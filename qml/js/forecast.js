
function date_diff(a, b) {
    var d1 = new Date();
    var d2 = new Date();

    d1.setTime(a);
    d2.setTime(b);

    return d1-d2;
}

function convert_raw(raw) {
    var data = [];

    raw.sort(function(a, b) {
        return date_diff(a.max_date, b.max_date);
    })

    for (var day = 0; day < raw.length; day++) {
        var dayData = {
            date: '',
            temperature: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{
                    fillColor: "rgba(0,0,0,0)",
                    strokeColor: "rgba(234,77,79,1)",
                    pointColor: "rgba(234,77,79,1)",
                    data: [],
                    symbols: [],
                }],
            },
            rainfall: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{
                    fillColor: "rgba(151,187,205,0.5)",
                    strokeColor: "rgba(151,187,205,1)",
                    pointColor: "rgba(151,187,205,1)",
                    data: [],
                    tableData: [],
                }]
            },
            wind: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{
                    fillColor: "rgba(0,0,0,0)",
                    strokeColor: "rgba(255,255,0,1)",
                    pointColor: "rgba(255,255,0,1)",
                    data: [],
                    symbols: [],
                }],
            },
            // TODO add variance_rain, variance_range
        };

        var date = new Date();
        date.setTime(raw[day].max_date);
        dayData.date = date.toJSON();

        raw[day].rainfall.sort(function(a, b) {
            return date_diff(a[0], b[0]);
        });

        raw[day].temperature.sort(function(a, b) {
            return date_diff(a[0], b[0]);
        });

        raw[day].wind.data.sort(function(a, b) {
            return date_diff(a[0], b[0]);
        });

        raw[day].wind.symbols.sort(function(a, b) {
            return date_diff(a.timestamp, b.timestamp);
        });

        raw[day].symbols.sort(function(a, b) {
            return date_diff(a.timestamp, b.timestamp);
        });

        for (var rain = 0; rain < raw[day].rainfall.length; rain++) {
            dayData.rainfall.datasets[0].data.push(raw[day].rainfall[rain][1]);
            dayData.rainfall.datasets[0].tableData.push(raw[day].rainfall[rain][1]);
        }

        var minR = Math.min.apply(Math, dayData.rainfall.datasets[0].data);
        var maxR = Math.max.apply(Math, dayData.rainfall.datasets[0].data);

        // @disable-check M126
        if ((minR === maxR) && minR == 0.0) { // WARNING ugly hack: set dummy data to force scale being shown
            dayData.rainfall.datasets[0].fillColor = "rgba(151,187,205,0.0)";
            dayData.rainfall.datasets[0].strokeColor = "rgba(151,187,205,0.0)";
            dayData.rainfall.datasets[0].pointColor = "rgba(151,187,205,0.0)";
            dayData.rainfall.datasets[0].data[0] = 0.3;
        }

        for (var temp = 0; temp < raw[day].temperature.length; temp++) {
            dayData.temperature.datasets[0].data.push(raw[day].temperature[temp][1]);
            dayData.temperature.datasets[0].symbols.push(0);
        }

        for (var wind = 0; wind < raw[day].wind.data.length; wind++) {
            dayData.wind.datasets[0].data.push(raw[day].wind.data[wind][1]);
            dayData.wind.datasets[0].symbols.push("");
        }

        for (var wind_sym = 0; wind_sym < raw[day].wind.symbols.length; wind_sym++) {
            dayData.wind.datasets[0].symbols[wind_sym*2] = raw[day].wind.symbols[wind_sym].symbol_id;
        }

        for (var sym = 0; sym < raw[day].symbols.length; sym++) {
            dayData.temperature.datasets[0].symbols[(sym*3)+2] = raw[day].symbols[sym].weather_symbol_id;
        }

        dayData.isSane = true;
        data.push(dayData);
    }

    return data
}

var emptyDummyDay = {
    isSane: false,
    date: '',
    temperature: {
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{
            fillColor: "rgba(0,0,0,0)",
            strokeColor: "rgba(234,77,79,1)",
            pointColor: "rgba(234,77,79,1)",
            data: [],
            symbols: []
        }],
    },
    rainfall: {
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{
            fillColor: "rgba(151,187,205,0.5)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            data: [],
            tableData: [],
        }],
    },
    wind: {
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{
            fillColor: "rgba(0,0,0,0)",
            strokeColor: "rgba(255,255,0,1)",
            pointColor: "rgba(255,255,0,1)",
            data: [],
            symbols: [],
        }],
    },
};

var fullData = [emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay];


function httpGet(url) {
    var xmlHttp = new XMLHttpRequest();
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
    fullData = JSON.parse(archived.converted);

    WorkerScript.sendMessage({
        'locationId': archived.locationId,
        'timestamp': archived.timestamp,
        'data': fullData,
        'raw': JSON.parse(archived.raw),
    });
}

// function sleep(ms) { // NOTE for debugging the loading display
//     var unixtime_ms = new Date().getTime();
//     while(new Date().getTime() < unixtime_ms + ms) {}
// }

WorkerScript.onMessage = function(message) {
    // sleep(2000) // DEBUG

    var locationId;
    var raw_data;
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

    if (archived) {
        var ts = new Date(archived.timestamp);
        var now = new Date();

        if (ts.toDateString() == now.toDateString() && (now.getTime() - ts.getTime()) < 60*60*1000) {
            fallbackToArchive(archived, "already refreshed less than an hour ago");
            return;
        }
    }

    var xml = httpGet('https://www.meteoschweiz.admin.ch/home.html?tab=overview').responseText;
    var chartReg = /\/product\/output\/forecast-chart\/version__[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9]\/de/g;
    var res = chartReg.exec(xml);

    if (!res) {
        fallbackToArchive(archived, "could not extract JSON data path");
        return;
    } else {
        console.log("extracted data path:", res);
    }

    var json = httpGet('https://www.meteoschweiz.admin.ch' + res + '/' + locationId + '.json');
    raw_data = JSON.parse(json.responseText);

    if (!raw_data) {
        fallbackToArchive(archived, "could not parse data JSON");
        return;
    }

    fullData = convert_raw(raw_data);

    WorkerScript.sendMessage({ 'locationId': locationId, 'timestamp': raw_data[0].current_time, 'data': fullData, 'raw': raw_data });
}
