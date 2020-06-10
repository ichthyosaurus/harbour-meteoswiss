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

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../../js/strings.js" as Strings


SilicaListView {
    id: table
    width: parent.width
    height: (showAll ? 24 : 8) * Theme.itemSizeSmall
    x: Theme.horizontalPageMargin

    property var forecastData
    property bool showAll: false
    signal toggleShowAll

    onToggleShowAll: {
        showAll = !showAll
    }

    Behavior on opacity { NumberAnimation { duration: 500 } }
    opacity: tablePage.loaded ? 1 : 0
    visible: tablePage.loaded ? true : false

    model: ListModel {
        ListElement {
            // This is here to enforce the correct types.
            // It will be removed when the real data is loaded.
            hour: 1
            image: 1; description: ''
            temp: ''; rain: '';
            wind: ''; windSym: ''
        }
    }

    delegate: Item {
        width: Screen.height
        height: opacity > 0 ? Theme.itemSizeSmall : 0

        opacity: (   hour == 2
                  || hour == 5
                  || hour == 8
                  || hour == 11
                  || hour == 14
                  || hour == 17
                  || hour == 20
                  || hour == 23
                  || showAll) ? 1.0 : 0.0

        Behavior on height { NumberAnimation { duration: 100 } }
        Behavior on opacity { NumberAnimation { duration: 50 } }

        Row {
            width: parent.width
            x: parent.x

            spacing: Theme.paddingLarge

            Label {
                id: hourLabel
                width: hourTitle.width
                text: hour
                font.pixelSize: Theme.fontSizeSmall
            }

            Image {
                width: symbolTitle.width
                height: Theme.itemSizeSmall
                fillMode: Image.PreserveAspectFit
                source: "../../weather-icons/" + image + ".svg"
                verticalAlignment: Image.AlignVCenter
                anchors.verticalCenter: hourLabel.verticalCenter
                opacity: 1
            }

            TableListValueElement {
                base: tempTitle
                text: temp
                unit: meteoApp.tempUnit
            }

            TableListValueElement {
                base: rainTitle
                text: (rain > 0.0) ? rain : ''
                unit: meteoApp.rainUnit
            }

            TableListValueElement {
                base: windTitle
                text: wind
                unit: meteoApp.windUnit
            }

            TableListValueElement {
                visible: isLandscape
                base: windSymTitle
                text: windSym
            }

            Label {
                visible: isLandscape
                x: descriptionTitle.x - Theme.paddingLarge
                width: descriptionTitle.width - Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: description ? description : ""
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                toggleShowAll()
            }
        }
    }

    function _rounded(value) {
        var prec = 1;
        /*if (String(Number(value).toPrecision(prec)).match(/\.0+$/) !== null) {
            prec = 0;
        }*/
        return Number(value).toLocaleString(Qt.locale(), 'f', prec);
    }

    function refreshModel() {
        rain = forecastData[day].rainfall
        temp = forecastData[day].temperature
        wind = forecastData[day].wind

        model.clear()

        for (var i = 0; i < 24; i++) {
            model.append({
                "hour": i,
                "image": temp.datasets[0].symbols[i],
                "temp": _rounded(temp.datasets[0].data[i]),
                "rain": _rounded(rain.datasets[0].data[i]),
                "wind": _rounded(wind.datasets[0].data[i]),
                "windSym": wind.datasets[0].symbols[i],
                "description": Strings.weatherSymbolDescription[temp.datasets[0].symbols[i]],
            })
        }
    }
}
