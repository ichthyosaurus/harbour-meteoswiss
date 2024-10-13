/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage

BackgroundItem {
    property int day
    property var timestamp
    property int location
    property var data
    property int dayCount

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

    Column {
        id: column
        width: parent.width

        property var textColor: (selected ? Theme.highlightColor :
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
            opacity: (selected || highlighted) ? 1.0 : 0.5
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
        if (locationToUpdate && locationToUpdate !== location) return;

        var meta = Storage.getLatestMetadata(location);

        if (meta) {
            dayCount = meta.dayCount;
            if (day < dayCount) timestamp = new Date(meta.dayDates[day]);
        } else {
            console.log("error: no data to show in day overview");
            return;
        }

        if (timestamp !== undefined && timestamp.toDateString() === new Date().toDateString()) {
            isToday = true;
        } else {
            isToday = false;
        }

        data = Storage.getDaySummary(location, timestamp, day);

        dayElem.value = isToday ? qsTr("Today") : (timestamp !== undefined ? timestamp.toLocaleString(Qt.locale(), "ddd") : "");
        dayElem.refresh();

        image.source = String("../../weather-icons/%1.svg").arg(data.symbol);

        tempElem.value = (data.minTemp !== undefined ? data.minTemp : "");
        tempElem.valueMax = (data.maxTemp !== undefined ? data.maxTemp : "");;
        tempElem.refresh();

        rainElem.value = (data.precipitation !== undefined ? data.precipitation : "");;
        rainElem.refresh();

        console.log("---> refresh", day, timestamp, locationId)
    }

    Component.onCompleted: {
        refreshData();
        meteoApp.weekSummaryUpdated.connect(refreshData);
    }
}
