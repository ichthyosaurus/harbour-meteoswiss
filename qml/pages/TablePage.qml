/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: tablePage
    property string name
    property int day
    property var rain
    property var temp
    property var wind
    property bool loaded: false
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Detailed Forecast")
            }

            Label {
                id: title
                x: Theme.horizontalPageMargin
                text: name
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Row {
                id: headers
                width: parent.width
                x: parent.x

                spacing: Theme.paddingLarge
                padding: Theme.horizontalPageMargin

                TablePageColumnTitle {
                    id: hourTitle
                    width: 70
                    text: qsTr("Hour")
                }

                TablePageColumnTitle {
                    id: symbolTitle
                    width: 100
                }

                TablePageColumnTitle {
                    id: tempTitle
                    width: 200
                    text: qsTr("Temp.")
                    unit: meteoApp.tempUnit
                }

                TablePageColumnTitle {
                    id: rainTitle
                    width: 250
                    text: qsTr("Precip.")
                    unit: meteoApp.rainUnit
                }

                TablePageColumnTitle {
                    id: windTitle
                    width: 230
                    text: qsTr("Wind")
                    unit: meteoApp.windUnit
                }

                TablePageColumnTitle {
                    id: windSymTitle
                    visible: isLandscape
                    width: 100
                }

                TablePageColumnTitle {
                    id: descriptionTitle
                    visible: isLandscape
                    width: 500
                    text: qsTr("Description")
                }
            }

            Column {
                id: waitingForData
                width: tablePage.width

                Behavior on opacity { NumberAnimation { duration: 500 } }
                opacity: tablePage.loaded ? 0 : 1
                visible: tablePage.loaded ? false : true

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: !tablePage.loaded
                    size: BusyIndicatorSize.Medium
                }
            }

            Loader {
                id: tableLoader
                onLoaded: {
                    tablePage.loaded = true
                    item.refreshModel()
                }
            }

            VerticalScrollDecorator {}
        }
    }

    function loadTable(msgData) {
        if (day === null) return
        console.log("loading table for day " + day + "...")
        tableLoader.setSource("../components/TableList.qml", {
            width: parent.width,
            forecastData: msgData ? msgData : meteoApp.forecastData
        })
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(loadTable)
        meteoApp.dataIsLoading.connect(function(){ if (tablePage) tablePage.loaded = false })

        if (meteoApp.dataIsReady) {
            loadTable()
        }
    }
}
