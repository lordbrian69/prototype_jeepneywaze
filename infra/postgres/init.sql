-- JeepneyWaze — PostgreSQL + PostGIS Schema
-- Phase 1: Pilot routes (Metro Manila + Cebu)

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── Vehicle Types (transit-neutral from day 1) ────────────────────
CREATE TYPE vehicle_type AS ENUM ('jeepney', 'uv_express', 'tricycle', 'bus', 'lrt', 'mrt');
CREATE TYPE beacon_status AS ENUM ('active', 'stale', 'terminated');

-- ─── Routes ────────────────────────────────────────────────────────
CREATE TABLE routes (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code         VARCHAR(20) UNIQUE NOT NULL,  -- e.g. 'EDSA-CUB-QUI'
  name         VARCHAR(100) NOT NULL,
  name_tl      VARCHAR(100),                  -- Tagalog
  name_ceb     VARCHAR(100),                  -- Cebuano
  vehicle_type vehicle_type NOT NULL DEFAULT 'jeepney',
  geom         GEOMETRY(LineString, 4326),    -- Route path (WGS84)
  fare_base    NUMERIC(6,2) NOT NULL DEFAULT 13.00,
  fare_per_km  NUMERIC(6,2) NOT NULL DEFAULT 1.80,
  active       BOOLEAN NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX routes_geom_idx ON routes USING GIST (geom);

-- ─── Stops (Kanto) ─────────────────────────────────────────────────
CREATE TABLE stops (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  route_id    UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
  sequence    INT NOT NULL,
  name        VARCHAR(100) NOT NULL,
  name_tl     VARCHAR(100),
  geom        GEOMETRY(Point, 4326) NOT NULL,
  radius_m    INT NOT NULL DEFAULT 40,       -- stop detection radius
  landmark    VARCHAR(200),                   -- e.g. 'Jollibee Cubao'
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(route_id, sequence)
);

CREATE INDEX stops_geom_idx ON stops USING GIST (geom);
CREATE INDEX stops_route_id_idx ON stops (route_id);

-- ─── Virtual Beacons ───────────────────────────────────────────────
-- Each row = one detected vehicle cluster (updated every ~5 seconds)
CREATE TABLE virtual_beacons (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  route_id        UUID REFERENCES routes(id),
  geom            GEOMETRY(Point, 4326) NOT NULL,
  heading_deg     NUMERIC(5,2),               -- 0–360 degrees
  speed_kmh       NUMERIC(5,2),
  occupancy_est   INT,                        -- estimated passengers
  confidence      NUMERIC(3,2),               -- 0.00–1.00
  contributor_ids TEXT[],                     -- pseudonymous user token array
  status          beacon_status NOT NULL DEFAULT 'active',
  last_seen       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX vbeacons_geom_idx ON virtual_beacons USING GIST (geom);
CREATE INDEX vbeacons_route_id_idx ON virtual_beacons (route_id);
CREATE INDEX vbeacons_status_idx ON virtual_beacons (status);
CREATE INDEX vbeacons_last_seen_idx ON virtual_beacons (last_seen DESC);

-- ─── GPS Pings (short retention — 6 hours rolling window) ──────────
-- Raw commuter pings before beacon clustering.
-- TimescaleDB hypertable in Phase 2. Plain table for Phase 1 MVP.
CREATE TABLE gps_pings (
  id           BIGSERIAL PRIMARY KEY,
  user_token   VARCHAR(64) NOT NULL,          -- rotating pseudonymous token
  geom         GEOMETRY(Point, 4326) NOT NULL,
  accuracy_m   NUMERIC(6,2),
  speed_kmh    NUMERIC(5,2),
  heading_deg  NUMERIC(5,2),
  altitude_m   NUMERIC(8,2),
  is_moving    BOOLEAN,
  ts           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX gps_pings_token_ts_idx ON gps_pings (user_token, ts DESC);
CREATE INDEX gps_pings_geom_idx ON gps_pings USING GIST (geom);
CREATE INDEX gps_pings_ts_idx ON gps_pings (ts DESC);

-- Auto-purge pings older than 6 hours (keep beacon history, not raw pings)
-- Run via pg_cron in production; handled by cleanup job in Phase 1
-- SELECT cron.schedule('purge-old-pings', '*/30 * * * *',
--   'DELETE FROM gps_pings WHERE ts < NOW() - INTERVAL ''6 hours''');

-- ─── Drivers (opt-in only) ─────────────────────────────────────────
CREATE TABLE drivers (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_user_id  UUID UNIQUE NOT NULL,         -- Supabase auth.users.id
  plate_number  VARCHAR(20),
  route_id      UUID REFERENCES routes(id),
  phone_masked  VARCHAR(20),                   -- last 4 digits only
  is_active     BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Commuters ─────────────────────────────────────────────────────
CREATE TABLE commuters (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_user_id  UUID UNIQUE NOT NULL,
  token         VARCHAR(64) UNIQUE NOT NULL,  -- rotating daily token
  token_expires TIMESTAMPTZ NOT NULL,
  is_premium    BOOLEAN NOT NULL DEFAULT false,
  lang          VARCHAR(10) NOT NULL DEFAULT 'tl',  -- tl, ceb, ilo...
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Route Guardian Points ─────────────────────────────────────────
CREATE TABLE guardian_points (
  id           BIGSERIAL PRIMARY KEY,
  commuter_id  UUID NOT NULL REFERENCES commuters(id) ON DELETE CASCADE,
  route_id     UUID REFERENCES routes(id),
  event_type   VARCHAR(50) NOT NULL,  -- 'ping', 'crowding_report', 'stop_report'
  points       INT NOT NULL,
  ts           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX guardian_points_commuter_idx ON guardian_points (commuter_id, ts DESC);

-- ─── Crowding Reports (Siksikan/Malwag) ───────────────────────────
CREATE TYPE crowding_level AS ENUM ('malwag', 'ok', 'siksikan', 'puno');

CREATE TABLE crowding_reports (
  id           BIGSERIAL PRIMARY KEY,
  beacon_id    UUID REFERENCES virtual_beacons(id),
  commuter_id  UUID NOT NULL REFERENCES commuters(id),
  level        crowding_level NOT NULL,
  ts           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX crowding_reports_beacon_idx ON crowding_reports (beacon_id, ts DESC);

-- ─── Seed: Phase 1 Pilot Routes ────────────────────────────────────
INSERT INTO routes (code, name, name_tl, vehicle_type, fare_base, fare_per_km) VALUES
  ('MNL-CUB-QUI',
   'Cubao to Quiapo (EDSA)',
   'Cubao hanggang Quiapo',
   'jeepney', 13.00, 1.80),
  ('CEB-COL-SM',
   'Colon Street to SM City Cebu',
   'Colon ngadto sa SM City',
   'jeepney', 13.00, 1.80);
