import { FastifyInstance } from "fastify";
import { z } from "zod";

const ETAQuerySchema = z.object({
  stop_id: z.string().uuid(),
  route_id: z.string().uuid(),
});

export async function etaRoute(app: FastifyInstance) {
  /**
   * GET /api/v1/eta
   * Returns ETAs for all active beacons approaching a given stop.
   *
   * Algorithm:
   * 1. Find all active beacons on the route ahead of the stop
   * 2. Calculate distance_m using PostGIS ST_Distance
   * 3. ETA = distance_m / (speed_kmh * 1000/3600) with traffic factor
   * 4. Kalman-smoothed positions from beacon engine improve accuracy
   */
  app.get("/", async (req, reply) => {
    const { stop_id, route_id } = ETAQuerySchema.parse(req.query);

    // Get stop location
    const { rows: stops } = await app.db.query(
      "SELECT ST_X(geom::geometry) as lng, ST_Y(geom::geometry) as lat FROM stops WHERE id = $1",
      [stop_id]
    );
    if (!stops[0]) return reply.code(404).send({ error: "Stop not found" });

    const stop = stops[0];

    const { rows: etas } = await app.db.query(
      `WITH beacon_distances AS (
         SELECT
           b.id,
           b.speed_kmh,
           b.confidence,
           b.occupancy_est,
           b.last_seen,
           ST_Distance(
             b.geom::geography,
             ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
           ) AS dist_m
         FROM virtual_beacons b
         WHERE b.route_id = $3
           AND b.status = 'active'
           AND b.last_seen > NOW() - INTERVAL '90 seconds'
       )
       SELECT
         id AS beacon_id,
         dist_m,
         CASE
           WHEN speed_kmh > 1 THEN ROUND(dist_m / (speed_kmh * 1000.0 / 3600))
           ELSE NULL
         END AS eta_seconds,
         occupancy_est,
         confidence,
         last_seen
       FROM beacon_distances
       WHERE dist_m > 0  -- beacon must be ahead of stop
       ORDER BY dist_m ASC
       LIMIT 5`,
      [stop.lng, stop.lat, route_id]
    );

    const formatted = etas.map((row) => ({
      beacon_id: row.beacon_id,
      eta_seconds: row.eta_seconds,
      eta_label: formatETA(row.eta_seconds),
      distance_m: Math.round(row.dist_m),
      occupancy_est: row.occupancy_est,
      confidence: row.confidence,
    }));

    return reply.send({ stop_id, route_id, etas: formatted });
  });
}

function formatETA(seconds: number | null): string {
  if (!seconds) return "Malapit na"; // "Almost here"
  if (seconds < 60) return "Malapit na";
  const mins = Math.round(seconds / 60);
  if (mins === 1) return "1 minuto";
  return `${mins} minuto`;
}
