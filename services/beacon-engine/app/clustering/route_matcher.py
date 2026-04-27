"""
Route Matcher
=============
Assigns each Virtual Beacon to the most likely route by checking
which route's stops are nearest to the beacon centroid.

Since the seed data does not yet populate routes.geom (LineString),
we match by nearest stop rather than by route geometry. When a beacon
sits within `stop_match_radius_m * 2` of a stop, that stop's route_id
wins.
"""

import math
from typing import Dict, List, Optional, Tuple

import psycopg2
import psycopg2.extras

from app.config import settings


class RouteMatcher:
    def __init__(self) -> None:
        # (route_id, lat, lng)
        self._stops: List[Tuple[str, float, float]] = []
        self._loaded = False

    def load(self) -> None:
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
                    """SELECT route_id::text AS route_id,
                              ST_Y(geom::geometry) AS lat,
                              ST_X(geom::geometry) AS lng
                       FROM stops"""
                )
                self._stops = [
                    (row["route_id"], row["lat"], row["lng"])
                    for row in cur.fetchall()
                ]
        finally:
            conn.close()
        self._loaded = True

    def match(self, lat: float, lng: float) -> Optional[str]:
        """Return route_id of the nearest stop within the match radius, else None."""
        if not self._loaded:
            self.load()
        if not self._stops:
            return None

        best: Tuple[Optional[str], float] = (None, float("inf"))
        for route_id, slat, slng in self._stops:
            d = _haversine_m(lat, lng, slat, slng)
            if d < best[1]:
                best = (route_id, d)

        max_radius = settings.stop_match_radius_m * 3  # ~120m
        return best[0] if best[1] <= max_radius else None

    def reload(self) -> None:
        self._loaded = False
        self.load()


def _haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    R = 6_371_000
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lng2 - lng1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2
    return 2 * R * math.asin(math.sqrt(a))
