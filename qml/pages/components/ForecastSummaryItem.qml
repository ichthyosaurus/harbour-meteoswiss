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
    property int hour
    property int day
    property var clickedCallback

    width: parent.width/8
    height: column.height + Theme.paddingSmall

    signal summaryClicked(int hour, int symbol)
    onClicked: summaryClicked(hour, forecastData[day].temperature.datasets[0].symbols[hour])

    Component.onCompleted: {
        summaryClicked.connect(clickedCallback);

        if (   (   day == 0
                && meteoApp.dataTimestamp != undefined
                && meteoApp.dataTimestamp.toDateString() == new Date().toDateString()
                && hour == Storage.getCurrentSymbolHour())
            || hour == meteoApp.noonHour
        ) {
            summaryClicked(hour, forecastData[day].temperature.datasets[0].symbols[hour]);
        }
    }

    Column {
        id: column
        width: parent.width

        property var textColor: ((meteoApp.dataTimestamp && meteoApp.dataTimestamp.toDateString() == new Date().toDateString() && day == 0) ?
            (hour >= Storage.getCurrentSymbolHour() ? Theme.secondaryColor : Theme.secondaryHighlightColor) : Theme.secondaryColor)

        ForecastSummaryItemLabel {
            value: hour
            font.pixelSize: Theme.fontSizeSmall
        }

        Image {
            width: 100
            height: Theme.itemSizeSmall
            fillMode: Image.PreserveAspectFit
            source: "../../weather-icons/" + (
                forecastData[day].temperature.datasets[0].symbols[hour] != undefined ? forecastData[day].temperature.datasets[0].symbols[hour] : 0
            ) + ".svg"
            verticalAlignment: Image.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 1
        }

        ForecastSummaryItemLabel {
            value: forecastData[day].temperature.datasets[0].data[hour]
            unit: meteoApp.tempUnit
        }

        ForecastSummaryItemLabel {
            property var rain: forecastData[day].rainfall.haveData ? forecastData[day].rainfall.datasets[0].data[hour] : 0
            value: rain > 0 ? rain : ""
            unit: meteoApp.rainUnitShort
        }
    }
}
