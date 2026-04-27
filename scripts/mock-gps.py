#!/usr/bin/env python3
"""
Mock GPS broadcaster for JeepneyWaze Virtual Beacon testing.

Simulates multiple commuters on a jeepney route by replaying
recorded GPS trajectories at configurable speed.

Usage:
  python mock-gps.py --route edsa-cubao-quiapo --users 5 --speed 1x
  python mock-gps.py --route edsa-cubao-quiapo --users 10 --speed 2x

This creates realistic Virtual Beacon conditions:
- N users clustered within 30m of each other
- Moving at jeepney speed (15-40 km/h)
- Stopping at known stop locations

Useful for testing beacon formation without real commuters.
"""

import argparse
import json
import math
import random
import time
import threading
import uuid
import paho.mqtt.client as mqtt
from datetime import datetime

# ── Pilot route: EDSA Cubao → Quiapo ─────────────────────────────────
# Approximate GPS waypoints along the route
ROUTES = {
    "edsa-cubao-quiapo": {
        "name": "EDSA Cubao to Quiapo",
        "waypoints": [
            # (lat, lng, stop=True/False)
            (14.6194, 121.0567, True),   # Cubao - START
            (14.6180, 121.0550, False),
            (14.6165, 121.0530, False),
            (14.6150, 121.0510, True),   # Stop: Aurora Blvd
            (14.6130, 121.0490, False),
            (14.6110, 121.0470, False),
            (14.6090, 121.0450, True),   # Stop: Anonas
            (14.6070, 121.0430, False),
            (14.6050, 121.0410, False),
            (14.6020, 121.0380, True),   # Stop: Santolan
            (14.5990, 121.0350, False),
            (14.5960, 121.0320, False),
            (14.5930, 121.0290, True),   # Stop: España
            (14.5900, 121.0260, False),
            (14.5870, 121.0230, True),   # Stop: Quiapo Church
            (14.5851, 121.0200, True),   # Quiapo - END
        ],
        "avg_speed_kmh": 22,
        "stop_dwell_sec": 8,
    }
}


def add_gps_noise(lat: float, lng: float, accuracy_m: float = 15) -> tuple:
    """Add realistic GPS noise within accuracy_m radius."""
    # 1 degree ≈ 111,000m
    noise = accuracy_m / 111_000
    return (
        lat + random.gauss(0, noise),
        lng + random.gauss(0, noise)
    )


def simulate_commuter(client: mqtt.Client, user_token: str,
                      waypoints: list, avg_speed: float,
                      stop_dwell: float, speed_multiplier: float,
                      offset_seconds: float):
    """Simulate one commuter following a route."""
    time.sleep(offset_seconds)  # Stagger commuters

    for i, (lat, lng, is_stop) in enumerate(waypoints):
        if i == 0:
            continue

        prev_lat, prev_lng, _ = waypoints[i - 1]

        # Distance between waypoints
        dlat = lat - prev_lat
        dlng = lng - prev_lng
        dist_deg = math.sqrt(dlat**2 + dlng**2)
        dist_m = dist_deg * 111_000
        heading = math.degrees(math.atan2(dlng, dlat)) % 360

        # Time to traverse this segment
        speed_ms = (avg_speed * 1000 / 3600) * speed_multiplier
        travel_time = dist_m / speed_ms if speed_ms > 0 else 10
        steps = max(1, int(travel_time / 5))  # One ping every 5 seconds

        for step in range(steps):
            progress = step / steps
            current_lat = prev_lat + dlat * progress
            current_lng = prev_lng + dlng * progress
            noisy_lat, noisy_lng = add_gps_noise(current_lat, current_lng)

            ping = {
                "user_token": user_token,
                "lat": round(noisy_lat, 7),
                "lng": round(noisy_lng, 7),
                "accuracy_m": random.uniform(5, 25),
                "speed_kmh": avg_speed + random.gauss(0, 3),
                "heading_deg": heading,
                "is_moving": True,
                "ts": datetime.utcnow().isoformat(),
                "source": "commuter",
            }

            topic = f"jw/gps/{user_token}"
            client.publish(topic, json.dumps(ping), qos=0)
            time.sleep(5 / speed_multiplier)

        # Dwell at stops
        if is_stop:
            dwell = stop_dwell / speed_multiplier
            for _ in range(int(dwell / 5)):
                noisy_lat, noisy_lng = add_gps_noise(lat, lng, 10)
                ping = {
                    "user_token": user_token,
                    "lat": round(noisy_lat, 7),
                    "lng": round(noisy_lng, 7),
                    "accuracy_m": random.uniform(5, 15),
                    "speed_kmh": 0,
                    "heading_deg": heading,
                    "is_moving": False,
                    "ts": datetime.utcnow().isoformat(),
                    "source": "commuter",
                }
                client.publish(f"jw/gps/{user_token}", json.dumps(ping), qos=0)
                time.sleep(5 / speed_multiplier)


def main():
    parser = argparse.ArgumentParser(description="JeepneyWaze Mock GPS Broadcaster")
    parser.add_argument("--route", default="edsa-cubao-quiapo")
    parser.add_argument("--users", type=int, default=5,
                        help="Number of simulated commuters on the jeepney")
    parser.add_argument("--speed", default="1x",
                        help="Replay speed multiplier (1x, 2x, 5x)")
    parser.add_argument("--mqtt-host", default="localhost")
    parser.add_argument("--mqtt-port", type=int, default=1883)
    args = parser.parse_args()

    speed_multiplier = float(args.speed.replace("x", ""))
    route = ROUTES.get(args.route)
    if not route:
        print(f"Unknown route: {args.route}. Available: {list(ROUTES.keys())}")
        return

    print(f"🚌 Simulating {args.users} commuters on '{route['name']}' at {args.speed}")

    client = mqtt.Client(client_id=f"mock-gps-{uuid.uuid4().hex[:8]}")
    client.connect(args.mqtt_host, args.mqtt_port, 60)
    client.loop_start()

    threads = []
    for i in range(args.users):
        token = f"mock_{uuid.uuid4().hex[:16]}"
        # Stagger commuters by 0-60 seconds to simulate different boarding times
        offset = random.uniform(0, 60 / speed_multiplier)
        t = threading.Thread(
            target=simulate_commuter,
            args=(client, token, route["waypoints"], route["avg_speed_kmh"],
                  route["stop_dwell_sec"], speed_multiplier, offset),
            daemon=True
        )
        t.start()
        threads.append(t)
        print(f"  Started commuter {i+1}/{args.users}: {token}")

    print("\n✅ All commuters running. Press Ctrl+C to stop.")
    try:
        for t in threads:
            t.join()
    except KeyboardInterrupt:
        print("\n⛔ Stopped.")
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
