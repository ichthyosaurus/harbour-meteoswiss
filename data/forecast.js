
function date_diff(a, b) {
    var d1 = new Date()
    var d2 = new Date()

    d1.setTime(a)
    d2.setTime(b)

    return d1-d2
}

function convert_raw(raw) {
    var data = []

    raw.sort(function(a, b) {
        return date_diff(a.max_date, b.max_date)
    })

    for (var day = 0; day < raw.length; day++) {
        var dayData = {
            date: '',
            dateString: '',
            temperature: {
                labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
                datasets: [{
                    fillColor: "rgba(0,0,0,0)",
                    strokeColor: "rgba(234,77,79,1)",
                    pointColor: "rgba(234,77,79,1)",
                    data: [],
                    symbols: []
                }]
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
            }
        }

        dayData.date = new Date()
        dayData.date.setTime(raw[day].max_date)

        var weekday = dayData.date.getDay()

        if (weekday == 0) {
            weekday = "So"
        } else if (weekday == 1) {
            weekday = "Mo"
        } else if (weekday == 2) {
            weekday = "Di"
        } else if (weekday == 3) {
            weekday = "Mi"
        } else if (weekday == 4) {
            weekday = "Do"
        } else if (weekday == 5) {
            weekday = "Fr"
        } else if (weekday == 6) {
            weekday = "Sa"
        }

        dayData.dateString = weekday + "., " + dayData.date.getDate() + ". " + (dayData.date.getMonth()+1) + ". " + dayData.date.getFullYear()

        raw[day].rainfall.sort(function(a, b) {
            return date_diff(a[0], b[0])
        })

        raw[day].temperature.sort(function(a, b) {
            return date_diff(a[0], b[0])
        })

        raw[day].symbols.sort(function(a, b) {
            return date_diff(a.timestamp, b.timestamp)
        })

        for (var rain = 0; rain < raw[day].rainfall.length; rain++) {
            dayData.rainfall.datasets[0].data.push(raw[day].rainfall[rain][1])
            dayData.rainfall.datasets[0].tableData.push(raw[day].rainfall[rain][1])
        }

        var minR = Math.min.apply(Math, dayData.rainfall.datasets[0].data)
        var maxR = Math.max.apply(Math, dayData.rainfall.datasets[0].data)

        if ((minR == maxR) && minR == 0.0) { // WARNING ugly hack: set dummy data to force scale being shown
            dayData.rainfall.datasets[0].fillColor = "rgba(151,187,205,0.0)"
            dayData.rainfall.datasets[0].strokeColor = "rgba(151,187,205,0.0)"
            dayData.rainfall.datasets[0].pointColor = "rgba(151,187,205,0.0)"
            dayData.rainfall.datasets[0].data[0] = 0.3
        }

        for (var temp = 0; temp < raw[day].temperature.length; temp++) {
            dayData.temperature.datasets[0].data.push(raw[day].temperature[temp][1])
            dayData.temperature.datasets[0].symbols.push(0)
        }

        for (var sym = 0; sym < raw[day].symbols.length; sym++) {
            dayData.temperature.datasets[0].symbols[(sym*3)+2] = raw[day].symbols[sym].weather_symbol_id
        }

        print("rain", dayData.rainfall.datasets[0].tableData)

        data.push(dayData)
    }

    return data
}

var emptyDummyDay = {
    date: '',
    dateString: '',
    temperature: {
        labels: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
        datasets: [{
            fillColor: "rgba(0,0,0,0)",
            strokeColor: "rgba(234,77,79,1)",
            pointColor: "rgba(234,77,79,1)",
            data: [],
            symbols: []
        }]
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
    }
}

var fullData = [emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay, emptyDummyDay]


function httpGet(url) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", url, false); // false for synchronous request
    xmlHttp.send(null);
    return xmlHttp;
}

function fail(error) {
    console.log("error: " + error)
    WorkerScript.sendMessage({ 'data': fullData })
}

WorkerScript.onMessage = function(message) {
    if (message.data) {
        fullData = convert_raw(message.data)
    } else {
        var xml = httpGet('https://www.meteoschweiz.admin.ch/home.html?tab=overview').responseText
        var chartReg = /\/product\/output\/forecast-chart\/version__[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9]\/de/g;
        var res = chartReg.exec(xml);
        console.log(res)

        if (!res) {
            fail("could not extract JSON path");
            return;
        }

        var json = httpGet('https://www.meteoschweiz.admin.ch' + res + '/414300.json')
        var raw_data = JSON.parse(json.responseText);

        if (!raw_data) {
            fail("could not parse JSON");
            return;
        }

        fullData = convert_raw(raw_data)
    }

    WorkerScript.sendMessage({ 'data': fullData })
}
