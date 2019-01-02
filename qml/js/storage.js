
function getDatabase() {
    return LocalStorage.openDatabaseSync("meteoswiss", "1.0", "MeteoSwiss Offline Cache", 1000000)
}

function init() {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS locations(zip INTEGER PRIMARY KEY, name TEXT, canton TEXT, cantonId TEXT)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS data(timestamp INTEGER, zip INTEGER, converted TEXT, raw TEXT, PRIMARY KEY(timestamp, zip))');
    });
}

function setData(timestamp, zip, converted, raw) {
    var db = getDatabase();
    var res = "";

    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO data VALUES (?,?,?,?);', [timestamp, zip, converted, raw]);

        if (rs.rowsAffected > 0) {
            res = "ok";
        } else {
            res = "error";
        }
    });

    return res; // 'ok' or 'error'
}

function addLocation(zip, name, canton, cantonId) {
    var db = getDatabase();
    var res = "";

    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO locations VALUES (?,?,?,?);', [zip, name, canton, cantonId]);

        if (rs.rowsAffected > 0) {
            res = "ok";
        } else {
            res = "error";
        }
    });

    return res; // 'ok' or 'error'
}

function removeLocation(zip) {
    var db = getDatabase();
    var res = ""

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM locations WHERE zip=?;', [zip]);

            if (rs.rowsAffected > 0) {
                res = "ok";
            } else {
                res = "error";
            }
        })
    } catch(e) {
        console.log("error while removing location: zip=" + zip)
        res = "error"
    }

    return res
}

function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

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

function getLocationData(zip) {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            if (zip) {
                var rs = tx.executeSql('SELECT * FROM locations WHERE zip=?;', [zip]);
            } else {
                var rs = tx.executeSql('SELECT * FROM locations ORDER BY zip DESC;');
            }

            for (var i = 0; i < rs.rows.length; i++) {
                res.push({
                    zip: rs.rows.item(i).zip,
                    name: rs.rows.item(i).name,
                    canton: rs.rows.item(i).canton,
                    cantonId: rs.rows.item(i).cantonId,
                })
            }
        })
    } catch(e) {
        console.log("error while loading locations data: zip=" + zip)
        return [];
    }

    return res
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
