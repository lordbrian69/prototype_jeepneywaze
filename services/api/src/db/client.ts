import { Pool } from "pg";

export const db = new Pool({
  host: process.env.POSTGRES_HOST ?? "localhost",
  port: parseInt(process.env.POSTGRES_PORT ?? "5432"),
  database: process.env.POSTGRES_DB ?? "jeepneywaze",
  user: process.env.POSTGRES_USER ?? "jeepney",
  password: process.env.POSTGRES_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 5_000,
});

db.on("error", (err) => console.error("Postgres pool error:", err));
