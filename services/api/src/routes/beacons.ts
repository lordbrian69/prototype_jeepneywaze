import { FastifyInstance } from "fastify";
import { z } from "zod";

const NearbyQuerySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
  radius_m: z.coerce.number().min(100).max(5000).default(1000),
  route_id: z.string().uuid().optional(),
});

export async function beaconsRoute(app: FastifyInstance) {
  /**
   * GET /api/v1/beacons/nearby
   * Returns active Virtual Beacons within radius of a point.
   * Used by Commuter App to populate the live map.
   */
  app.get("/nearby", async (req, reply) => {
    const query = NearbyQuerySchema.parse(req.query);

    const { rows } = await app.db.query(
      `SELECT
         b.id,
         b.route_id,
         r.name     AS route_name,
         r.code     AS route_code,
         ST_X(b.geom::geometry) AS lng,
         ST_Y(b.geom::geometry) AS lat,
         b.heading_deg,
         b.speed_kmh,
         b.occupancy_est,
         b.confidence,
         b.last_seen,
         ST_Distance(
           b.geom::geography,
           ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography
         ) AS distance_m
       FROM virtual_beacons b
       LEFT JOIN routes r ON r.id = b.route_id
       WHERE b.status = 'active'
         AND b.last_seen > NOW() - INTERVAL '60 seconds'
         AND ST_DWithin(
           b.geom::geography,
           ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
           $3
         )
         ${query.route_id ? "AND b.route_id = $4" : ""}
       ORDER BY distance_m ASC
       LIMIT 50`,
      query.route_id
        ? [query.lat, query.lng, query.radius_m, query.route_id]
        : [query.lat, query.lng, query.radius_m]
    );

    return reply.send({ beacons: rows });
  });

  /**
   * GET /api/v1/beacons/:id
   * Returns a single beacon with latest crowding reports.
   */
  app.get<{ Params: { id: string } }>("/:id", async (req, reply) => {
    const { rows } = await app.db.query(
      `SELECT b.*, r.name AS route_name, r.code AS route_code,
              ST_X(b.geom::geometry) AS lng, ST_Y(b.geom::geometry) AS lat
       FROM virtual_beacons b
       LEFT JOIN routes r ON r.id = b.route_id
       WHERE b.id = $1 AND b.status = 'active'`,
      [req.params.id]
    );

    if (!rows[0]) return reply.code(404).send({ error: "Beacon not found" });

    // Most recent crowding reports for this beacon
    const { rows: reports } = await app.db.query(
      `SELECT level, COUNT(*) as votes
       FROM crowding_reports
       WHERE beacon_id = $1 AND ts > NOW() - INTERVAL '5 minutes'
       GROUP BY level`,
      [req.params.id]
    );

    return reply.send({ beacon: rows[0], crowding: reports });
  });

  /**
   * POST /api/v1/beacons/:id/crowding
   * Submit a Siksikan/Malwag crowding report (commuters on the vehicle).
   */
  app.post<{ Params: { id: string }; Body: { level: string; user_token: string } }>(
    "/:id/crowding",
    async (req, reply) => {
      const { level, user_token } = req.body;
      const validLevels = ["malwag", "ok", "siksikan", "puno"];

      if (!validLevels.includes(level)) {
        return reply.code(400).send({ error: "Invalid crowding level" });
      }

      // Find commuter by token
      const { rows: commuters } = await app.db.query(
        "SELECT id FROM commuters WHERE token = $1 AND token_expires > NOW()",
        [user_token]
      );
      if (!commuters[0]) return reply.code(401).send({ error: "Invalid token" });

      await app.db.query(
        "INSERT INTO crowding_reports (beacon_id, commuter_id, level) VALUES ($1, $2, $3)",
        [req.params.id, commuters[0].id, level]
      );

      // Award Route Guardian points
      await app.db.query(
        "INSERT INTO guardian_points (commuter_id, event_type, points) VALUES ($1, 'crowding_report', 5)",
        [commuters[0].id]
      );

      // Broadcast updated crowding via Socket.io
      app.io.to(`route:${req.params.id}`).emit("crowding_update", {
        beacon_id: req.params.id,
        level,
        ts: new Date().toISOString(),
      });

      return reply.code(201).send({ ok: true, points_earned: 5 });
    }
  );
}
