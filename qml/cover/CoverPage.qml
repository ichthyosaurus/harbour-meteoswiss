/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings

CoverBackground {
    id: coverPage

    property bool haveLocation: locationId > 0
    property int locationId: meteoApp.coverData.locationId
    property var summary: meteoApp.coverData.summary
    property var locationData: meteoApp.coverData.locationData

    Label {
        id: label
        visible: !haveLocation
        anchors.centerIn: parent
        text: qsTr("MeteoSwiss")
    }

    Item {
        visible: (haveLocation ? true : false)
        width: parent.width - 2*Theme.paddingLarge

        Column {
            x: Theme.paddingLarge
            width: parent.width

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                text: (locationData ? (locationData.name ? (summary.temp ? summary.temp + " °C " + locationData.name : locationData.name) : '') : '')
                width: parent.width
                truncationMode: TruncationMode.Fade
            }

            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: summary.symbol ? Strings.weatherSymbolDescription[summary.symbol] || "" : ""  // weather string
                truncationMode: TruncationMode.Fade
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Image {
                x: Theme.paddingLarge
                width: parent.width - 2*x
                height: width
                sourceSize.width: width
                sourceSize.height: height
                source: "../weather-icons/" + (summary.symbol ? summary.symbol : "0") + ".svg"
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: meteoApp.setNextCoverLocation()
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../pages/LocationSearchPage.qml"))
                meteoApp.activate()
            }
        }
    }
}
