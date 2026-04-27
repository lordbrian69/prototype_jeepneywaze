import "dotenv/config";
import { readFile, readdir } from "node:fs/promises";
import { join, resolve } from "node:path";
import { db } from "./client";

async function run() {
  // Apply base schema (idempotent when containerized — safe for fresh DBs)
  const rootSql = resolve(__dirname, "../../../../infra/postgres/init.sql");
  try {
    const sql = await readFile(rootSql, "utf-8");
    console.log(`→ applying ${rootSql}`);
    await db.query(sql);
  } catch (e) {
    console.warn(`(skipping init.sql: ${(e as Error).message})`);
  }

  // Apply any timestamped .sql files under src/db/migrations
  const migDir = join(__dirname, "migrations");
  let files: string[] = [];
  try {
    files = (await readdir(migDir)).filter((f) => f.endsWith(".sql")).sort();
  } catch {
    // no migrations dir — OK
  }

  for (const f of files) {
    const sql = await readFile(join(migDir, f), "utf-8");
    console.log(`→ applying migrations/${f}`);
    await db.query(sql);
  }

  console.log("migrations complete");
  await db.end();
}

run().catch((err) => {
  console.error("migration failed:", err);
  process.exit(1);
});
