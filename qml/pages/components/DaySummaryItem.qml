import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../../js/storage.js" as Storage

BackgroundItem {
    property int day
    property int location
    property var data

    opacity: 0.65
    width: parent.width/6
    height: column.height

    signal summaryClicked(int day, int location)
    onClicked: summaryClicked(day, location)

    Column {
        id: column
        width: parent.width

        property var textColor: Theme.primaryColor

        ForecastSummaryItemLabel {
            id: dayElem
            value: ""
            font.pixelSize: Theme.fontSizeSmall
        }

        Image {
            id: image
            width: 100
            height: Theme.itemSizeSmall
            fillMode: Image.PreserveAspectFit
            source: String("../../weather-icons/%1.svg").arg(0)
            verticalAlignment: Image.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 1
        }

        ForecastSummaryItemLabel {
            id: tempElem
            value: ""
            valueMax: ""
            unit: meteoApp.tempUnit
        }

        ForecastSummaryItemLabel {
            id: rainElem
            value: ""
            valueMax: ""
            unit: meteoApp.rainUnitShort
        }
    }

    function getRain(data) {
        function prep(value) {
            if (value < 1) {
                return Math.round(value*10)/10;
            } else {
                return Math.round(value);
            }
        }

        if (   !data
            || (data.minRain == undefined || data.maxRain == undefined)
            || data.minRain == 0 && data.maxRain == 0
        ) {
            return ["", ""];
        }

        return [prep(data.minRain), prep(data.maxRain)];
    }

    function getTemp(data) {
        if (!data || data.minTemp == undefined || data.maxTemp == undefined) {
            return ["", ""];
        } else {
            return [data.minTemp, data.maxTemp];
        }
    }

    function refreshData(data, locationToUpdate) {
        if (locationToUpdate && locationToUpdate != location) return;

        data = Storage.getDaySummary(location, day, meteoApp.noonHour);
        var rain = getRain(data);
        var temp = getTemp(data);

        image.source = String("../../weather-icons/%1.svg").arg(data.symbol);

        tempElem.value = temp[0];
        tempElem.valueMax = temp[1];
        tempElem.refresh();

        rainElem.value = rain[0];
        rainElem.valueMax = rain[1];
        rainElem.refresh();

        dayElem.value = data.timestamp.toLocaleString(Qt.locale(), "ddd");
        dayElem.refresh();

        if (data.timestamp.toDateString() == new Date().toDateString()) {
            opacity = 0.75
        }
    }

    Component.onCompleted: {
        refreshData();
        overviewPage.dataUpdated.connect(refreshData);
    }
}
