
function getDatabase() {
    return LocalStorage.openDatabaseSync("meteoswiss", "1.0", "MeteoSwiss Offline Cache", 1000000)
}

function init() {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS zipcodes(zip INTEGER PRIMARY KEY, name TEXT, canton TEXT, cantonId TEXT)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS data(timestamp INTEGER, zip INTEGER, converted TEXT, raw TEXT, PRIMARY KEY(timestamp, zip))');
    });
}

function setData(timestamp, zip, converted, raw) {
    var db = getDatabase();
    var res = "";

    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO data VALUES (?,?,?,?);', [timestamp, zip, converted, raw]);
        console.log("save dataset: " + rs.rowsAffected)

        if (rs.rowsAffected > 0) {
            res = "ok";
        } else {
            res = "error";
        }
    });

    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO zipcodes VALUES (?,?,?,?);', [zip, "unknown", "unknown", "??"]);
        console.log("save location: " + rs.rowsAffected)

        if (rs.rowsAffected > 0) {
            res = "ok";
        } else {
            res = "error";
        }
    });

    return res; // 'ok' or 'error'
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
