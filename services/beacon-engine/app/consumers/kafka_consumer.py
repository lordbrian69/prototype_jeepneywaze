"""
Kafka consumer: reads GPS pings from gps.pings topic
and feeds them into the VirtualBeaconEngine.
"""

import asyncio
import json
import logging
from datetime import datetime

from kafka import KafkaConsumer
from app.config import settings
from app.models.beacon import GPSPing

logger = logging.getLogger(__name__)


class GPSPingConsumer:
    def __init__(self, ping_callback):
        self._callback = ping_callback
        self._running = False

    def start(self):
        """Start blocking Kafka consumer loop (run in a thread)."""
        consumer = KafkaConsumer(
            settings.kafka_topic_gps_pings,
            bootstrap_servers=settings.kafka_brokers.split(","),
            group_id=settings.kafka_group_id,
            value_deserializer=lambda m: json.loads(m.decode("utf-8")),
            auto_offset_reset="latest",
            enable_auto_commit=True,
        )

        logger.info(f"Kafka consumer started on topic: {settings.kafka_topic_gps_pings}")
        self._running = True

        for message in consumer:
            if not self._running:
                break
            try:
                data = message.value
                ping = GPSPing(
                    user_token=data["user_token"],
                    lat=float(data["lat"]),
                    lng=float(data["lng"]),
                    accuracy_m=float(data.get("accuracy_m", 50)),
                    speed_kmh=float(data.get("speed_kmh", 0)),
                    heading_deg=float(data.get("heading_deg", 0)),
                    is_moving=bool(data.get("is_moving", True)),
                    ts=datetime.fromisoformat(data.get("ts", datetime.utcnow().isoformat())),
                    source=data.get("source", "commuter"),
                )
                self._callback(ping)
            except Exception as e:
                logger.error(f"Failed to process ping: {e}")

        consumer.close()

    def stop(self):
        self._running = False
