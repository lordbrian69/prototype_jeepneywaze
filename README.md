# JeepneyWaze — Phase 1 Monorepo
**Own the Jeepney Commuter · Year 1–2**

> Real-time jeepney tracking powered by the Virtual Beacon engine —
> zero hardware, commuter GPS clustering, no driver participation required.

---

## Architecture

```
jeepneywaze/
├── apps/
│   ├── commuter/          Flutter — Commuter App (Android + iOS)
│   └── driver/            Flutter — Driver App (opt-in GPS broadcast)
├── services/
│   ├── api/               Node.js + Fastify — REST + Socket.io API
│   ├── gps-ingestion/     Go — High-throughput GPS ping receiver (MQTT → Kafka)
│   └── beacon-engine/     Python — DBSCAN clustering + Kalman filter (Virtual Beacon IP)
├── infra/
│   ├── docker-compose.yml         Local dev stack
│   ├── docker-compose.prod.yml    Production stack
│   ├── nginx/                     Reverse proxy config
│   ├── postgres/                  DB init scripts
│   └── railway/                   Railway.app deploy configs
└── scripts/
    ├── seed-routes.py     Seed pilot route data (EDSA Cubao–Quiapo, Cebu Colon–SM)
    └── mock-gps.py        Replay recorded commute trajectories for beacon testing
```

## Tech Stack (Phase 1)

| Layer | Technology |
|---|---|
| Mobile | Flutter + Riverpod + Drift (offline SQLite) + flutter_map (MapLibre) |
| API | Node.js + Fastify + Socket.io + Redis Pub/Sub |
| GPS Ingestion | Go + Gin + MQTT (Eclipse Mosquitto) + Kafka |
| Virtual Beacon | Python + FastAPI + DBSCAN (scikit-learn) + Kalman (filterpy) |
| Database | PostgreSQL 16 + PostGIS 3.4 |
| Cache | Redis 7 |
| Auth | Supabase Auth (Phone + OTP) |
| Maps | MapLibre GL (flutter_map) + OpenStreetMap tiles |
| Deployment | Docker Compose (dev) → Railway.app (MVP) |

---

## Quick Start (Local Dev)

### Prerequisites
- Docker & Docker Compose
- Flutter SDK 3.19+
- Node.js 20+
- Go 1.22+
- Python 3.11+

### 1. Environment
```bash
cp .env.example .env
# Fill in: SUPABASE_URL, SUPABASE_ANON_KEY, JWT_SECRET
```

### 2. Start infrastructure
```bash
docker compose up -d
# Starts: PostgreSQL + PostGIS, Redis, Mosquitto (MQTT), Kafka, Zookeeper
```

### 3. Run database migrations
```bash
cd services/api
npm install
npm run migrate
```

### 4. Seed pilot routes
```bash
cd scripts
python seed-routes.py
```

### 5. Start services
```bash
# Terminal 1 — API
cd services/api && npm run dev

# Terminal 2 — GPS Ingestion
cd services/gps-ingestion && go run main.go

# Terminal 3 — Beacon Engine
cd services/beacon-engine && uvicorn main:app --reload

# Terminal 4 — Mock GPS (for testing without real drivers)
cd scripts && python mock-gps.py --route edsa-cubao-quiapo --speed 1x
```

### 6. Run apps
```bash
# Commuter app
cd apps/commuter && flutter run

# Driver app
cd apps/driver && flutter run
```

---

## Phase 1 Pilot Routes
- **Route A**: EDSA Cubao → Quiapo (Metro Manila) — ~18 stops
- **Route B**: Colon Street → SM City Cebu — ~12 stops

## Success Metrics (Phase 1)
- 80% live-map beacon coverage on pilot routes during peak hours (6–10 AM, 4–8 PM)
- Virtual Beacon formation rate: ≥3 users lock into single vehicle within 60 seconds
- Battery drain complaints: <1% per 1,000 active users
- Stop-pattern filter accuracy: >95% private car rejection rate

---

## Environment Variables
See `.env.example` for all required variables.

## Contributing
Each service has its own README in its directory.
