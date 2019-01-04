
function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

var initialized = false

function getDatabase() {
    var db = LocalStorage.openDatabaseSync("harbour-meteoswiss", "2.0", "MeteoSwiss Offline Cache", 1000000);

    if (!initialized) {
        doInit(db);
        initialized = true;
    }

    return db;
}

function init() {
    initialized = false
    getDatabase();
}

function doInit(db) {
    // Database tables: (primary key in all-caps)
    // data: TIMESTAMP, LOCATION_ID, converted, raw
    // locations: LOCATION_ID, zip, name, cantonId, canton, view_position
    // settings: SETTING, value

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS data(\
            timestamp INTEGER NOT NULL, location_id INTEGER NOT NULL, converted TEXT NOT NULL, raw TEXT, PRIMARY KEY(timestamp, location_id))');

        tx.executeSql('CREATE TABLE IF NOT EXISTS locations(\
            location_id INTEGER NOT NULL PRIMARY KEY, zip INTEGER NOT NULL, name TEXT NOT NULL,\
            cantonId TEXT NOT NULL, canton TEXT NOT NULL, view_position INTEGER NOT NULL)');

        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT NOT NULL PRIMARY KEY, value TEXT)');
    });
}

function simpleQuery(query, values) {
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
        });
    } catch(e) {
        console.log("error in query:", values);
        res = undefined;
    }

    return res;
}

function addLocation(locationId, zip, name, cantonId, canton, viewPosition) {
    var res = simpleQuery('INSERT OR IGNORE INTO locations VALUES (?,?,?,?,?,?);', [locationId, zip, name, cantonId, canton, viewPosition]);

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
                    console.log("error: failed to get next cover location");
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
    var res = undefined;
    dataPairs = defaultFor(dataPairs, []);

    try {
        db.transaction(function(tx) {
            for (var i = 0; i < dataPairs.length; i++) {
                var rs = tx.executeSql('UPDATE locations SET view_position=? WHERE location_id=?;', [dataPairs[i].viewPosition, dataPairs[i].locationId]);

                if (rs.rowsAffected !== 1) {
                    console.log("error: failed to update view position for " + dataPairs[i].locationId);
                }

                res += rs.rowsAffected;
            }
        });
    } catch(e) {
        console.log("error in query:", values);
        res = undefined;
    }

    if (res !== dataPairs.length) {
        console.log("error: failed to save overview positions");
    }

    return res;
}

function getDataSummary(locationId) {
    var res = {
        locationId: locationId,
        symbol: 0,
        temp: undefined,
        rain: undefined,
    };

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

    var full = JSON.parse(data.converted);
    var temp = full[0].temperature.datasets[0].data[hour];
    var rain = full[0].rainfall.datasets[0].data[hour];

    // find nearest available symbol:
    // There are symbols every 3 hours, starting at 2am and ending at 11pm.
    // If the current hour is 0 (= 12pm), set it to 11pm for the symbol (= 23).
    // Else if the current hour modulus 3 is 1, set it to the previous hour.
    // If it is 2, get the symbol of the next hour.

    if (hour == 0) {
        hour = 23;
    } else {
        if ((hour+1) % 3 == 1) {
            hour -= 1;
        } else if ((hour+1) % 3 == 2) {
            hour += 1;
        }
    }

    var symbol = full[0].temperature.datasets[0].symbols[hour];

    res.symbol = symbol;
    res.temp = temp;
    res.rain = rain;

    return res;
}

function setData(timestamp, locationId, converted, raw) {
    var res = simpleQuery('INSERT OR REPLACE INTO data VALUES (?,?,?,?);', [timestamp, locationId, converted, raw]);

    if (!res) {
        console.log("error: failed to save data for " + locationId + " to db");
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
            var rs = tx.executeSql('SELECT * FROM data WHERE location_id=? AND timestamp>=? ORDER BY timestamp DESC;', [locationId, newerThan]);

            for (var i = 0; i < rs.rows.length; i++) {
                res.push({
                    locationId: rs.rows.item(i).location_id,
                    timestamp: rs.rows.item(i).timestamp,
                    converted: rs.rows.item(i).converted,
                    raw: rs.rows.item(i).raw,
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
