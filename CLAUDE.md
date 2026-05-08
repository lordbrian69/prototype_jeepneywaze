# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is
Real-time jeepney tracking app for the Philippines. Phase 1 MVP targeting Metro Manila and Cebu pilot routes. Core innovation: the **Virtual Beacon** — vehicle detection from commuter GPS clustering (DBSCAN), no driver participation required.

## Monorepo Structure

```
apps/commuter/     Flutter — Commuter app (primary user-facing product)
apps/driver/       Flutter — Driver app (opt-in GPS supplement)
services/api/      Node.js + Fastify — REST API + Socket.io real-time
services/gps-ingestion/  Go — MQTT subscriber + Kafka producer
services/beacon-engine/  Python — DBSCAN Virtual Beacon core IP
infra/             Docker Compose, NGINX, PostgreSQL init
scripts/           Seeding and GPS simulation tools
```

## Critical Architecture: Virtual Beacon Model

**Do NOT treat this as a driver-tracking app.** The beacon system works from commuter GPS:
1. Every commuter app user publishes pings to MQTT topic `jw/gps/{user_token}` → Kafka topic `gps.pings`
2. `services/beacon-engine` consumes Kafka and maintains a **30-second sliding window** of pings
3. Every **5 seconds**, `dbscan.py` clusters pings into vehicle objects
4. `stop_pattern.py` filters private cars; `route_matcher.py` assigns the nearest route
5. Confirmed beacons → PostgreSQL → Redis pub/sub (`beacon:updates`, `beacon:removed`) → Socket.io → Flutter map

## Key Files

| File | What It Does |
|---|---|
| `services/beacon-engine/app/clustering/dbscan.py` | **Core IP** — DBSCAN vehicle clustering, beacon lifecycle |
| `services/beacon-engine/app/clustering/stop_pattern.py` | Private car filter (must stop near ≥2 known stops) |
| `services/beacon-engine/app/clustering/kalman.py` | Kalman smoother for beacon position |
| `services/beacon-engine/app/clustering/route_matcher.py` | PostGIS nearest-route assignment |
| `services/api/src/server.ts` | Fastify server setup — registers all routes + Socket.io |
| `services/api/src/routes/beacons.ts` | REST endpoints for beacon data |
| `services/api/src/socket/beacon.handler.ts` | Redis → Socket.io bridge; room pattern `route:{id}` / `stop:{id}` |
| `services/gps-ingestion/mqtt/broker.go` | MQTT subscriber (`jw/gps/#`) → Kafka producer |
| `apps/commuter/lib/services/gps_service.dart` | Commuter GPS broadcasting (accelerometer-adaptive intervals) |
| `apps/commuter/lib/features/map/map_screen.dart` | Main map UI |
| `infra/postgres/init.sql` | Full DB schema with PostGIS |

## Dev Commands

```bash
# Start all infra (Postgres/PostGIS, Redis, Mosquitto, Kafka/Zookeeper)
docker compose up -d

# Seed pilot routes
cd scripts && python seed-routes.py

# Start API — port 3000 (tsx watch, auto-reload)
cd services/api && npm run dev

# Start beacon engine — port 8001 (uvicorn, auto-reload)
cd services/beacon-engine && uvicorn main:app --reload

# Start GPS ingestion — port 8080
cd services/gps-ingestion && go run main.go

# Test Virtual Beacon formation (no real users needed)
cd scripts && python mock-gps.py --route edsa-cubao-quiapo --users 5

# Run commuter app
cd apps/commuter && flutter run
```

## Build & Lint Commands

```bash
# API — TypeScript compile check
cd services/api && npm run build

# API — ESLint
cd services/api && npm run lint

# Beacon engine — syntax check (no pytest suite yet)
cd services/beacon-engine && python -m py_compile main.py app/clustering/dbscan.py

# GPS ingestion — compile all packages
cd services/gps-ingestion && go build ./...

# Flutter — static analysis
cd apps/commuter && flutter analyze

# Flutter — unit tests
cd apps/commuter && flutter test
```

## Running the Commuter App (First Time)

Platform folders (`web/`, `android/`, `ios/`, `windows/`) are not committed. Generate the target(s) you want once:

```bash
cd apps/commuter && flutter create --platforms=web .
cd apps/commuter && flutter pub get
cd apps/commuter && flutter run -d chrome    # or -d windows / -d <device-id>
```

`intl` in `pubspec.yaml` must match the version that `flutter_localizations` pins (currently `^0.20.2` for Flutter 3.41.x). Lowering it breaks `pub get` with a "version solving failed" error.

## Android Build Requirements

Both apps target `minSdk = 23` (Android 6.0) and `targetSdk = 34`. The commuter app's `AndroidManifest.xml` needs `FOREGROUND_SERVICE_LOCATION` and `POST_NOTIFICATIONS` (Android 13+); the driver app needs the foreground-service permissions but not POST_NOTIFICATIONS (no FCM yet). Both need `ACCESS_BACKGROUND_LOCATION` so GPS keeps streaming when the app is backgrounded during a ride. iOS scaffolding has not been generated — it requires macOS + Xcode.

## Dev-Mode Init Guards (Do Not Remove)

`lib/main.dart` wraps `Supabase.initialize` and `Firebase.initializeApp` in try/catch, and `lib/core/router.dart` wraps `Supabase.instance.client.auth.currentSession` the same way. These guards are intentional — they let the app run against placeholder credentials in `core/constants.dart` so contributors without Supabase/Firebase projects can still launch the UI. Remove the guards only when real credentials become a hard requirement.

## Flutter Code Generation

Riverpod and Drift both require `build_runner`. Run this after adding or changing any `@riverpod` or `@DriftDatabase` annotations:

```bash
cd apps/commuter && flutter pub run build_runner build --delete-conflicting-outputs
# or watch mode during development:
cd apps/commuter && flutter pub run build_runner watch --delete-conflicting-outputs
```

Generated files (`*.g.dart`, `*.drift.dart`) are committed to the repo.

## Service Ports

| Service | Port |
|---|---|
| API (Fastify) | 3000 |
| GPS Ingestion (Go/Gin) | 8080 |
| Beacon Engine (FastAPI) | 8001 |
| MQTT (Mosquitto) | 1883 (TCP), 9001 (WS) |
| Kafka | 9092 |
| PostgreSQL | 5432 |
| Redis | 6379 |
| NGINX (reverse proxy) | 80 |

API routes are all prefixed `/api/v1/` (auth, beacons, routes, stops, eta).

## Database

PostgreSQL 16 + PostGIS 3.4. Key tables:
- `routes` — jeepney routes (transit-neutral schema, vehicle_type column)
- `stops` — kanto stops with PostGIS geometry
- `virtual_beacons` — active beacon objects (upserted every 5s by beacon engine)
- `gps_pings` — raw pings (6-hour rolling window, purge job needed)
- `commuters` — users with rotating anonymous tokens
- `crowding_reports` — Siksikan/Malwag votes
- `guardian_points` — Route Guardian gamification ledger

Run migrations: `cd services/api && npm run migrate`

## DBSCAN Parameters (Tunable)

In `.env` / `services/beacon-engine/app/config.py`:
```
DBSCAN_EPS=0.0003          # ~30m cluster radius (degrees); algorithm uses haversine on radians
DBSCAN_MIN_SAMPLES=3       # min users to form a beacon
JEEPNEY_MIN_SPEED_KMH=2    # filter stationary clusters
JEEPNEY_MAX_SPEED_KMH=65   # filter highway speeders
STOP_MATCH_RADIUS_M=40     # stop proximity for car filter
MIN_STOPS_TO_CONFIRM=2     # must match ≥2 stops
```

The beacon engine clusters every 5s (`BEACON_PUBLISH_INTERVAL_SECONDS`) over a 30s rolling window (`DBSCAN_WINDOW_SECONDS`). Beacons without an update for `BEACON_STALE_SECONDS` are marked stale and removed from the map.

Beacon matching between cycles uses 80m proximity + 45° heading tolerance to track continuity.

## Phase 1 Success Metrics

- 80% beacon coverage on pilot routes 6–10AM and 4–8PM
- Beacon formation rate: ≥3 users form beacon within 60s
- Battery drain: <1% complaint rate per 1,000 users
- Stop filter accuracy: >95% private car rejection

## Coding Conventions

- **TypeScript strict mode** for all API code
- **Riverpod** for all Flutter state management (no Provider, no BLoC)
- **Drift** for Flutter offline SQLite (no Hive, no SharedPreferences for structured data)
- **Pydantic v2** for all Python models
- All GPS coordinates: **lat/lng** order (never lng/lat) in application code
- PostGIS: `ST_MakePoint(lng, lat)` — note reversed order for WKT
- All times in **UTC**, display in Philippine Standard Time (UTC+8) only in UI

## Environment

Copy `.env.example` to `.env`. Required vars:
- `SUPABASE_URL` + `SUPABASE_ANON_KEY` (Supabase project)
- `JWT_SECRET` (generate: `openssl rand -hex 32`)
- Postgres/Redis/MQTT/Kafka — defaults work with docker compose

## What's NOT Built Yet (Next Tasks)

- [ ] Flutter offline route tile caching (MapLibre)
- [ ] WatermelonDB/Drift schema for commuter app
- [ ] Driver app GPS broadcast implementation
- [ ] Push notification smart alerts (FCM rule engine)
- [ ] Route Guardian points display in UI
- [ ] Auth flow (Supabase Phone OTP screens)
- [ ] Beacon → route matching via PostGIS nearest-route query
- [ ] GPS ping purge job (cron or pg_cron)
- [ ] Deployment configs for Railway.app
