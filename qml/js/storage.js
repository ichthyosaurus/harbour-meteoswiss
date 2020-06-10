/*
 * This file is part of harbour-meteoswiss.
 * Copyright (C) 2018-2019  Mirian Margiani
 *
 * harbour-meteoswiss is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-meteoswiss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

.pragma library
.import QtQuick.LocalStorage 2.0 as LS


function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

var initialized = false

function getDatabase() {
    var db = LS.LocalStorage.openDatabaseSync("harbour-meteoswiss", "2.0", "MeteoSwiss Offline Cache", 1000000);

    if (!initialized) {
        initialized = true;
        doInit(db);
    }

    return db;
}

function doInit(db) {
    // Database tables: (primary key in all-caps)
    // data: TIMESTAMP, LOCATION_ID, data (converted), day_count, day_dates
    // data_overview: DATESTRING, LOCATION_ID, symbol, precipitation, temp_max, temp_min, age
    // locations: LOCATION_ID, zip, name, cantonId, canton, latitude, longitude, altitude, view_position
    // settings: SETTING, value

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS data(\
            timestamp INTEGER NOT NULL, location_id INTEGER NOT NULL, data TEXT NOT NULL,\
            day_count INTEGER NOT NULL, day_dates TEXT NOT NULL, PRIMARY KEY(timestamp, location_id))');

        tx.executeSql('CREATE TABLE IF NOT EXISTS data_overview(\
            datestring STRING NOT NULL, location_id INTEGER NOT NULL, symbol INTEGER NOT NULL,\
            precipitation INTEGER NOT NULL, temp_max INTEGER NOT NULL, temp_min INTEGER NOT NULL,\
            age INTEGER NOT NULL, PRIMARY KEY(datestring, location_id))');

        tx.executeSql('CREATE TABLE IF NOT EXISTS locations(\
            location_id INTEGER NOT NULL PRIMARY KEY, zip INTEGER NOT NULL, name TEXT NOT NULL,\
            cantonId TEXT NOT NULL, canton TEXT NOT NULL,\
            latitude REAL NOT NULL, longitude REAL NOT NULL, altitude INTEGER NOT NULL, view_position INTEGER NOT NULL)');

        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT NOT NULL PRIMARY KEY, value TEXT)');
    });
}

function simpleQuery(query, values, getSelectedCount) {
    var db = getDatabase();
    var res = undefined;
    values = defaultFor(values, []);

    if (!query) {
        console.log("error: empty query");
        return undefined;
    }

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql(query, values);

            if (rs.rowsAffected > 0) {
                res = rs.rowsAffected;
            } else {
                res = 0;
            }

            if (getSelectedCount === true) {
                res = rs.rows.length;
            }
        });
    } catch(e) {
        console.log("error in query: '"+ e +"', values=", values);
        res = undefined;
    }

    return res;
}

function pruneOldData(locationId, allAtOnce) {
    if (!locationId && !allAtOnce) return;
    var res;

    if (allAtOnce === true) {
        var res1 = simpleQuery('DELETE FROM data WHERE rowid IN (SELECT rowid FROM data WHERE\
            (timestamp <= strftime("%s", "now", "-14 day")*1000) OR\
            (location_id NOT IN (SELECT location_id FROM locations))\
            ORDER BY rowid ASC\
        );');

        var res2 = simpleQuery('DELETE FROM data_overview WHERE rowid IN (SELECT rowid FROM data_overview WHERE\
            (datestring <= date("now", "-14 day")) OR\
            (location_id NOT IN (SELECT location_id FROM locations))\
            ORDER BY rowid ASC\
        );');

        if (res1 === undefined && res2 === undefined) res = undefined;
        else if (res1 === undefined) res1 = 0;
        else if (res2 === undefined) res2 = 0;
        if (res !== undefined) res = res1 + res2;
    } else {
        res = simpleQuery('DELETE FROM data WHERE rowid IN (SELECT rowid FROM data WHERE\
            (location_id=? AND timestamp <= strftime("%s", "now", "-14 day")*1000) OR\
            (location_id NOT IN (SELECT location_id FROM locations))\
            ORDER BY rowid ASC\
            LIMIT 100\
        );', [locationId]);
    }

    if (res === undefined) {
        console.log("error: failed to prune old data for " + locationId);
    } else if (res > 0) {
        console.log("pruned " + res + " old entries for " + locationId);
    }
}

function vacuumDatabase() {
    var db = getDatabase();

    try {
        db.transaction(function(tx) {
            // VACUUM cannot be executed inside a transaction, but the LocalStorage
            // module cannot execute queries without one. Thus we have to manually
            // end the transaction from inside the transaction...
            var rs = tx.executeSql("END TRANSACTION;");
            var rs2 = tx.executeSql("VACUUM;");
        });
    } catch(e) {
        console.log("error in query: '"+ e);
    }
}

function dbNeedsMaintenance() {
    var last_maintenance = simpleQuery('SELECT * FROM settings WHERE setting="last_maintenance" AND value >= date("now", "-60 day") LIMIT 1;', [], true);

    if (last_maintenance > 0) {
        return false;
    }

    return true;
}

function doDatabaseMaintenance() {
    pruneOldData(0, true);
    vacuumDatabase();
    simpleQuery('INSERT OR REPLACE INTO settings VALUES (?,?);', ["last_maintenance", new Date().toISOString()]);
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

    var res = simpleQuery('INSERT OR IGNORE INTO locations VALUES (?,?,?,?,?,?,?,?,?);', [id, zip, name, canId, can, lat, long, alt, viewPosition]);

    if (res !== 0 && !res) {
        console.log("error: failed to save location " + locationId + " to db");
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

function getCoverLocation() {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM settings WHERE setting="cover_location" LIMIT 1;');

            if (rs.rows.length > 0) {
                res = parseInt(rs.rows.item(0).value, 10);
            } else {
                res = 0;
            }
        });
    } catch(e) {
        console.log("error while loading cover location data");
        return 0;
    }

    return res;
}

function getNextCoverLocation(locationId) {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations WHERE location_id > ? ORDER BY location_id LIMIT 1;', [locationId]);

            if (rs.rows.length === 0) {
                rs = tx.executeSql('SELECT * FROM locations ORDER BY location_id LIMIT 1;');

                if (rs.rows.length === 0) {
                    res = 0;
                    console.log("failed to get next cover location: no locations available");
                    return res;
                }
            }

            res = rs.rows.item(0).location_id;
        });
    } catch(e) {
        console.log("error while loading next cover location");
        return 0;
    }

    return res;
}

function setCoverLocation(locationId) {
    var db = getDatabase();
    var res = undefined;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', ['cover_location', locationId]);

            if (rs.rowsAffected > 0) {
                res = rs.rowsAffected;
            } else {
                res = 0;
            }
        });
    } catch(e) {
        console.log("error in query:", values)
        res = undefined;
    }

    if (res !== 0 && !res) {
        console.log("error: failed to save cover settings")
    }

    return res;
}

function getLocationsList() {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations;', []);

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
    var db = getDatabase();
    var res = new Date(0);

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM data_overview ORDER BY age DESC LIMIT 1;', []);

            if (rs.rows.length > 0) {
                res.setTime(rs.rows.item(0).age);
            } else {
                res.setTime(0);
            }
        });
    } catch(e) {
        console.log("error while loading day summary age");
    }

    return res;
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
    var temp = full[0].temperature.datasets[0].data[hour];
    var rain = full[0].rainfall.datasets[0].data[hour];

    var symbol = full[0].temperature.datasets[0].symbols[getCurrentSymbolHour()];

    res.symbol = symbol;
    res.temp = temp;
    res.rain = rain;

    return res;
}

function setData(timestamp, locationId, data) {
    var times = [];
    for (var i = 0; i < data.length; i++) {
        times.push(data[i].date);
    }

    var res = simpleQuery('INSERT OR REPLACE INTO data VALUES (?,?,?,?,?);', [
        timestamp, locationId, JSON.stringify(data),
        data.length, JSON.stringify(times)
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
