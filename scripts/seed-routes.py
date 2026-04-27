#!/usr/bin/env python3
"""
Seed Phase 1 pilot route and stop data into PostgreSQL.

Pilot routes:
  1. Metro Manila: EDSA Cubao → Quiapo (MNL-CUB-QUI)
  2. Cebu: Colon Street → SM City Cebu (CEB-COL-SM)

Usage:
  python seed-routes.py
  python seed-routes.py --db-url postgresql://jeepney:pass@localhost/jeepneywaze
"""

import argparse
import os
from pathlib import Path

import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

# Load .env from the project root regardless of CWD.
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

PILOT_ROUTES = [
    {
        "code": "MNL-CUB-QUI",
        "name": "Cubao to Quiapo (EDSA)",
        "name_tl": "Cubao hanggang Quiapo",
        "name_ceb": None,
        "vehicle_type": "jeepney",
        "fare_base": 13.00,
        "fare_per_km": 1.80,
        "stops": [
            {"seq": 1,  "name": "Cubao Terminal",        "name_tl": "Terminal ng Cubao",       "lat": 14.6194, "lng": 121.0567, "landmark": "Araneta Center"},
            {"seq": 2,  "name": "Aurora Blvd",            "name_tl": "Aurora Boulevard",         "lat": 14.6150, "lng": 121.0510, "landmark": "St. Luke's Hospital"},
            {"seq": 3,  "name": "Anonas",                 "name_tl": "Anonas",                   "lat": 14.6090, "lng": 121.0450, "landmark": "Jollibee Anonas"},
            {"seq": 4,  "name": "Santolan",               "name_tl": "Santolan",                 "lat": 14.6020, "lng": 121.0380, "landmark": "Santolan LRT"},
            {"seq": 5,  "name": "España",                 "name_tl": "España Boulevard",         "lat": 14.5930, "lng": 121.0290, "landmark": "University of Santo Tomas"},
            {"seq": 6,  "name": "Lacson",                 "name_tl": "Lacson Avenue",             "lat": 14.5900, "lng": 121.0260, "landmark": "Philippine General Hospital"},
            {"seq": 7,  "name": "Quiapo Church",          "name_tl": "Simbahan ng Quiapo",       "lat": 14.5870, "lng": 121.0230, "landmark": "Minor Basilica of the Black Nazarene"},
            {"seq": 8,  "name": "Quiapo Terminal",        "name_tl": "Terminal ng Quiapo",       "lat": 14.5851, "lng": 121.0200, "landmark": "Carriedo LRT Station"},
        ]
    },
    {
        "code": "CEB-COL-SM",
        "name": "Colon Street to SM City Cebu",
        "name_tl": None,
        "name_ceb": "Colon ngadto sa SM City",
        "vehicle_type": "jeepney",
        "fare_base": 13.00,
        "fare_per_km": 1.80,
        "stops": [
            {"seq": 1, "name": "Colon Street",     "name_tl": None, "lat": 10.2959, "lng": 123.8986, "landmark": "Oldest Street in the Philippines"},
            {"seq": 2, "name": "Carbon Market",    "name_tl": None, "lat": 10.2970, "lng": 123.8960, "landmark": "Carbon Public Market"},
            {"seq": 3, "name": "Fuente Osmeña",    "name_tl": None, "lat": 10.3056, "lng": 123.8917, "landmark": "Fuente Osmeña Circle"},
            {"seq": 4, "name": "Ayala Center",     "name_tl": None, "lat": 10.3175, "lng": 123.9050, "landmark": "Ayala Center Cebu"},
            {"seq": 5, "name": "SM City Cebu",     "name_tl": None, "lat": 10.3110, "lng": 123.9175, "landmark": "SM City Cebu North Wing"},
        ]
    }
]


def seed(db_url: str):
    conn = psycopg2.connect(db_url)
    conn.autocommit = False

    try:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            for route in PILOT_ROUTES:
                # Upsert route
                cur.execute(
                    """INSERT INTO routes (code, name, name_tl, name_ceb, vehicle_type, fare_base, fare_per_km)
                       VALUES (%(code)s, %(name)s, %(name_tl)s, %(name_ceb)s, %(vehicle_type)s, %(fare_base)s, %(fare_per_km)s)
                       ON CONFLICT (code) DO UPDATE SET
                         name=EXCLUDED.name, name_tl=EXCLUDED.name_tl,
                         name_ceb=EXCLUDED.name_ceb, fare_base=EXCLUDED.fare_base
                       RETURNING id""",
                    route
                )
                route_id = cur.fetchone()["id"]
                print(f"✅ Route: {route['code']} → {route_id}")

                # Delete existing stops (reseed clean)
                cur.execute("DELETE FROM stops WHERE route_id = %s", (route_id,))

                # Insert stops
                for stop in route["stops"]:
                    cur.execute(
                        """INSERT INTO stops (route_id, sequence, name, name_tl, landmark, geom, radius_m)
                           VALUES (%s, %s, %s, %s, %s,
                             ST_SetSRID(ST_MakePoint(%s, %s), 4326),
                             40)""",
                        (route_id, stop["seq"], stop["name"], stop.get("name_tl"),
                         stop.get("landmark"), stop["lng"], stop["lat"])
                    )
                    print(f"   Stop {stop['seq']}: {stop['name']}")

        conn.commit()
        print("\n🎉 Seeding complete!")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        conn.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--db-url",
        default=f"postgresql://{os.getenv('POSTGRES_USER','jeepney')}:{os.getenv('POSTGRES_PASSWORD','jeepney_dev_pass')}@{os.getenv('POSTGRES_HOST','localhost')}/{os.getenv('POSTGRES_DB','jeepneywaze')}"
    )
    args = parser.parse_args()
    seed(args.db_url)


if __name__ == "__main__":
    main()
