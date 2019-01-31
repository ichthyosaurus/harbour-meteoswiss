import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../../js/storage.js" as Storage

BackgroundItem {
    property int day
    property int location
    property var data

    property bool primary: false
    property bool selected: false
    property bool isToday: false

    width: parent.width/6
    height: column.height + Theme.paddingSmall

    signal summaryClicked(int day, int location)

    onClicked: {
        if (day != undefined && location != undefined) {
            summaryClicked(day, location);
        }
    }

    Item {
        anchors.fill: parent
        clip: true

        Rectangle {
            rotation: (Math.atan(parent.width/parent.height) * 180) / Math.PI // diagonal
            width: parent.width * Math.ceil(parent.height/parent.width)
            height: parent.height * Math.ceil(parent.height/parent.width)
            x: parent.width - width

            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.rgba(Theme.secondaryColor, 0) }
                GradientStop { position: 1.0; color: Theme.rgba(Theme.secondaryColor, 0.15) }
            }
        }
    }

    Column {
        id: column
        width: parent.width

        property var textColor: (primary ? Theme.highlightColor :
            (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor))

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
            opacity: (primary ? 0.8 : (isToday ? 0.8 : 0.65))
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

        if (data.timestamp.toDateString() == new Date().toDateString()) {
            isToday = true;
        }

        dayElem.value = isToday ? qsTr("Today") : data.timestamp.toLocaleString(Qt.locale(), "ddd");
        dayElem.refresh();
    }

    Component.onCompleted: {
        refreshData();
    }
}
