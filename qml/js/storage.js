/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
 */

.pragma library
.import "../modules/Opal/LocalStorage/StorageHelper.js" as DB

//
// BEGIN Startup configuration
//

function setMaintenanceSignals(start, end) {
    DB.maintenanceStartSignal = start
    DB.maintenanceEndSignal = end
}

//
// BEGIN Database configuration
//

function dbOk() { return DB.dbOk }
var isSameValue = DB.isSameValue

DB.dbName = "harbour-meteoswiss"
DB.dbDescription = "Swiss Meteo Offline Cache"
DB.dbSize = 2000000
DB.enableAutoMaintenance = true
DB.maintenanceCallback = function(){
    pruneOldData(-1)
}

DB.dbMigrations = [
    // Database versions do not correspond to app versions.
    [2.0, function(tx){
        // Version 2.0 is the first version. Subsequent versions use integer
        // version numbers only.
        tx.executeSql('\
            CREATE TABLE IF NOT EXISTS data(
                timestamp INTEGER NOT NULL,
                location_id INTEGER NOT NULL,
                data TEXT NOT NULL,
                day_count INTEGER NOT NULL,
                day_dates TEXT NOT NULL,

                PRIMARY KEY(timestamp, location_id)
        );')
        tx.executeSql('\
            CREATE TABLE IF NOT EXISTS data_overview(
                datestring STRING NOT NULL,
                location_id INTEGER NOT NULL,
                symbol INTEGER NOT NULL,
                precipitation INTEGER NOT NULL,
                temp_max INTEGER NOT NULL,
                temp_min INTEGER NOT NULL,
                age INTEGER NOT NULL,

                PRIMARY KEY(datestring, location_id)
        );')
        tx.executeSql('\
            CREATE TABLE IF NOT EXISTS locations(
                location_id INTEGER NOT NULL PRIMARY KEY,
                zip INTEGER NOT NULL,
                name TEXT NOT NULL,
                cantonId TEXT NOT NULL,
                canton TEXT NOT NULL,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                altitude INTEGER NOT NULL,
                view_position INTEGER NOT NULL
        );')
        tx.executeSql('\
            CREATE TABLE IF NOT EXISTS settings(
                setting TEXT NOT NULL PRIMARY KEY,
                value TEXT
        );')
    }],
    [3, function(tx){
        // Store raw data
        tx.executeSql('\
            ALTER TABLE data
            ADD COLUMN raw_data TEXT DEFAULT ""
        ;')

        // Mark broken locations as disabled
        tx.executeSql('\
            ALTER TABLE locations
            ADD COLUMN active BOOLEAN DEFAULT TRUE
        ;')
        tx.executeSql('\
            UPDATE locations
            SET active = TRUE
        ')

        // Handle settings through Opal.LocalStorage
        tx.executeSql('\
            CREATE TABLE IF NOT EXISTS settings(
                setting TEXT UNIQUE, value TEXT
        );')

        tx.executeSql('DROP TABLE IF EXISTS %1;'.arg(DB.settingsTable))
        DB.createSettingsTable(tx)

        tx.executeSql('INSERT INTO %1(key, value) \
            SELECT setting, value FROM settings;'.arg(DB.settingsTable))
        tx.executeSql('DROP TABLE settings;')

        // Drop all cached data to force a full refresh
        // because the internal data structure has changed
        tx.executeSql('DELETE FROM data;')
        tx.executeSql('DELETE FROM data_overview;')
        tx.executeSql('DELETE FROM %1 WHERE key = "last_maintenance";'.arg(DB.settingsTable))
    }],

    // add new versions here...
    //
    // remember: versions must be numeric, e.g. 0.1 but not 0.1.1
    // note: this app uses integer version numbers since db version 3
]


//
// BEGIN App database functions
//

var defaultFor = DB.defaultFor
var getDatabase = DB.getDatabase

function simpleQuery(query, values, getSelectedCount) {
    var res = DB.simpleQuery(query, values, false)

    if (res.ok === false) {
        return undefined
    } else if (getSelectedCount) {
        return res.rows.length
    } else {
        return res.rowsAffected
    }
}

function pruneOldData(locationId) {
    var q

    if (locationId < 0) {
        q = DB.simpleQuery('\
            DELETE FROM data
            WHERE (
                (timestamp <= strftime("%s", "now", "-14 day")*1000)
                OR (location_id NOT IN (SELECT location_id FROM locations))
            )
        ;')
        console.log("pruned %1 data entries for all locations".arg(q.rowsAffected))

        DB.simpleQuery('\
            DELETE FROM data_overview
            WHERE (
                (datestring <= date("now", "-14 day"))
                OR (location_id NOT IN (SELECT location_id FROM locations))
            )
        ;')
        console.log("pruned %1 overview entries for all locations".arg(q.rowsAffected))
    } else if (!!locationId) {
        q = DB.simpleQuery('\
            DELETE FROM data
            WHERE (
                (location_id = ? AND timestamp <= strftime("%s", "now", "-14 day")*1000)
                OR (location_id NOT IN (SELECT location_id FROM locations))
            )
        ;', [locationId])
        console.log("pruned %1 data entries for %2".arg(q.rowsAffected).arg(locationId))

        DB.simpleQuery('\
            DELETE FROM data_overview
            WHERE (
                (location_id = ? AND datestring <= date("now", "-14 day"))
                OR (location_id NOT IN (SELECT location_id FROM locations))
            )
        ;', [locationId])
        console.log("pruned %1 overview entries for %2".arg(q.rowsAffected).arg(locationId))
    }
}

function addLocation(locationData, viewPosition) {
    var id = defaultFor(locationData.locationId, null);
    var alt = defaultFor(locationData.altitude, 0);
    var lat = defaultFor(locationData.latitude, 0);
    var long = defaultFor(locationData.longitude, 0);
    var zip = defaultFor(locationData.zip, null);
    var canId = defaultFor(locationData.cantonId, null);
    var can = defaultFor(locationData.canton, null);
    var name = defaultFor(locationData.name, null);

    var res = simpleQuery('INSERT OR IGNORE INTO locations VALUES (?,?,?,?,?,?,?,?,?, ?);', [id, zip, name, canId, can, lat, long, alt, viewPosition, true]);

    if (res !== 0 && !res) {
        console.log("error: failed to save location " + id + " to db");
    }

    return res;
}

function removeLocation(locationId) {
    var res = simpleQuery('DELETE FROM locations WHERE location_id=?;', [locationId]);

    if (!res) {
        console.log("error: failed to remove location " + locationId + " from db");
    }

    return res;
}

function disableLocation(locationId) {
    simpleQuery('\
        UPDATE locations
        SET active = FALSE
        WHERE location_id = ?
    ;', [locationId])
}

function getCoverLocation() {
    return DB.getSetting("cover_location", 0)
}

function getNextCoverLocation(locationId) {
    var q = DB.simpleQuery('\
        SELECT location_id FROM locations
        WHERE location_id > ? AND active = TRUE
        ORDER BY location_id ASC
        LIMIT 1
    ;', [locationId])

    if (q.rows.length === 0) {
        q = DB.simpleQuery('\
            SELECT location_id FROM locations
            WHERE active = TRUE
            ORDER BY location_id ASC
            LIMIT 1
        ;')

        if (q.rows.length === 0) {
            console.log("failed to get next cover location: no locations available")
            return 0
        }
    }

    return q.rows.item(0).location_id
}

function setCoverLocation(locationId) {
    DB.setSetting("cover_location", locationId)
}

function getActiveLocationsList() {
    var q = DB.simpleQuery('\
        SELECT location_id FROM locations
        WHERE active = TRUE
        ORDER BY view_position ASC
    ;', [])

    var ret = []

    for (var i = 0; i < q.rows.length; ++i) {
        ret.push(q.rows.item(i).location_id)
    }

    return ret
}

function getLocationsList() {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations ORDER BY view_position ASC;', []);

            for (var i = 0; i < rs.rows.length; i++) {
                res.push(rs.rows.item(i).location_id);
            }
        });
    } catch(e) {
        console.log("error while loading locations list")
    }

    return res;
}

function getLocationsCount() {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations;', []);
            res = rs.rows.length;
        });
    } catch(e) {
        console.log("error while loading locations count")
    }

    return res;
}

function getLocationData(locationId) {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            var rs = undefined;

            if (locationId) {
                rs = tx.executeSql('SELECT * FROM locations WHERE location_id=?;', [locationId]);
            } else {
                rs = tx.executeSql('SELECT * FROM locations ORDER BY view_position ASC;');
            }

            for (var i = 0; i < rs.rows.length; i++) {
                res.push({
                    locationId: rs.rows.item(i).location_id,
                    altitude: rs.rows.item(i).altitude,
                    latitude: rs.rows.item(i).latitude,
                    longitude: rs.rows.item(i).longitude,
                    zip: rs.rows.item(i).zip,
                    name: rs.rows.item(i).name,
                    cantonId: rs.rows.item(i).cantonId,
                    canton: rs.rows.item(i).canton,
                    viewPosition: rs.rows.item(i).view_position,
                    active: rs.rows.item(i).active === 1,
                });
            }
        });
    } catch(e) {
        console.log("error while loading locations data for " + locationId)
        return [];
    }

    return res;
}

function setOverviewPositions(dataPairs) {
    var db = getDatabase();
    var res = 0;
    dataPairs = defaultFor(dataPairs, []);

    try {
        db.transaction(function(tx) {
            for (var i = 0; i < dataPairs.length; i++) {
                var rs = tx.executeSql('UPDATE locations SET view_position=? WHERE location_id=?;', [dataPairs[i].viewPosition, dataPairs[i].locationId]);

                if (rs.rowsAffected !== 1) {
                    console.log("error: failed to update view position for " + dataPairs[i].locationId);
                } else {
                    res += 1;
                }
            }
        });
    } catch(e) {
        console.log("error in query:", dataPairs);
        res = undefined;
    }

    if (res !== dataPairs.length) {
        console.log("error: failed to save overview positions (" + (res ? res : 0) + "/" + dataPairs.length + " ok)");
    }

    return res;
}

function getHourSymbolFor(hour) {
    if (!hour) {
        hour = 23;
    }

    if (hour == 0) {
        hour = 23;
    } else {
        if ((hour+1) % 3 == 1) {
            hour -= 1;
        } else if ((hour+1) % 3 == 2) {
            hour += 1;
        }
    }

    return hour;
}

function getCurrentSymbolHour() {
    // find nearest available symbol:
    // There are symbols every 3 hours, starting at 2am and ending at 11pm.
    // If the current hour is 0 (= 12pm), set it to 11pm for the symbol (= 23).
    // Else if the current hour modulus 3 is 1, set it to the previous hour.
    // If it is 2, get the symbol of the next hour.

    var now = new Date();
    var hour = now.getHours();

    if (now.getMinutes() > 30) {
        hour += 1;
    }

    return getHourSymbolFor(hour);
}

function setDaySummary(locationId, dayString, symbol, precipitation, tempMin, tempMax) {
    var res = simpleQuery('INSERT OR REPLACE INTO data_overview VALUES (?,?,?,?,?,?,?);', [
        dayString, locationId, symbol, precipitation, tempMax, tempMin, Date.now()
    ]);

    if (!res) {
        console.log("error: failed to save day summary data for " + locationId + " to db");
    }

    return res;
}

function getDaySummaryAge() {
    var q = DB.simpleQuery("\
        SELECT age FROM data_overview
        ORDER BY age DESC
        LIMIT 1
    ;", [])

    var ret = new Date(0)

    if (q.rows.length > 0) {
        ret.setTime(q.rows.item(0).age)
    }

    return ret
}

function getDaySummary(locationId, dayDate, dayId) {
    var res = {
        symbol: 0,
        minTemp: undefined,
        maxTemp: undefined,
        precipitation: undefined,
    };

    if (locationId === undefined || dayDate === undefined) return res;

    var db = getDatabase();

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM data_overview WHERE location_id=? AND datestring=? LIMIT 1;',
                                   [locationId, dayDate.toLocaleString(Qt.locale(), "yyyy-MM-dd")]);

            if (rs.rows.length > 0) {
                res.symbol = rs.rows.item(0).symbol;
                res.precipitation = rs.rows.item(0).precipitation;
                res.maxTemp = rs.rows.item(0).temp_max;
                res.minTemp = rs.rows.item(0).temp_min;
            } else {
                console.log("error while loading day overview: no data");

                if (dayId === undefined) {
                    console.log("cannot generate day overview: day id is missing")
                } else {
                    res = getGeneratedDaySummary(locationId, dayId)
                }
            }
        });
    } catch(e) {
        console.log("error while loading day summary data: locationId=" + locationId + " date=" + dayDate.toLocaleString(Qt.locale(), "yyyy-MM-dd"));
    }

    return res;
}

function getGeneratedDaySummary(locationId, dayId) {
    var res = {
        symbol: 0,
        minTemp: undefined,
        maxTemp: undefined,
        precipitation: undefined,
    };

    if (locationId == undefined || dayId == undefined) return res;

    var data = getData(locationId, true);
    data = data.length > 0 ? data[0] : undefined;

    if (!data) {
        console.log("error: failed to get data to generate summary for", locationId)
        return res;
    }

    var full = JSON.parse(data.data)[dayId];
    res.maxTemp = Math.max.apply(Math, full.temperature.datasets[0].data);
    res.minTemp = Math.min.apply(Math, full.temperature.datasets[0].data);
    res.precipitation = Math.round(full.rainfall.datasets[0].data.reduce(function(acc, val) { return acc + val; }, 0)*10)/10;
    res.symbol = full.temperature.datasets[0].symbols[getHourSymbolFor(12)];

    return res;
}

function getDataSummary(locationId) {
    var res = {
        locationId: locationId,
        symbol: 0,
        temp: undefined,
        rain: undefined,
    };

    if (locationId === 0) {
        return res;
    }

    var data = getData(locationId, true);
    data = data.length > 0 ? data[0] : undefined;

    if (!data) {
        console.log("error: failed to get data summary for", locationId)
        return res;
    }

    var ts = new Date(data.timestamp);
    var now = new Date();

    if (ts.toDateString() != now.toDateString()) {
        console.log("error: no cached data from today available");
        return res;
    }

    var hour = now.getHours();
    var minutes = now.getMinutes();

    if (minutes > 30) {
        hour += 1;
    }

    var full = JSON.parse(data.data);

    if (full[0].isSane) {
        res.temp = full[0].temperature.datasets[0].data[hour]
        res.rain = full[0].rainfall.datasets[0].data[hour]
        res.symbol = full[0].temperature.datasets[0].symbols[getCurrentSymbolHour()]
    }

    return res;
}

function setData(timestamp, locationId, data, rawData) {
    var times = []

    if (data.length >= 1 && data[0].isSane === true) {
        for (var i = 0; i < data.length; i++) {
            times.push(data[i].date);
        }
    }

    var res = simpleQuery('INSERT OR REPLACE INTO data VALUES (?,?,?,?,?, ?);', [
        timestamp, locationId, JSON.stringify(data),
        times.length, JSON.stringify(times), rawData
    ]);

    if (!res) {
        console.log("error: failed to save data for " + locationId + " to db");
    } else {
        pruneOldData(locationId);
    }

    return res;
}

function getLatestMetadata(locationId) {
    var db = getDatabase();
    var res = {
        locationId: locationId,
        timestamp: 0,
        dayCount: 0,
        dayDates: []
    };

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM data WHERE location_id=? AND timestamp>=? ORDER BY timestamp DESC LIMIT 1;', [locationId, 0]);

            if (rs.rows && rs.rows.length == 0) {
                console.log("failed loading metadata: no data available for " + locationId);
            } else {
                res.timestamp = rs.rows.item(0).timestamp
                res.dayCount  = rs.rows.item(0).day_count
                res.dayDates  = JSON.parse(rs.rows.item(0).day_dates)
            }
        });
    } catch(e) {
        console.log("error while loading latest metadata: locationId=" + locationId);
        return res;
    }

    return res;
}

function getData(locationId, mostRecent, newerThan) {
    var db = getDatabase();
    var res = [];

    newerThan = defaultFor(newerThan, 0);
    mostRecent = defaultFor(mostRecent, true);

    try {
        db.transaction(function(tx) {
            var limit = ";"
            if (mostRecent) limit = " LIMIT 1;"
            var rs = tx.executeSql('SELECT * FROM data WHERE location_id=? AND timestamp>=? ORDER BY timestamp DESC' + limit, [locationId, newerThan]);

            for (var i = 0; i < rs.rows.length; i++) {
                res.push({
                    locationId: rs.rows.item(i).location_id,
                    timestamp: rs.rows.item(i).timestamp,
                    data: rs.rows.item(i).data,
                    dayCount: rs.rows.item(i).day_count,
                    dayDates: rs.rows.item(i).day_dates,
                    rawData: rs.rows.item(i).raw_data,
                });

                if (mostRecent) break;
            }
        });
    } catch(e) {
        console.log("error while loading data: locationId=" + locationId + " newerThan=" + newerThan);
        return [];
    }

    return res;
}
