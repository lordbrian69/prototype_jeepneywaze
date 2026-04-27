"""
Stop-Pattern Recognition Filter
================================
Distinguishes jeepneys from private cars by checking whether
a GPS cluster has passed through known jeepney stop locations.

Private cars stop anywhere.
Jeepneys stop at known kanto (street corners) / stops.

This filter is the key to keeping private GPS signals out of the
Virtual Beacon feed — protecting data quality and preventing false ETAs.
"""

import math
from typing import List, Tuple
import psycopg2
import psycopg2.extras
from app.config import settings


class StopPatternFilter:
    def __init__(self):
        self._stops: List[Tuple[float, float]] = []  # (lat, lng)
        self._loaded = False

    def load_stops(self) -> None:
        """Load all stop coordinates from PostgreSQL into memory."""
        conn = psycopg2.connect(
            host=settings.postgres_host,
            port=settings.postgres_port,
            dbname=settings.postgres_db,
            user=settings.postgres_user,
            password=settings.postgres_password,
        )
        try:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                cur.execute(
                    "SELECT ST_Y(geom::geometry) as lat, ST_X(geom::geometry) as lng FROM stops"
                )
                self._stops = [(row["lat"], row["lng"]) for row in cur.fetchall()]
        finally:
            conn.close()
        self._loaded = True

    def passes(self, recent_positions: List[Tuple[float, float]]) -> bool:
        """
        Returns True if the cluster trajectory passes through ≥ min_stops_to_confirm
        known stop locations within stop_match_radius_m.

        Called during DBSCAN clustering for each candidate vehicle cluster.
        """
        if not self._loaded:
            self.load_stops()

        if not self._stops:
            # No stops loaded — pass all clusters (fail-open for MVP cold start)
            return True

        matched_stops = set()
        for pos_lat, pos_lng in recent_positions:
            for stop_lat, stop_lng in self._stops:
                dist = _haversine_m(pos_lat, pos_lng, stop_lat, stop_lng)
                if dist <= settings.stop_match_radius_m:
                    matched_stops.add((round(stop_lat, 5), round(stop_lng, 5)))

        return len(matched_stops) >= settings.min_stops_to_confirm

    def reload(self) -> None:
        """Refresh stop cache (call after route/stop data changes)."""
        self._loaded = False
        self.load_stops()


def _haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    R = 6_371_000
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lng2 - lng1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2
    return 2 * R * math.asin(math.sqrt(a))
