import { FastifyInstance } from "fastify";
import { z } from "zod";
import crypto from "crypto";

export async function authRoute(app: FastifyInstance) {
  /**
   * POST /api/v1/auth/verify-otp
   * Called after Supabase Phone OTP verification on the mobile app.
   * Returns a JeepneyWaze JWT + rotating user token for anonymous GPS pings.
   */
  app.post("/verify-otp", async (req, reply) => {
    const schema = z.object({
      supabase_access_token: z.string(),
      supabase_user_id: z.string().uuid(),
      lang: z.enum(["tl", "ceb", "ilo", "hil", "bcl", "kpm", "war"]).default("tl"),
    });

    const { supabase_access_token, supabase_user_id, lang } = schema.parse(req.body);

    // Verify the Supabase JWT (in production: validate against Supabase public key)
    // For MVP: trust the user_id and issue our own token
    const token = generateUserToken();
    const tokenExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24h

    // Upsert commuter record
    const { rows } = await app.db.query(
      `INSERT INTO commuters (auth_user_id, token, token_expires, lang)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (auth_user_id) DO UPDATE
         SET token = $2, token_expires = $3, lang = $4
       RETURNING id, is_premium`,
      [supabase_user_id, token, tokenExpires, lang]
    );

    const commuter = rows[0];

    const jwt = app.jwt.sign(
      { sub: commuter.id, token, is_premium: commuter.is_premium },
      { expiresIn: "1h" }
    );

    return reply.send({ jwt, user_token: token, is_premium: commuter.is_premium });
  });

  /**
   * POST /api/v1/auth/refresh-token
   * Rotates the anonymous GPS ping token (called daily by the app).
   */
  app.post("/refresh-token", { preHandler: [app.authenticate] }, async (req, reply) => {
    const user = req.user as { sub: string };
    const newToken = generateUserToken();
    const tokenExpires = new Date(Date.now() + 24 * 60 * 60 * 1000);

    await app.db.query(
      "UPDATE commuters SET token = $1, token_expires = $2 WHERE id = $3",
      [newToken, tokenExpires, user.sub]
    );

    return reply.send({ user_token: newToken });
  });
}

function generateUserToken(): string {
  return crypto.randomBytes(32).toString("hex");
}
