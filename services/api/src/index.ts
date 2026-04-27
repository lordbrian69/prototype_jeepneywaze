import "dotenv/config";
import { buildServer } from "./server";

const PORT = parseInt(process.env.API_PORT ?? "3000");
const HOST = process.env.API_HOST ?? "0.0.0.0";

async function main() {
  const app = await buildServer();
  await app.listen({ port: PORT, host: HOST });
  app.log.info(`JeepneyWaze API running on http://${HOST}:${PORT}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
