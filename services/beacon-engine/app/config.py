from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    postgres_db: str = "jeepneywaze"
    postgres_user: str = "jeepney"
    postgres_password: str = "jeepney_dev_pass"

    redis_url: str = "redis://localhost:6379"

    kafka_brokers: str = "localhost:9092"
    kafka_topic_gps_pings: str = "gps.pings"
    kafka_topic_beacons: str = "beacons.detected"
    kafka_group_id: str = "beacon-engine"

    # DBSCAN parameters (jeepney mode)
    dbscan_eps: float = 0.0003          # ~30m radius in degrees
    dbscan_min_samples: int = 3          # ≥3 users = candidate vehicle
    dbscan_window_seconds: int = 30      # sliding window for clustering

    # Vehicle filter thresholds (jeepney)
    jeepney_min_speed_kmh: float = 2.0
    jeepney_max_speed_kmh: float = 65.0
    stop_match_radius_m: float = 40.0
    min_stops_to_confirm: int = 2        # must match ≥2 stops to be a beacon

    # Beacon lifecycle
    beacon_stale_seconds: int = 90       # mark beacon stale after 90s without pings
    beacon_publish_interval_seconds: float = 5.0

    # Kalman filter
    kalman_process_noise: float = 0.01
    kalman_measurement_noise: float = 0.1

    beacon_engine_port: int = 8001

    class Config:
        # Env vars from the container take precedence; .env is a dev fallback only.
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"

settings = Settings()
