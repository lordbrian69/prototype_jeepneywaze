"""
JeepneyWaze Beacon Engine
=========================
FastAPI service that:
1. Consumes GPS pings from Kafka
2. Runs DBSCAN clustering every 5 seconds
3. Persists confirmed Virtual Beacons to PostgreSQL
4. Publishes beacon updates to Redis pub/sub (consumed by API → Socket.io)
"""

import asyncio
import logging
import threading
import json
from contextlib import asynccontextmanager

import psycopg2
import redis as sync_redis
from fastapi import FastAPI

from app.config import settings
from app.clustering.dbscan import VirtualBeaconEngine
from app.clustering.route_matcher import RouteMatcher
from app.clustering.stop_pattern import StopPatternFilter
from app.consumers.kafka_consumer import GPSPingConsumer
from app.models.beacon import GPSPing

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

# ── Globals ─────────────────────────────────────────────────────────
stop_filter = StopPatternFilter()
route_matcher = RouteMatcher()
engine = VirtualBeaconEngine(stop_filter, route_matcher)
redis_client = sync_redis.from_url(settings.redis_url)


def on_ping(ping: GPSPing):
    engine.ingest_ping(ping)


async def beacon_publish_loop():
    """Every 5s: cluster pings → persist beacons → publish to Redis."""
    db_conn = psycopg2.connect(
        host=settings.postgres_host,
        port=settings.postgres_port,
        dbname=settings.postgres_db,
        user=settings.postgres_user,
        password=settings.postgres_password,
    )

    while True:
        await asyncio.sleep(settings.beacon_publish_interval_seconds)
        try:
            beacons = engine.cluster()
            active = [b for b in beacons if b.status == "active"]
            stale = [b for b in beacons if b.status == "stale"]

            with db_conn.cursor() as cur:
                for b in active:
                    cur.execute(
                        """INSERT INTO virtual_beacons
                             (id, route_id, geom, heading_deg, speed_kmh,
                              occupancy_est, confidence, contributor_ids, status, last_seen)
                           VALUES (%s, %s,
                             ST_SetSRID(ST_MakePoint(%s, %s), 4326),
                             %s, %s, %s, %s, %s, 'active', NOW())
                           ON CONFLICT (id) DO UPDATE SET
                             geom        = EXCLUDED.geom,
                             heading_deg = EXCLUDED.heading_deg,
                             speed_kmh   = EXCLUDED.speed_kmh,
                             occupancy_est = EXCLUDED.occupancy_est,
                             confidence  = EXCLUDED.confidence,
                             contributor_ids = EXCLUDED.contributor_ids,
                             last_seen   = NOW()""",
                        (b.id, b.route_id, b.lng, b.lat,
                         b.heading_deg, b.speed_kmh,
                         b.occupancy_est, b.confidence,
                         b.contributor_tokens)
                    )
                    # Publish to Redis → API → Socket.io
                    redis_client.publish("beacon:updates", json.dumps(b.to_redis_dict()))

                for b in stale:
                    cur.execute(
                        "UPDATE virtual_beacons SET status = 'stale' WHERE id = %s",
                        (b.id,)
                    )
                    redis_client.publish("beacon:removed",
                                         json.dumps({"beacon_id": b.id, "route_id": b.route_id}))

            db_conn.commit()
            logger.info(f"Published {len(active)} active, {len(stale)} stale beacons")

        except Exception as e:
            logger.error(f"Beacon publish loop error: {e}")
            db_conn.rollback()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load stops into memory (used by the private-car filter and route matcher)
    logger.info("Loading stops from database...")
    stop_filter.load_stops()
    route_matcher.load()
    logger.info(f"Loaded {len(stop_filter._stops)} stops, {len(route_matcher._stops)} route-stop rows")

    # Start Kafka consumer in background thread
    consumer = GPSPingConsumer(on_ping)
    kafka_thread = threading.Thread(target=consumer.start, daemon=True)
    kafka_thread.start()

    # Start beacon publish loop
    asyncio.create_task(beacon_publish_loop())

    yield

    consumer.stop()


app = FastAPI(title="JeepneyWaze Beacon Engine", lifespan=lifespan)


@app.get("/health")
def health():
    ping_count = len(engine._ping_window)
    active_count = sum(1 for b in engine._active_beacons.values() if b.status == "active")
    return {
        "status": "ok",
        "pings_in_window": ping_count,
        "active_beacons": active_count,
        "stops_loaded": len(stop_filter._stops),
    }


@app.get("/beacons")
def list_beacons():
    return {
        "beacons": [b.to_redis_dict() for b in engine._active_beacons.values()]
    }
