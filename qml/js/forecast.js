/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
 */

function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

function mayRefresh(lastRefreshed, maxAgeMins) {
//    return false; // DEBUG

    if (!lastRefreshed) {
        return true
    }

    maxAgeMins = defaultFor(maxAgeMins, 30)
    var maxAgeMillis = maxAgeMins * 60 * 1000
    var lastRefreshedDate = new Date(lastRefreshed)
    var now = new Date()

    console.log("check refresh: got age", now - lastRefreshedDate, ", max.", maxAgeMillis)

    if (now - lastRefreshedDate > maxAgeMillis) {
        console.log("> may refresh")
        return true
    } else {
        console.log("> no refresh needed")
    }

    return false
}

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
            }
        ],
    },
};

function convertRaw(raw) {
    var data = [];

    console.log("converting...")

    if (!raw || !raw.hasOwnProperty('graph') || !raw.hasOwnProperty('forecast')) {
        throw new Error('no-forecast-error')
    }

    if (raw.graph.hasOwnProperty('precipitation10m') && raw.graph.precipitation10m.length > 0) {
        var lists = ['precipitation', 'precipitationMin', 'precipitationMax']

        for (var k = 0; k < lists.length; k++) {
            var prefix = lists[k]
            var highRes = prefix + '10m'
            var lowRes = prefix + '1h'

            var _highResSums = []
            var _currentSum = 0

            for (var i = 0; i < raw.graph[highRes].length; i++) {
                if (i > 0 && i % 6 === 0) {
                    _highResSums.push(_currentSum)
                    _currentSum = 0
                }

                _currentSum += raw.graph[highRes][i]
            }

            if (raw.graph[highRes].length > 0 &&
                    raw.graph[highRes].length % 6 === 0) {
                _highResSums.push(_currentSum)
            }

            var endOfSummedRange = raw.graph.start + (_highResSums.length*3600*1000)

            if (endOfSummedRange > raw.graph.startLowResolution) {
                var drop = Math.ceil(
                            Math.abs(endOfSummedRange-raw.graph.startLowResolution) /
                            (3600*1000))
                raw.graph[lowRes].splice(0, drop)
                console.log(prefix + ": got too much high resolution data, dropping %1 low resolution hours".arg(drop))
            } else if (endOfSummedRange < raw.graph.startLowResolution &&
                       raw.graph.startLowResolution - endOfSummedRange > 3600*1000) {
                console.warn(prefix + ": gap of more than 1h between high resolution and low resolution data: %1 ms".
                             arg(raw.graph.startLowResolution - endOfSummedRange))
            } else if (endOfSummedRange === raw.graph.startLowResolution) {
                console.log(prefix + ": low and high resolution data aligns perfectly")
            }

            raw.graph[lowRes] = _highResSums.concat(raw.graph[lowRes])

            var extraHours = raw.graph[lowRes].length % 24
            if (raw.graph[lowRes].length / 24 < raw.forecast.length && extraHours !== 0) {
                console.warn(prefix + ": data is incomplete (modulo 24 === %1 !== 0)".arg(raw.graph[lowRes].length % 24));
            } else if (extraHours > 0) {
                console.log(prefix + ": dropping %1 extra hours".arg(extraHours))
                raw.graph[lowRes].splice(-extraHours, extraHours)
            }
        }
    }

    var dayCount = raw.forecast.length;
    for (var day = 0; day < dayCount; day++) {
        var dayData = {
            isSane: false,
            date: '',
            temperature: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [
                    { // expected
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
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [
                    { // expected
                        data: [],
                        symbols: []
                    },{ // minimum
                        data: [],
                    },{ // maximum
                        data: [],
                    },

                    { // invisible placeholder dataset
                      // to make sure the scale is always visible
                      // even if there is no precipitation
                        data: [1.0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               1.0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               1.0, 0, 0, 0]
                    }
                ],
            },
            sun: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [
                    { // expected
                        data: [],
                        symbols: []
                    },

                    { // invisible placeholder dataset
                      // to make sure the scale always
                      // goes up to 60
                        data: [60, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0]
                    }
                ],
            },
            wind: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [
                    // WIND
                    { // mean
                        data: [],
                        symbols: []
                    },{ // minimum
                        data: [],
                    },{ // maximum
                        data: [],
                    },

                    // GUSTS
                    { // mean
                        data: [],
                        symbols: []
                    },{ // minimum
                        data: [],
                    },{ // maximum
                        data: [],
                    },
                ],
            },
        };

        var date = new Date();
        date.setTime(raw.graph.start+(day*86400000));
        dayData.date = date.toJSON();

        console.log("- converting date:", dayData.date);

        // convert data
        for (var hour = day*24; hour < day*24+24; hour++) {
            var isThird = (hour)%3 === 1;
            var third = (hour-1)/3;
            // console.log("H", hour, day, dayCount, isThird, third)

            if (hour < raw.graph.precipitation1h.length) {
                dayData.rainfall.datasets[0].data.push(raw.graph.precipitation1h[hour] || null); // mean
                dayData.rainfall.datasets[1].data.push(raw.graph.precipitationMin1h[hour] || null); // minimum
                dayData.rainfall.datasets[2].data.push(raw.graph.precipitationMax1h[hour] || null); // maximum

                if (isThird) {
                    dayData.rainfall.datasets[0].symbols.push(raw.graph.precipitationProbability3h[third]);
                } else {
                    dayData.rainfall.datasets[0].symbols.push(null);
                }
            } else {
                // dayData.isSane = false;
                console.log("warning: missing data at the end: precipitation,", hour, raw.graph.precipitation1h.length);
            }

            if (hour < raw.graph.temperatureMean1h.length
                    && hour < raw.graph.temperatureMin1h.length
                    && hour < raw.graph.temperatureMax1h.length) {
                dayData.temperature.datasets[0].data.push(raw.graph.temperatureMean1h[hour]); // mean
                dayData.temperature.datasets[1].data.push(raw.graph.temperatureMin1h[hour]); // minimum
                dayData.temperature.datasets[2].data.push(raw.graph.temperatureMax1h[hour]); // maximum

                // weather icons are indexed at [__X] instead of [_X_]
                // TODO change this
                var tempIsThird = (hour)%3 === 2
                var tempThird = (hour-2)/3

                if (tempIsThird) {
                    dayData.temperature.datasets[0].symbols.push(raw.graph.weatherIcon3h[tempThird]);
                } else {
                    dayData.temperature.datasets[0].symbols.push(0);
                }
            } else {
                // dayData.isSane = false;
                console.log("warning: missing data at the end: temperature,", hour, raw.graph.temperatureMean1h.length);
            }

            if (hour < raw.graph.windSpeed1h.length
                    && hour < raw.graph.windSpeed1hq10.length
                    && hour < raw.graph.windSpeed1hq90.length) {
                dayData.wind.datasets[0].data.push(raw.graph.windSpeed1h[hour]) // mean
                dayData.wind.datasets[1].data.push(raw.graph.windSpeed1hq10[hour]) // minimum
                dayData.wind.datasets[2].data.push(raw.graph.windSpeed1hq90[hour]) // maximum

                if (isThird) {
                    dayData.wind.datasets[0].symbols.push(raw.graph.windDirection3h[third]);
                } else {
                    dayData.wind.datasets[0].symbols.push(null);
                }
            } else {
                // dayData.isSane = false
                console.log("warning: missing data at the end: wind,", hour, raw.graph.windSpeed1h.length);
            }

            if (hour < raw.graph.gustSpeed1h.length
                    && hour < raw.graph.gustSpeed1hq10.length
                    && hour < raw.graph.gustSpeed1hq90.length) {
                dayData.wind.datasets[3].data.push(raw.graph.gustSpeed1h[hour]) // mean
                dayData.wind.datasets[4].data.push(raw.graph.gustSpeed1hq10[hour]) // minimum
                dayData.wind.datasets[5].data.push(raw.graph.gustSpeed1hq90[hour]) // maximum
            } else {
                // dayData.isSane = false
                console.log("warning: missing data at the end: gust,", hour, raw.graph.gustSpeed1h.length);
            }

            if (hour < raw.graph.sunshine1h.length) {
                dayData.sun.datasets[0].data.push(raw.graph.sunshine1h[hour]) // expected
            } else {
                // dayData.isSane = false
                console.log("warning: missing data at the end: sunshine,", hour, raw.graph.sunshine1h.length);
            }
        }

        dayData.isSane = true;
        data.push(dayData);
    }

    return data
}

var fullData = [emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay];

function httpGet(url) {
    console.log("getting", url);

    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", url, false); // 'false' for synchronous request
    xmlHttp.setRequestHeader("User-Agent", "MeteoSwissApp-3.4.2-Android");
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
//    try {
//        fullData = convertRaw(JSON.parse(archived.rawData));
//    } catch (e) {
//        console.error("failed to convert raw data | exception:", e)
//        return
//    }
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

    if (!message || !message.hasOwnProperty('type')) {
        return
    }

    if (message.type === "weekOverview") {
        if (!message.locations || message.locations.length === 0) {
            console.log("note: no locations - week overview not updated");
            return
        }

        if (!mayRefresh(message.lastRefreshed, 15)) {
            console.log("no update needed for week overviews")
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

        console.log("updated week overviews")
        WorkerScript.sendMessage({
            type: 'weekOverview',
            timestamp: (new Date()).getTime(),
            data: ret
        })
    } else if (message.type === 'forecast') {
        var archived = message.data
        var lastRefreshed = message.lastRefreshed
        var locationId = message.locationId

        if (!!archived && !mayRefresh(message.lastRefreshed, 30)) {
            fallbackToArchive(archived, "no update needed for location %1".arg(locationId))
            return
        }

        var loaded = httpGet('https://app-prod-ws.meteoswiss-app.ch/v1/plzDetail?plz=' + locationId);
        // var loaded = httpGet('/home/%1/Devel/meteoswiss/plzDetail-3001.json'.arg('defaultuser')); // -- for debugging
        var rawData = {}

        if (loaded.status === 200) {
            try {
                rawData = JSON.parse(loaded.responseText)
            } catch (e) {
                fallbackToArchive(archived, "could not parse data JSON")
                return
            }
        } else {
            fallbackToArchive(archived, "failed to retrieve data (status %1)".arg(loaded.status))
            return
        }

        try {
            fullData = convertRaw(JSON.parse(JSON.stringify(rawData)));
        } catch (e) {
            if (e.message === 'no-forecast-error') {
                console.warn("no forecast available for location", locationId)
                console.warn("this location will be disabled")

                WorkerScript.sendMessage({
                    'type': 'disable-location',
                    'locationId': locationId,
                })
            } else {
                console.error("failed to convert raw data for", locationId)
                console.error("exception:", e.name);
                console.error("message:", e.message);
                console.error("stack:\n", e.stack);

                console.log("RAW DATA:")
                console.log(JSON.stringify(rawData))
            }

            return
        }

        var dateHeader = loaded.getResponseHeader('date')
        var timestamp = new Date()

        if (!!dateHeader) {
            timestamp = new Date(dateHeader)
            console.log("received data date header:", dateHeader, timestamp)
        }

        WorkerScript.sendMessage({
            'type': 'data',
            'locationId': locationId,
            'timestamp': timestamp.getTime(),
            'data': fullData,
            'rawData': JSON.stringify(rawData),
        })
    } else {
        console.error("received an invalid worker request:", JSON.stringify(message))
        return
    }
}
