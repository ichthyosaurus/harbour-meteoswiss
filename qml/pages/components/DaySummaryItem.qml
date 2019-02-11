import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage

BackgroundItem {
    property int day
    property var timestamp
    property int location
    property var data
    property int dayCount

    property bool primary: false
    property bool selected: false
    property bool isToday: false

    width: dayCount > 0 ? parent.width/dayCount : 0
    height: column.height + Theme.paddingSmall

    visible: day < dayCount

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
            opacity: (primary ? 0.8 : (isToday ? 0.9 : 0.7))
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

    function refreshData(data, locationToUpdate) {
        if (locationToUpdate && locationToUpdate != location) return;

        var meta = Storage.getLatestMetadata(location);

        if (meta) {
            dayCount = meta.dayCount;
            if (day < dayCount) timestamp = new Date(meta.dayDates[day]);
        } else {
            console.log("error: no data to show in day overview");
            return;
        }

        if (timestamp != undefined && timestamp.toDateString() == new Date().toDateString()) {
            isToday = true;
        } else {
            isToday = false;
        }

        data = Storage.getDaySummary(location, timestamp);

        dayElem.value = isToday ? qsTr("Today") : (timestamp != undefined ? timestamp.toLocaleString(Qt.locale(), "ddd") : "");
        dayElem.refresh();

        image.source = String("../../weather-icons/%1.svg").arg(data.symbol);

        tempElem.value = (data.minTemp != undefined ? data.minTemp : "");
        tempElem.valueMax = (data.maxTemp != undefined ? data.maxTemp : "");;
        tempElem.refresh();

        rainElem.value = (data.precipitation != undefined ? data.precipitation : "");;
        rainElem.refresh();
    }

    Component.onCompleted: {
        refreshData();
        meteoApp.weekSummaryUpdated.connect(refreshData);
    }
}
