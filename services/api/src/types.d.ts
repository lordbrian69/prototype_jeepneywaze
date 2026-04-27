import "fastify";
import "@fastify/jwt";
import type { Pool } from "pg";
import type { Server } from "socket.io";
import type { FastifyRequest, FastifyReply } from "fastify";

declare module "fastify" {
  interface FastifyInstance {
    db: Pool;
    io: Server;
    authenticate: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

declare module "@fastify/jwt" {
  interface FastifyJWT {
    payload: { sub: string; token: string; is_premium: boolean };
    user: { sub: string; token: string; is_premium: boolean };
  }
}
