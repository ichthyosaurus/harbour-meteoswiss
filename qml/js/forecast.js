/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
 */

function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

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
        haveData: false,
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
        haveData: false,
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{
                data: [],
                symbols: [],
            }
        ],
    },
};

function convert_raw(raw) {
    var data = [];

    console.log("converting...")

    if (raw.graph.hasOwnProperty('precipitation10m') && raw.graph.precipitation10m.length > 0) {
        var _currentSum = 0
        var _currentIndex = 0

        console.log("missing %1 more high res data points".
                    arg(raw.graph.precipitation10m.length%6 > 0 ? 6-raw.graph.precipitation10m.length%6 : 0));
        for (var m = 0; m < raw.graph.precipitation10m.length; m++) {
            if (m > 0 && m%6 === 0) {
                raw.graph.precipitation1h.splice(_currentIndex, 0, _currentSum);
                _currentIndex += 1;
                _currentSum = 0;
            }
            _currentSum += raw.graph.precipitation10m[m];
        }

        console.log("inserted %1 summed high res data points: final length".arg(_currentIndex+1),
                    raw.graph.precipitation1h.length)

        if (raw.graph.start+((_currentIndex)*3600000) === raw.graph.startLowResolution) {
            console.warn("precipitation data does not align: last summed hour and first low res hour seem to overlap | MUST BE CHECKED; often, this is fine");
        } else if (raw.graph.start+((_currentIndex+1)*3600000) !== raw.graph.startLowResolution) {
            console.warn("precipitation data does not align: generated start and startLowResolution mismatch");
        }
    }

    if (raw.graph.precipitation1h.length % 24 !== 0) {
        console.warn("precipitation data is incomplete (modulo 24 === %1 !== 0)".arg(raw.graph.precipitation1h.length % 24));
    }

    var dayCount = raw.forecast.length;
    for (var day = 0; day < dayCount; day++) {
        var dayData = {
            isSane: false,
            date: '',
            temperature: {
                haveData: false,
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
                haveData: false,
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{
                        data: [],
                        symbols: [],
                    }
                ],
            },
        };

        var date = new Date();
        date.setTime(raw.graph.start+(day*86400000));
        dayData.date = date.toJSON();

        console.log("- converting date:", dayData.date);

        // convert data
        for (var hour = day*24; hour < day*24+24; hour++) {
            var isThird = (hour)%3 === 2;
            var third = (hour-2)/3;
            // console.log("H", hour, day, dayCount, isThird, third)

            if (hour < raw.graph.precipitation1h.length) {
                dayData.rainfall.datasets[0].data.push(raw.graph.precipitation1h[hour]); // mean
                dayData.rainfall.datasets[1].data.push(raw.graph.precipitationMin1h[hour]); // minimum
                dayData.rainfall.datasets[2].data.push(raw.graph.precipitationMax1h[hour]); // maximum
                dayData.rainfall.haveData = true;
            } else {
                // dayData.isSane = false;
                // dayData.rainfall.haveData = false;
                console.log("warning: missing data at the end: precipitation,", hour, raw.graph.precipitation1h.length);
            }

            if (hour < raw.graph.temperatureMean1h.length
                    && hour < raw.graph.temperatureMin1h.length
                    && hour < raw.graph.temperatureMax1h.length) {
                dayData.temperature.datasets[0].data.push(raw.graph.temperatureMean1h[hour]); // estimate
                dayData.temperature.datasets[1].data.push(raw.graph.temperatureMin1h[hour]); // minimum
                dayData.temperature.datasets[2].data.push(raw.graph.temperatureMax1h[hour]); // maximum

                if (isThird) {
                    dayData.temperature.datasets[0].symbols.push(raw.graph.weatherIcon3h[third]);
                } else {
                    dayData.temperature.datasets[0].symbols.push(0);
                }

                dayData.temperature.haveData = true;
            } else {
                // dayData.isSane = false;
                // dayData.temperature.haveData = false;
                console.log("warning: missing data at the end: temperature,", hour, raw.graph.temperatureMean1h.length);
            }

            if (third < raw.graph.windSpeed3h.length) {
                if (isThird) {
                    dayData.wind.datasets[0].data.push(raw.graph.windSpeed3h[third]);
                    dayData.wind.datasets[0].symbols.push(raw.graph.windDirection3h[third]+"°");
                    dayData.wind.haveData = true;
                } else {
                    var lastThird = (hour-(hour%3))/3;
                    dayData.wind.datasets[0].data.push(lastThird >= 0 ? raw.graph.windSpeed3h[lastThird] : 0.0);
                    dayData.wind.datasets[0].symbols.push("");
                }
            } else {
                // dayData.isSane = false;
                // dayData.wind.haveData = false;
                console.log("warning: missing data at the end: temperature,", hour, raw.graph.temperatureMean1h.length);
            }
        }

        // check if there is any precipitation
        var minRain = Math.min.apply(Math, dayData.rainfall.datasets[1].data); // minimum of minimum

        // @disable-check M126
        if (minRain == 0.0) {
            // workaround to make sure chart scale is being shown
            dayData.rainfall.haveData = false;
            dayData.rainfall.datasets[0].data[0] = 0.3;
        }

        dayData.isSane = true;
        data.push(dayData);
    }

    return data
}

var fullData = [emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay];

function httpGet(url, enableSpoofing) {
    enableSpoofing = defaultFor(enableSpoofing, false);
    console.log("getting", url, "| spoofed:", enableSpoofing);

    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", url, false); // 'false' for synchronous request
    xmlHttp.setRequestHeader("User-Agent", "MeteoSwissApp-3.0.6-Android");

    if (enableSpoofing === true) {
        // FIXME Setting Host and Referer is not possible via XHR.
        // See: https://developer.mozilla.org/en-US/docs/Glossary/Forbidden_header_name
        // And: https://doc.qt.io/qt-5/qtqml-javascript-qmlglobalobject.html#xmlhttprequest
        // As of 2020-06-10, the app can no longer receive data due to this.

        // xmlHttp.setRequestHeader('Host', 'www.meteoschweiz.admin.ch');
        // xmlHttp.setRequestHeader('Referer', 'https://www.meteoschweiz.admin.ch/home.html?tab=overview');
    }

    xmlHttp.send(null);

    console.log("XHR response:", xmlHttp.status, xmlHttp.statusText);
    console.log("XHR response headers:", xmlHttp.getAllResponseHeaders());
    if (xmlHttp.status !== 200) console.log("XHR received data:", xmlHttp.responseText);

    return xmlHttp;
}

function fallbackToArchive(archived, errorMessage) {
    if (!archived) {
        console.log("warning: got invalid archive");
        return;
    }

    console.log("warning (" + archived.locationId + "): " + errorMessage);
    fullData = JSON.parse(archived.data);

    // vvv DEBUG
    /*try {
        fullData = convert_raw(JSON.parse(archived.rawData));
    } catch (e) {
        console.error("failed to convert raw data | exception:", e)
        return
    }*/
    // ^^^ DEBUG

    WorkerScript.sendMessage({
        'type': 'data',
        'locationId': archived.locationId,
        'timestamp': archived.timestamp,
        'data': fullData,
        'rawData': archived.rawData,
    });
}

// function sleep(ms) { // NOTE for debugging the loading display
//     var unixtime_ms = new Date().getTime();
//     while(new Date().getTime() < unixtime_ms + ms) {}
// }

WorkerScript.onMessage = function(message) {
    // sleep(2000) // DEBUG

    if (message && message.type === "weekOverview") {
        if (!message.locations || message.locations.length === 0) {
            console.log("note: no locations - week overview not updated");
            return
        }

        var json = httpGet('https://app-prod-ws.meteoswiss-app.ch/v1/plzOverview?plz=&small=' + message.locations.join(',') + '&large=');
        // var json = httpGet('/home/%1/Devel/meteoswiss/plzOverview.json'.arg('defaultuser')); // -- for debugging

        try {
            var week = JSON.parse(json.responseText);
        } catch (e) {
            console.log("error: failed to parse week overview json");
            return;
        }

        var ret = [];
        for (var l = 0; l < message.locations.length; l++) {
            var summary = week.forecast[message.locations[l]]

            if (!summary || !summary.hasOwnProperty('forecast')) {
                console.log("error: received an empty week overview for ", message.locations[l])
                continue
            }

            var days = summary.forecast

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

        if (ts.toDateString() === now.toDateString() && (now.getTime() - ts.getTime()) < 60*60*1000) {
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
                WorkerScript.sendMessage({ type: 'path', source: message.source, age: message.sourceAge });
            }

            return;
        }
    }

    var sourcePath = message.source;
    var sourceAge = message.sourceAge;

    function getSourcePath() {
        /*var xml = httpGet('https://www.meteoschweiz.admin.ch/home.html?tab=overview', false).responseText;
        var chartReg = /\/product\/output\/forecast-chart\/version__[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9]\/de/g;
        var retPath = chartReg.exec(xml);

        if (!retPath) {
            fallbackToArchive(archived, "could not extract JSON data path");
            return [undefined, undefined];
        } else {
            console.log("extracted data path:", retPath);
        }*/

        var retPath = '[unused]';
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
        var json = httpGet('https://app-prod-ws.meteoswiss-app.ch/v1/plzDetail?plz=' + locationId);
        // var json = httpGet('/home/%1/Devel/meteoswiss/plzDetail-3001.json'.arg('defaultuser')); // -- for debugging

        if (json.status !== 200) {
            return 'FAILED';
        }

        try {
            var ret = JSON.parse(json.responseText);
            return ret;
        } catch (e) {
            return undefined;
        }
    }

    var raw_data = getJSON(sourcePath);

    if (!raw_data) {
        /*console.log("retrying with new source path...");
        var source = getSourcePath();
        sourcePath = source[0];
        sourceAge = source[1];
        raw_data = getJSON(sourcePath);

        if (!raw_data) {
            fallbackToArchive(archived, "could not parse data JSON");
            return;
        }*/

        fallbackToArchive(archived, "could not parse data JSON");
        return;
    } else if (raw_data === 'FAILED') {
        fallbackToArchive(archived, "failed to retrieve data (invalid response)");
        return;
    }

    try {
        fullData = convert_raw(raw_data);
    } catch (e) {
        console.error("failed to convert raw data | exception:", e)
        return
    }

    WorkerScript.sendMessage({
        'type': 'data',
        'locationId': locationId,
        'timestamp': raw_data.currentWeather.time,
        'data': fullData,
        'rawData': JSON.stringify(raw_data),
    });
}
