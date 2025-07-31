#!/bin/env python3
#
# This file is part of harbour-meteoswiss.
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2018-2025 Mirian Margiani

# This script converts locations taken from the official MeteoSwiss app
# for use in the Sailfish app.
#
# Database: https://s3-eu-central-1.amazonaws.com/app-prod-static-fra.meteoswiss-app.ch/v1/db.sqlite

import sqlite3
from pathlib import Path


EXPECTED_DATA_VERSION = "171"


# convert LV03 coordinates to international WGS84 coordinates
# source: https://web.archive.org/web/20220619221858/https://asciich.ch/wordpress/koordinatenumrechner-schweiz-international
# slightly adapted to fit
def swiss2intl(swissNorth, swissEast):
    y = (swissEast - 600000) / 1000000
    x = (swissNorth - 200000) / 1000000

    lam = 2.6779094
    lam += 4.728982 * y
    lam += 0.791484 * y * x
    lam += 0.1306 * y * x * x
    lam -= 0.0436 * y * y * y
    lam *= 100 / 36

    phi = 16.9023892
    phi += 3.238272 * x
    phi -= 0.270978 * y * y
    phi -= 0.002528 * x * x
    phi -= 0.0447 * y * y * x
    phi -= 0.0140 * x * x * x
    phi *= 100 / 36

    return {'latitude': phi, 'longitude': lam}


def convert(source: str) -> int:
    source = Path(source)
    target = Path('locations.db')

    if not source.is_file():
        print(f"error: cannot find input '{source}'")
        return 1

    if target.is_file():
        print(f"error: output file '{target}' already exists")
        return 1

    in_conn = sqlite3.connect(source)
    in_conn.row_factory = sqlite3.Row
    # in_cursor = in_conn.cursor()

    data_version = in_conn.execute("""SELECT version FROM metadata;""").fetchone()['version']

    if data_version != EXPECTED_DATA_VERSION:
        print(f"error: unexpected input data version '{data_version}', expected '{EXPECTED_DATA_VERSION}'")
        print("check the database and make sure everything is ok, then update the script")
        return 255

    locations = in_conn.execute("""
        SELECT
            plz_pk as locationId,
            primary_name as primaryName,
            name,
            SUBSTR(plz_pk, 0, 5) AS zip,
            x,
            y,
            altitude
        FROM plz_names
        INNER JOIN plz ON plz_names.plz = plz.plz_pk
        WHERE plz.active = 1
        ORDER BY locationId ASC
    """).fetchall()

    out_conn = sqlite3.connect(target)
    out_conn.row_factory = sqlite3.Row
    # out_cursor = out_conn.cursor()

    out_conn.execute("""CREATE TABLE IF NOT EXISTS metadata(key TEXT PRIMARY KEY, value TEXT);""")
    out_conn.execute("""CREATE TABLE IF NOT EXISTS locations(
        locationId INTEGER,
        primaryName TEXT,
        name TEXT,
        zip TEXT,
        latitude REAL,
        longitude REAL,
        altitude INTEGER,

        PRIMARY KEY (locationId, name)
    );""")
    out_conn.execute("""INSERT INTO metadata(key, value) VALUES("schema", 1);""")
    out_conn.execute("""INSERT INTO metadata(key, value) VALUES("data", ?);""", [data_version])

    for row in locations:
        # NOTE Swiss coordinates use x = north and y = east but MeteoSwiss's
        # database actually (wrongly) uses x = east and y = north
        # cf. https://de.wikipedia.org/wiki/Schweizer_Landeskoordinaten
        coords = swiss2intl(row['y'], row['x'])

        out_conn.execute("""INSERT INTO locations(
            locationId, primaryName, name, zip, latitude, longitude, altitude
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?
        )""", [
            row['locationId'],
            row['primaryName'],
            row['name'],
            row['zip'],
            coords['latitude'],
            coords['longitude'],
            row['altitude']
        ])

    out_conn.commit()
    out_conn.execute("""VACUUM;""")


if __name__ == "__main__":
    import sys

    ret = convert(sys.argv[1])
    sys.exit(ret)
