
function date_diff(a, b) {
    var d1 = new Date();
    var d2 = new Date();

    d1.setTime(a);
    d2.setTime(b);

    return d1-d2;
}

var emptyDummyDay = {
    isSane: false,
    date: '',
    temperature: {
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{ // estimate
                data: [],
                symbols: []
            },{ // minimum
                data: [],
            },{ // maximum
                data: [],
            },
        ],
    },
    rainfall: {
        haveData: false,
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{ // estimate
                data: [],
            },{ // minimum
                data: [],
            },{ // maximum
                data: [],
            },
        ],
    },
    wind: {
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{
            data: [],
            symbols: [],
        }],
    },
};

function convert_raw(raw) {
    var data = [];

    raw.sort(function(a, b) {
        return date_diff(a.max_date, b.max_date);
    })

    for (var day = 0; day < raw.length; day++) {
        var dayData = {
            isSane: false,
            date: '',
            temperature: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{ // estimate
                        data: [],
                        symbols: []
                    },{ // minimum
                        data: [],
                    },{ // maximum
                        data: [],
                    },
                ],
            },
            rainfall: {
                haveData: false,
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{ // estimate
                        data: [],
                    },{ // minimum
                        data: [],
                    },{ // maximum
                        data: [],
                    },
                ],
            },
            wind: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{
                    data: [],
                    symbols: [],
                }],
            },
        };

        if (   raw[day].rainfall.length != 24
            || raw[day].rainfall.length != raw[day].temperature.length
            || raw[day].rainfall.length != raw[day].wind.data.length
            || raw[day].rainfall.length != raw[day].variance_rain.length
            || raw[day].rainfall.length != raw[day].variance_range.length
        ) {
            console.log("failed converting data for day " + day + ": datasets have different lengths")
            dayData.isSane = true;
            data.push(dayData);
            continue;
        }

        var date = new Date();
        date.setTime(raw[day].max_date);
        dayData.date = date.toJSON();

        // sort data
        raw[day].rainfall.sort(function(a, b) { return date_diff(a[0], b[0]); });
        raw[day].variance_rain.sort(function(a, b) { return date_diff(a[0], b[0]); });
        raw[day].temperature.sort(function(a, b) { return date_diff(a[0], b[0]); });
        raw[day].variance_range.sort(function(a, b) { return date_diff(a[0], b[0]); });
        raw[day].wind.data.sort(function(a, b) { return date_diff(a[0], b[0]); });
        raw[day].wind.symbols.sort(function(a, b) { return date_diff(a.timestamp, b.timestamp); });
        raw[day].symbols.sort(function(a, b) { return date_diff(a.timestamp, b.timestamp); });

        // convert data
        for (var hour = 0; hour < raw[day].rainfall.length; hour++) {
            dayData.rainfall.datasets[0].data.push(raw[day].rainfall[hour][1]);         // estimate
            dayData.rainfall.datasets[1].data.push(raw[day].variance_rain[hour][1]);    // minimum
            dayData.rainfall.datasets[2].data.push(raw[day].variance_rain[hour][2]);    // maximum

            dayData.temperature.datasets[0].data.push(raw[day].temperature[hour][1]);       // estimate
            dayData.temperature.datasets[0].symbols.push(0);
            dayData.temperature.datasets[1].data.push(raw[day].variance_range[hour][1]);    // minimum
            dayData.temperature.datasets[2].data.push(raw[day].variance_range[hour][2]);    // maximum

            dayData.wind.datasets[0].data.push(raw[day].wind.data[hour][1]);
            dayData.wind.datasets[0].symbols.push("");
        }

        for (var wind_sym = 0; wind_sym < raw[day].wind.symbols.length; wind_sym++) {
            dayData.wind.datasets[0].symbols[wind_sym*2] = raw[day].wind.symbols[wind_sym].symbol_id;
        }

        for (var sym = 0; sym < raw[day].symbols.length; sym++) {
            dayData.temperature.datasets[0].symbols[(sym*3)+2] = raw[day].symbols[sym].weather_symbol_id;
        }

        // check if there is any precipitation
        var minR = Math.min.apply(Math, dayData.rainfall.datasets[1].data); // minimum of minimum
        var maxR = Math.max.apply(Math, dayData.rainfall.datasets[2].data); // maximum of maximum

        // @disable-check M126
        if ((minR === maxR) && minR == 0.0) {
            // workaround to make sure chart scale is being shown
            dayData.rainfall.haveData = false;
            dayData.rainfall.datasets[0].data[0] = 0.3;
        } else {
            dayData.rainfall.haveData = true;
        }

        dayData.isSane = true;
        data.push(dayData);
    }

    return data
}

var fullData = [emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay];


function httpGet(url) {
    var xmlHttp = new XMLHttpRequest();
    // xmlHttp.setRequestHeader("User-Agent", "MeteoSwissApp-2.3.3-Android");
    xmlHttp.open("GET", url, false); // false for synchronous request
    xmlHttp.send(null);
    return xmlHttp;
}

function fallbackToArchive(archived, errorMessage) {
    if (!archived) {
        console.log("warning: got invalid archive");
        return;
    }

    console.log("warning (" + archived.locationId + "): " + errorMessage);
    fullData = JSON.parse(archived.data);

    WorkerScript.sendMessage({
        'type': 'data',
        'locationId': archived.locationId,
        'timestamp': archived.timestamp,
        'data': fullData,
    });
}

// function sleep(ms) { // NOTE for debugging the loading display
//     var unixtime_ms = new Date().getTime();
//     while(new Date().getTime() < unixtime_ms + ms) {}
// }

WorkerScript.onMessage = function(message) {
    // sleep(2000) // DEBUG

    if (message && message.type == "weekOverview") {
        if (!message.locations || message.locations.length == 0) {
            console.log("note: no locations - week overview not updated");
            return
        }

        var json = httpGet('https://app-prod-ws.meteoswiss-app.ch/v1/plzOverview?plz=&small=' + message.locations.join(',') + '&large=');

        try {
            var week = JSON.parse(json.responseText);
        } catch (e) {
            console.log("error: failed to parse week overview json");
            return;
        }

        var ret = [];
        for (var l = 0; l < message.locations.length; l++) {
            var days = week.forecast[message.locations[l]].forecast

            for (var d = 0; d < (days.length ? days.length : 0); d++) {
                ret.push({
                    locationId: message.locations[l],
                    dayString: days[d].dayDate,
                    symbol: days[d].iconDay,
                    precipitation: days[d].precipitation,
                    tempMin: days[d].temperatureMin,
                    tempMax: days[d].temperatureMax,
                });
            }
        }

        console.log("UPDATED updated week overviews")
        WorkerScript.sendMessage({ type: 'weekOverview', age: new Date(), data: ret });
        return;
    }


    var locationId;
    var archived = null;

    if (message && message.locationId) {
        locationId = message.locationId;
    } else {
        console.log("error: failed to load data: missing location id");
        return;
    }

    if (message && message.data) {
        archived = message.data;
    }

    // if (message && message.dummy) {
    //     fallbackToArchive(message.dummy, "using dummy archive")
    //     return
    // }

    var now = new Date();
    if (archived) {
        var ts = new Date(archived.timestamp);

        if (ts.toDateString() == now.toDateString() && (now.getTime() - ts.getTime()) < 60*60*1000) {
            fallbackToArchive(archived, "already refreshed less than an hour ago");

            // Notify of the unchanged path to make sure refreshing continues.
            //
            // When refreshing all locations, the first is refreshed and the
            // rest waits for the updated path. If the path stays unchanged,
            // the main thread has to be notified nonetheless, else the process
            // would not continue.
            // This is only needed if the first location was already refreshed
            // less than an hour ago. If the path is invalid later on, we don't
            // want to ensure a cached path is used. It will be renewed if necessary.
            // All this is only important when refreshing all locations. When
            // refreshing a single location, the path gets extracted and stored.
            // If two locations are refreshed separately with less than a certain
            // threshold of difference, the cached path will be used correctly.
            // This work-around is only necessary to make sure the threads stay
            // in sync when looping quickly over all locations.
            if (message.notifyUnchangedPath) {
                WorkerScript.sendMessage({ type: 'path', source: sourcePath, age: sourceAge });
            }

            return;
        }
    }

    var sourcePath = message.source;
    var sourceAge = message.sourceAge;

    function getSourcePath() {
        var xml = httpGet('https://www.meteoschweiz.admin.ch/home.html?tab=overview').responseText;
        var chartReg = /\/product\/output\/forecast-chart\/version__[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9]\/de/g;
        var retPath = chartReg.exec(xml);

        if (!retPath) {
            fallbackToArchive(archived, "could not extract JSON data path");
            return [undefined, undefined];
        } else {
            console.log("extracted data path:", retPath);
        }

        var retAge = now;

        WorkerScript.sendMessage({ type: 'path', source: retPath, age: retAge });

        return [retPath, retAge];
    }

    if (!sourcePath || (now - sourceAge) > 60*10*1000) {
        var source = getSourcePath();
        sourcePath = source[0];
        sourceAge = source[1];
    } else {
        console.log("using cached data path:", sourcePath);
    }

    function getJSON(sourcePath) {
        var json = httpGet('https://www.meteoschweiz.admin.ch' + sourcePath + '/' + locationId + '.json');

        try {
            var ret = JSON.parse(json.responseText);
            return ret;
        } catch (e) {
            return undefined;
        }
    }

    var raw_data = getJSON(sourcePath);

    if (!raw_data) {
        console.log("retrying with new source path...");
        var source = getSourcePath();
        sourcePath = source[0];
        sourceAge = source[1];
        raw_data = getJSON(sourcePath);

        if (!raw_data) {
            fallbackToArchive(archived, "could not parse data JSON");
            return;
        }
    }

    fullData = convert_raw(raw_data);

    WorkerScript.sendMessage({
        'type': 'data',
        'locationId': locationId,
        'timestamp': raw_data[0].current_time,
        'data': fullData,
    });
}
