import { FastifyInstance } from "fastify";

export async function routesRoute(app: FastifyInstance) {
  // GET /api/v1/routes — all active routes
  app.get("/", async (_req, reply) => {
    const { rows } = await app.db.query(
      `SELECT id, code, name, name_tl, name_ceb, vehicle_type, fare_base, fare_per_km,
              ST_AsGeoJSON(geom)::json AS geojson
       FROM routes WHERE active = true ORDER BY code`
    );
    return reply.send({ routes: rows });
  });

  // GET /api/v1/routes/:id/stops — stops for a route
  app.get<{ Params: { id: string } }>("/:id/stops", async (req, reply) => {
    const { rows } = await app.db.query(
      `SELECT id, sequence, name, name_tl, landmark, radius_m,
              ST_X(geom::geometry) as lng, ST_Y(geom::geometry) as lat
       FROM stops WHERE route_id = $1 ORDER BY sequence`,
      [req.params.id]
    );
    return reply.send({ stops: rows });
  });
}
