
function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

var initialized = false

function getDatabase() {
    var db = LocalStorage.openDatabaseSync("meteoswiss", "1.0", "MeteoSwiss Offline Cache", 1000000)
    if (!initialized) {
        doInit(db)
        initialized = true
    }
    return db;
}

function init() {
    initialized = false
    getDatabase();
}

function doInit(db) {
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS data(timestamp INTEGER, zip INTEGER, converted TEXT, raw TEXT, PRIMARY KEY(timestamp, zip))');
        tx.executeSql('CREATE TABLE IF NOT EXISTS locations(zip INTEGER PRIMARY KEY, name TEXT, canton TEXT, cantonId TEXT, position INTEGER)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS view(zip_on_cover INTEGER PRIMARY KEY)');
    });
}

function simpleQuery(query, values) {
    var db = getDatabase();
    var res = null
    values = defaultFor(values, [])

    if (!query) {
        console.log("error: empty query")
        return null
    }

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql(query, values);

            if (rs.rowsAffected > 0) {
                res = rs.rowsAffected;
            } else {
                res = 0;
            }
        })
    } catch(e) {
        console.log("error in query:", values)
        res = null
    }

    return res
}

function addLocation(zip, name, canton, cantonId, position) {
    var res = simpleQuery('INSERT OR IGNORE INTO locations VALUES (?,?,?,?,?);', [zip, name, canton, cantonId, position])

    if (res != 0 && !res) {
        console.log("error: failed to save location to db")
    }

    return res
}

function removeLocation(zip) {
    var res = simpleQuery('DELETE FROM locations WHERE zip=?;', [zip])

    if (!res) {
        console.log("error: failed to remove location from db")
    }
}

function getCoverZip() {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM view ORDER BY zip_on_cover LIMIT 1;');

            if (rs.rows.length > 0) {
                res = rs.rows.item(0).zip_on_cover
            } else {
                res = 0
            }
        })
    } catch(e) {
        console.log("error while loading view settings data")
        return 0;
    }

    return res
}

function getNextCoverZip(zip) {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations WHERE zip > ? ORDER BY zip LIMIT 1', [zip]);

            if (rs.rows.length == 0) {
                rs = tx.executeSql('SELECT * FROM locations ORDER BY zip LIMIT 1');

                if (rs.rows.length == 0) {
                    res = 0
                    console.log("error: failed to get next cover location")
                }
            }

            res = rs.rows.item(0).zip
        })
    } catch(e) {
        console.log("error while loading next cover location")
        return 0;
    }

    return res
}

function setCoverZip(zip) {
    var db = getDatabase();
    var res = null

    try {
        db.transaction(function(tx) {
            tx.executeSql('UPDATE view SET zip_on_cover=?;', [zip]);
            var rs = tx.executeSql('INSERT OR REPLACE INTO view (zip_on_cover) VALUES (?); ', [zip]);

            if (rs.rowsAffected > 0) {
                res = rs.rowsAffected;
            } else {
                res = 0;
            }
        })
    } catch(e) {
        console.log("error in query:", values)
        res = null
    }

    if (res != 0 && !res) {
        console.log("error: failed to save cover view settings")
    }
}

function getLocationData(zip) {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            if (zip) {
                var rs = tx.executeSql('SELECT * FROM locations WHERE zip=?;', [zip]);
            } else {
                var rs = tx.executeSql('SELECT * FROM locations ORDER BY position ASC;');
            }

            for (var i = 0; i < rs.rows.length; i++) {
                res.push({
                    zip: rs.rows.item(i).zip,
                    name: rs.rows.item(i).name,
                    canton: rs.rows.item(i).canton,
                    cantonId: rs.rows.item(i).cantonId,
                    position: rs.rows.item(i).position,
                })
            }
        })
    } catch(e) {
        console.log("error while loading locations data: zip=" + zip)
        return [];
    }

    return res
}

function setOverviewPositions(dataPairs) {
    var db = getDatabase();
    var res = 0
    dataPairs = defaultFor(dataPairs, [])

    try {
        db.transaction(function(tx) {
            for (var i = 0; i < dataPairs.length; i++) {
                var rs = tx.executeSql('UPDATE locations SET position=? WHERE zip=?;', [dataPairs[i].position, dataPairs[i].zip]);

                if (rs.rowsAffected != 1) {
                    console.log("error: failed to update position for zip=" + dataPairs[i].zip)
                }

                res += rs.rowsAffected
            }
        })
    } catch(e) {
        console.log("error in query:", values)
        res = null
    }

    if (res != dataPairs.length) {
        console.log("error: failed to save overview order")
    }
}

function getDataSummary(zip) {
    var data = getData(zip, true)
    data = data.length > 0 ? data[0] : null

    var ts = new Date(data.timestamp)
    var now = new Date()

    if (ts.toDateString() != now.toDateString()) {
        console.log("error: no cached data from today available")
        return {
            zip: zip,
            symbol: 0,
            temp: null,
            rain: null,
        }
    }

    var hour = now.getHours()
    var full = JSON.parse(data.converted)
    var temp = full[0].temperature.datasets[0].data[hour]
    var rain = full[0].rainfall.datasets[0].data[hour]

    // find nearest available symbol:
    // There are symbols every 3 hours, starting at 2am and ending at 11pm.
    // If the current hour is 0 (= 12pm), set it to 11pm for the symbol (= 23).
    // Else if the current hour modulus 3 is 1, set it to the previous hour.
    // If it is 2, get the symbol of the next hour.

    if (hour == 0) {
        hour = 23
    } else {
        if ((hour+1) % 3 == 1) {
            hour -= 1
        } else if ((hour+1) % 3 == 2) {
            hour += 1
        }
    }

    var symbol = full[0].temperature.datasets[0].symbols[hour]

    return {
        zip: zip,
        symbol: symbol,
        temp: temp,
        rain: rain,
    }
}

function setData(timestamp, zip, converted, raw) {
    var res = simpleQuery('INSERT OR REPLACE INTO data VALUES (?,?,?,?);', [timestamp, zip, converted, raw])

    if (!res) {
        console.log("error: failed to save data to db")
    }
}

function getData(zip, mostRecent, newerThan) {
    var db = getDatabase();
    var res = [];

    newerThan = defaultFor(newerThan, 0)
    mostRecent = defaultFor(mostRecent, true)

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM data WHERE zip=? AND timestamp>=? ORDER BY timestamp DESC;', [zip, newerThan]);

            for (var i = 0; i < rs.rows.length; i++) {
                res.push({
                    zip: rs.rows.item(i).zip,
                    timestamp: rs.rows.item(i).timestamp,
                    converted: rs.rows.item(i).converted,
                    raw: rs.rows.item(i).raw,
                })

                if (mostRecent) break;
            }
        })
    } catch(e) {
        console.log("error while loading data: zip=" + zip + " newerThan=" + newerThan)
        return [];
    }

    return res
}
