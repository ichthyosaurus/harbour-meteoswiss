/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"


Page {
    id: mainPage
    property int locationId
    property int activeDay: 0
    property alias title: pageTitle.title
    allowedOrientations: Orientation.All

    signal activateGraph(int dayId)

    SilicaFlickable {
        contentHeight: (column.visible ? column.height : Screen.width - Theme.horizontalPageMargin) + Theme.horizontalPageMargin

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: isLandscape ? parent.bottom : summaryRow.top
        }

        clip: true

        PullDownMenu {
            MenuItem {
                text: qsTr("Reload Data")
                onClicked: {
                    meteoApp.refreshData(locationId, true)
                }
            }
            MenuItem {
                text: qsTr("Table view")
                onClicked: {
                    if (meteoApp.dataIsReady[locationId]) {
                        meteoApp.refreshTableModel(locationId)
                        pageStack.push(Qt.resolvedUrl("TablePage.qml"), {
                            locationId: locationId,
                            day: 0
                        })
                    } else {
                        console.log("table locked")
                    }
                }
            }
        }

        Column {
            id: column
            width: parent.width
            visible: (meteoApp.dataIsReady[locationId] && !meteoApp.forecastData[0].isSane) ? false : true

            PageHeader {
                id: pageTitle
            }

            Repeater {
                model: meteoApp.forecastData.length

                ForecastItem {
                    dayId: index
                    active: (activeDay == index)
                    visible: active || isLandscape

                    Component.onCompleted: {
                        mainPage.activateGraph.connect(function(newDay) {
                            active = (dayId == newDay);
                        })
                    }
                }
            }

            VerticalScrollDecorator {}
        }

        Item {
            id: failedColumn
            anchors.fill: parent
            visible: !column.visible

            PageHeader {
                title: qsTr("MeteoSwiss")
            }

            Label {
                x: Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Failed to load data!")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            VerticalScrollDecorator {}
        }
    }

    Row {
        id: summaryRow
        width: parent.width
        y: (Screen.height - height)
        visible: isPortrait

        Repeater {
            model: meteoApp.forecastData.length

            DaySummaryItem {
                location: locationId
                day: index
                timestamp: new Date(meteoApp.forecastData[index].date)
                dayCount: meteoApp.forecastData.length
                selected: (index == activeDay)

                Component.onCompleted: {
                    summaryClicked.connect(function(newDay, loc) {
                        activateGraph(newDay);
                    })
                    mainPage.activateGraph.connect(function(newDay) {
                        selected = (newDay == day);
                    })
                }

                Binding on highlighted {
                    when: selected || down
                    value: true
                }
            }
        }
    }

    Rectangle {
        anchors.fill: summaryRow
        z: -1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.3) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.1) }
        }
    }
}
