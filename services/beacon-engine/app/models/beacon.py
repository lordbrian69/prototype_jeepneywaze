from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional
import uuid


@dataclass
class GPSPing:
    user_token: str
    lat: float
    lng: float
    accuracy_m: float = 0.0
    speed_kmh: float = 0.0
    heading_deg: float = 0.0
    altitude_m: float = 0.0
    is_moving: bool = True
    ts: datetime = field(default_factory=datetime.utcnow)
    source: str = "commuter"  # "commuter" | "driver"


@dataclass
class VirtualBeacon:
    """
    A detected vehicle cluster formed from ≥3 commuter GPS trajectories.
    This is the core output of the DBSCAN engine.
    """
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    route_id: Optional[str] = None
    lat: float = 0.0
    lng: float = 0.0
    heading_deg: float = 0.0
    speed_kmh: float = 0.0
    occupancy_est: int = 0          # number of contributing users
    confidence: float = 0.0         # 0.0–1.0
    contributor_tokens: list = field(default_factory=list)
    last_seen: datetime = field(default_factory=datetime.utcnow)
    created_at: datetime = field(default_factory=datetime.utcnow)
    status: str = "active"          # "active" | "stale" | "terminated"

    def to_redis_dict(self) -> dict:
        return {
            "id": self.id,
            "route_id": self.route_id or "",
            "lat": self.lat,
            "lng": self.lng,
            "heading_deg": self.heading_deg,
            "speed_kmh": self.speed_kmh,
            "occupancy_est": self.occupancy_est,
            "confidence": self.confidence,
            "last_seen": self.last_seen.isoformat(),
            "status": self.status,
        }
