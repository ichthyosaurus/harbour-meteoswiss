/*
 * This file is part of harbour-meteoswiss.
 * Copyright (C) 2018-2019  Mirian Margiani
 *
 * harbour-meteoswiss is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-meteoswiss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
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
