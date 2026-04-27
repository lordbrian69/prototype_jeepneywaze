"""
Virtual Beacon Engine — DBSCAN Clustering
==========================================
Core IP of JeepneyWaze.

Algorithm:
1. Collect GPS pings in a 30-second sliding window
2. Run DBSCAN on (lat, lng) coordinates to find clusters
3. For each cluster with ≥ min_samples users:
   a. Compute centroid, mean heading, mean speed
   b. Apply stop-pattern recognition to filter private cars
   c. Run Kalman filter on centroid for smooth position
4. Emit Virtual Beacon objects for confirmed vehicle clusters
5. Match beacon to nearest route via PostGIS (in route_matcher.py)
"""

import numpy as np
from sklearn.cluster import DBSCAN
from datetime import datetime, timedelta
from collections import defaultdict
from typing import Dict, List, Optional, Tuple

from app.models.beacon import GPSPing, VirtualBeacon
from app.clustering.kalman import KalmanTracker
from app.clustering.stop_pattern import StopPatternFilter
from app.clustering.route_matcher import RouteMatcher
from app.config import settings


class VirtualBeaconEngine:
    def __init__(
        self,
        stop_filter: StopPatternFilter,
        route_matcher: Optional[RouteMatcher] = None,
    ):
        self.stop_filter = stop_filter
        self.route_matcher = route_matcher or RouteMatcher()
        self._ping_window: List[GPSPing] = []
        self._active_beacons: Dict[str, VirtualBeacon] = {}
        self._kalman_trackers: Dict[str, KalmanTracker] = {}

    def ingest_ping(self, ping: GPSPing) -> None:
        """Add a GPS ping to the sliding window."""
        cutoff = datetime.utcnow() - timedelta(seconds=settings.dbscan_window_seconds)
        self._ping_window.append(ping)
        # Evict pings outside the window
        self._ping_window = [p for p in self._ping_window if p.ts >= cutoff]

    def cluster(self) -> List[VirtualBeacon]:
        """
        Run DBSCAN on the current ping window and return updated beacon list.
        Called every beacon_publish_interval_seconds by the main loop.
        """
        if len(self._ping_window) < settings.dbscan_min_samples:
            return list(self._active_beacons.values())

        coords = np.array([[p.lat, p.lng] for p in self._ping_window])

        db = DBSCAN(
            eps=settings.dbscan_eps,        # ~30m in degrees
            min_samples=settings.dbscan_min_samples,
            algorithm="ball_tree",
            metric="haversine",             # Great-circle distance
        ).fit(np.radians(coords))           # haversine requires radians

        labels = db.labels_
        unique_labels = set(labels) - {-1}  # -1 = noise (ungrouped pings)

        newly_confirmed: Dict[str, VirtualBeacon] = {}

        for label in unique_labels:
            mask = labels == label
            cluster_pings = [p for p, m in zip(self._ping_window, mask) if m]

            beacon = self._build_beacon(cluster_pings)
            if beacon is None:
                continue  # filtered by stop-pattern (private car)

            # Match to existing beacon or create new
            matched_id = self._match_existing(beacon)
            if matched_id:
                beacon.id = matched_id
                beacon.created_at = self._active_beacons[matched_id].created_at
                # Apply Kalman smoothing
                tracker = self._kalman_trackers.get(matched_id)
                if tracker:
                    beacon.lat, beacon.lng = tracker.update(beacon.lat, beacon.lng)
            else:
                self._kalman_trackers[beacon.id] = KalmanTracker(beacon.lat, beacon.lng)

            newly_confirmed[beacon.id] = beacon

        # Mark beacons not seen in this cycle as stale
        stale_threshold = datetime.utcnow() - timedelta(seconds=settings.beacon_stale_seconds)
        for bid, beacon in list(self._active_beacons.items()):
            if bid not in newly_confirmed and beacon.last_seen < stale_threshold:
                beacon.status = "stale"

        self._active_beacons.update(newly_confirmed)
        return list(self._active_beacons.values())

    def _build_beacon(self, pings: List[GPSPing]) -> Optional[VirtualBeacon]:
        """Build a VirtualBeacon from a cluster of pings. Returns None if filtered."""
        lats = [p.lat for p in pings]
        lngs = [p.lng for p in pings]
        speeds = [p.speed_kmh for p in pings if p.speed_kmh > 0]
        headings = [p.heading_deg for p in pings]
        tokens = list({p.user_token for p in pings})

        centroid_lat = float(np.mean(lats))
        centroid_lng = float(np.mean(lngs))
        mean_speed = float(np.mean(speeds)) if speeds else 0.0
        mean_heading = float(_circular_mean(headings))

        # Speed filter: reject stationary private cars and fast vehicles
        if not (settings.jeepney_min_speed_kmh <= mean_speed <= settings.jeepney_max_speed_kmh):
            return None

        # Stop-pattern filter: must have stopped near ≥2 known stops
        recent_positions = [(p.lat, p.lng) for p in pings[-10:]]  # last 10 pings
        if not self.stop_filter.passes(recent_positions):
            return None

        # Confidence: based on number of contributors and GPS accuracy
        mean_accuracy = float(np.mean([p.accuracy_m for p in pings if p.accuracy_m > 0] or [50]))
        confidence = min(1.0, len(tokens) / 6.0) * max(0.5, 1.0 - mean_accuracy / 100.0)

        route_id = self.route_matcher.match(centroid_lat, centroid_lng)

        return VirtualBeacon(
            route_id=route_id,
            lat=centroid_lat,
            lng=centroid_lng,
            heading_deg=mean_heading,
            speed_kmh=mean_speed,
            occupancy_est=len(tokens),
            confidence=round(confidence, 2),
            contributor_tokens=tokens,
            last_seen=datetime.utcnow(),
        )

    def _match_existing(self, beacon: VirtualBeacon) -> Optional[str]:
        """
        Match a new cluster to an existing beacon by proximity and heading.
        Returns the existing beacon ID if matched, None otherwise.
        """
        for bid, existing in self._active_beacons.items():
            if existing.status != "active":
                continue
            dist = _haversine_m(existing.lat, existing.lng, beacon.lat, beacon.lng)
            heading_diff = abs(existing.heading_deg - beacon.heading_deg) % 360
            heading_diff = min(heading_diff, 360 - heading_diff)
            if dist < 80 and heading_diff < 45:   # 80m, 45° tolerance
                return bid
        return None


def _haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Fast haversine distance in metres."""
    R = 6_371_000
    phi1, phi2 = np.radians(lat1), np.radians(lat2)
    dphi = np.radians(lat2 - lat1)
    dlam = np.radians(lng2 - lng1)
    a = np.sin(dphi / 2) ** 2 + np.cos(phi1) * np.cos(phi2) * np.sin(dlam / 2) ** 2
    return 2 * R * np.arcsin(np.sqrt(a))


def _circular_mean(angles: List[float]) -> float:
    """Mean of circular angles (0–360)."""
    if not angles:
        return 0.0
    sin_sum = sum(np.sin(np.radians(a)) for a in angles)
    cos_sum = sum(np.cos(np.radians(a)) for a in angles)
    return float(np.degrees(np.arctan2(sin_sum, cos_sum)) % 360)
