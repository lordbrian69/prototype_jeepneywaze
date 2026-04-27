import { Server, Socket } from "socket.io";
import { createClient } from "redis";

/**
 * Socket.io beacon handler
 *
 * Events emitted to clients:
 *   beacon:update   — new/updated Virtual Beacon position
 *   beacon:removed  — beacon became stale (jeepney arrived / stopped)
 *   eta:update      — updated ETA for a subscribed stop
 *   crowding:update — crowding level changed for a beacon
 *
 * Events received from clients:
 *   subscribe:route   — commuter subscribes to live updates for a route
 *   unsubscribe:route — commuter unsubscribes
 *   subscribe:stop    — commuter subscribes to ETA for a specific stop
 */
export function registerBeaconSocket(io: Server) {
  // Subscribe to Redis channel where beacon-engine publishes updates
  const redis = createClient({ url: process.env.REDIS_URL });
  redis.connect().catch(console.error);

  redis.subscribe("beacon:updates", (message) => {
    try {
      const update = JSON.parse(message) as BeaconUpdate;
      // Broadcast to all commuters subscribed to this route room
      io.to(`route:${update.route_id}`).emit("beacon:update", update);
    } catch (e) {
      console.error("Failed to parse beacon update:", e);
    }
  });

  redis.subscribe("beacon:removed", (message) => {
    try {
      const { beacon_id, route_id } = JSON.parse(message);
      io.to(`route:${route_id}`).emit("beacon:removed", { beacon_id });
    } catch (e) {
      console.error("Failed to parse beacon removal:", e);
    }
  });

  io.on("connection", (socket: Socket) => {
    console.log(`Socket connected: ${socket.id}`);

    socket.on("subscribe:route", (route_id: string) => {
      socket.join(`route:${route_id}`);
      console.log(`Socket ${socket.id} subscribed to route ${route_id}`);
    });

    socket.on("unsubscribe:route", (route_id: string) => {
      socket.leave(`route:${route_id}`);
    });

    socket.on("subscribe:stop", (stop_id: string) => {
      socket.join(`stop:${stop_id}`);
    });

    socket.on("disconnect", () => {
      console.log(`Socket disconnected: ${socket.id}`);
    });
  });
}

interface BeaconUpdate {
  id: string;
  route_id: string;
  lat: number;
  lng: number;
  heading_deg: number;
  speed_kmh: number;
  occupancy_est: number;
  confidence: number;
  last_seen: string;
}
