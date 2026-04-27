import Fastify from "fastify";
import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import rateLimit from "@fastify/rate-limit";
import { Server } from "socket.io";
import { createAdapter } from "@socket.io/redis-adapter";
import { createClient } from "redis";
import { beaconsRoute } from "./routes/beacons";
import { routesRoute } from "./routes/routes";
import { stopsRoute } from "./routes/stops";
import { etaRoute } from "./routes/eta";
import { authRoute } from "./routes/auth";
import { registerBeaconSocket } from "./socket/beacon.handler";
import { db } from "./db/client";

export async function buildServer() {
  const app = Fastify({
    logger: {
      transport: process.env.NODE_ENV === "development"
        ? { target: "pino-pretty", options: { colorize: true } }
        : undefined,
    },
  });

  // ── Plugins ──────────────────────────────────────────
  await app.register(cors, {
    origin: process.env.NODE_ENV === "development" ? "*" : process.env.ALLOWED_ORIGINS?.split(","),
    credentials: true,
  });

  await app.register(jwt, { secret: process.env.JWT_SECRET ?? "dev-secret-change-me" });

  app.decorate("authenticate", async (req, reply) => {
    try {
      await req.jwtVerify();
    } catch (err) {
      reply.code(401).send({ error: "Unauthorized" });
    }
  });

  await app.register(rateLimit, {
    max: 300,
    timeWindow: "1 minute",
    keyGenerator: (req) => req.headers["x-user-token"] as string ?? req.ip,
  });

  // ── Socket.io with Redis adapter (horizontal scaling) ─
  const io = new Server(app.server, {
    cors: { origin: "*" },
    transports: ["websocket", "polling"],
  });

  if (process.env.REDIS_URL) {
    const pubClient = createClient({ url: process.env.REDIS_URL });
    const subClient = pubClient.duplicate();
    await Promise.all([pubClient.connect(), subClient.connect()]);
    io.adapter(createAdapter(pubClient, subClient));
    app.log.info("Socket.io Redis adapter connected");
  }

  app.decorate("io", io);
  app.decorate("db", db);

  // ── Register Socket handlers ──────────────────────────
  registerBeaconSocket(io);

  // ── Routes ───────────────────────────────────────────
  await app.register(authRoute, { prefix: "/api/v1/auth" });
  await app.register(beaconsRoute, { prefix: "/api/v1/beacons" });
  await app.register(routesRoute, { prefix: "/api/v1/routes" });
  await app.register(stopsRoute, { prefix: "/api/v1/stops" });
  await app.register(etaRoute, { prefix: "/api/v1/eta" });

  // ── Health check ─────────────────────────────────────
  app.get("/health", async () => ({
    status: "ok",
    service: "jeepneywaze-api",
    timestamp: new Date().toISOString(),
  }));

  return app;
}
