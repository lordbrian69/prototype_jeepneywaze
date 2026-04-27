import { FastifyInstance } from "fastify";
import { z } from "zod";

export async function stopsRoute(app: FastifyInstance) {
  // GET /api/v1/stops/nearest — find nearest stop to a GPS coordinate
  app.get("/nearest", async (req, reply) => {
    const schema = z.object({
      lat: z.coerce.number(),
      lng: z.coerce.number(),
      route_id: z.string().uuid().optional(),
    });

    const { lat, lng, route_id } = schema.parse(req.query);

    const { rows } = await app.db.query(
      `SELECT s.id, s.name, s.name_tl, s.sequence, s.landmark,
              r.id AS route_id, r.name AS route_name, r.code AS route_code,
              ST_X(s.geom::geometry) as lng, ST_Y(s.geom::geometry) as lat,
              ST_Distance(
                s.geom::geography,
                ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography
              ) AS distance_m
       FROM stops s
       JOIN routes r ON r.id = s.route_id
       WHERE r.active = true
         ${route_id ? "AND s.route_id = $3" : ""}
       ORDER BY distance_m ASC
       LIMIT 5`,
      route_id ? [lat, lng, route_id] : [lat, lng]
    );

    return reply.send({ stops: rows });
  });
}
