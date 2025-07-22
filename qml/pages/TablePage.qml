/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Opal.Delegates 1.0
import "../js/strings.js" as Strings
import "../js/storage.js" as Storage
import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    property int locationId
    property int day

    readonly property string title: {
        var loc = Storage.getLocationData(locationId)[0]
        String("%1 %2 (%3)").arg(loc.zip).arg(loc.name).arg(loc.cantonId)
    }

    readonly property bool _haveData: meteoApp.forecastTable.count > 0
    readonly property QtObject _cw: QtObject {
        readonly property int spacing: Theme.paddingSmall
        readonly property int hour: 5 * _em
        readonly property int icon: Theme.iconSizeMedium
        readonly property int temperature: 12 * _em
        readonly property int rain: 12 * _em
        readonly property int rainChance: 6 * _em
        readonly property int sun: 6 * _em
        readonly property int wind: 12 * _em
        readonly property int gusts: 12 * _em
        readonly property int windDirection: 4 * _em
        readonly property int description: 20 * _em
    }
    readonly property int _em: emMetrics.width

    TextMetrics {
        id: emMetrics
        font {
            pixelSize: Theme.fontSizeMedium
            family: Theme.fontFamily
        }
        text: "M"
    }

    PageHeader {
        id: header
        title: root.title
        description: qsTr("Detailed Forecast")

        Label {
            parent: header.extraContent
            anchors {
                left: parent.left
                top: parent.top
                topMargin: header._descriptionLabel.y
            }
            width: header.extraContent.width
            text: new Date(itemList.currentSection).toLocaleString(Qt.locale(), meteoApp.fullDateFormat)
            color: Theme.secondaryHighlightColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    SilicaFlickable {
        id: headerFlick
        visible: _haveData
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: horizontalFlick.contentWidth
        contentX: horizontalFlick.contentX
        height: Theme.itemSizeSmall
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: header.height + Theme.paddingMedium
        }

        Row {
            id: headerRow
            width: childrenRect.width + 2*padding
            anchors.bottom: parent.bottom
            bottomPadding: Theme.paddingMedium
            leftPadding: Theme.horizontalPageMargin
            rightPadding: leftPadding
            spacing: _cw.spacing

            Label {
                width: _cw.hour
                text: qsTr("Hour")
                font.pixelSize: Theme.fontSizeMedium
                font.family: Theme.fontFamilyHeading
                color: Theme.highlightColor
            }

            Item {
                width: _cw.icon
                height: 1
            }

            Label {
                width: _cw.temperature
                text: qsTr("Temperature")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                font.family: Theme.fontFamilyHeading
                color: Theme.highlightColor
            }

            Label {
                width: _cw.rain
                text: qsTr("Precipitation")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                font.family: Theme.fontFamilyHeading
                color: Theme.highlightColor
            }

            Item {
                width: _cw.rainChance
                height: 1
            }

            Label {
                width: _cw.sun
                text: qsTr("Sun", "short for “Sunshine” in a narrow table header")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                font.family: Theme.fontFamilyHeading
                color: Theme.highlightColor
            }

            Label {
                width: _cw.wind
                text: qsTr("Wind")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                font.family: Theme.fontFamilyHeading
                color: Theme.highlightColor
            }

            Label {
                width: _cw.gusts
                text: qsTr("Gusts")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                font.family: Theme.fontFamilyHeading
                color: Theme.highlightColor
            }

            Item {
                width: _cw.windDirection
                height: 1
            }

            Item {
                width: _cw.description
                height: 1
            }
        }
    }

    SilicaFlickable {
        id: horizontalFlick
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: itemList.contentWidth
        HorizontalScrollDecorator { flickable: horizontalFlick }

        clip: true
        anchors {
            left: parent.left
            right: parent.right
            top: headerFlick.bottom
            bottom: parent.bottom
            bottomMargin: 0
        }

        ViewPlaceholder {
            enabled: !_haveData
            text: qsTr("No data available")
            hintText: qsTr("Check your internet connection and refresh.")
        }

        SilicaListView {
            id: itemList
            anchors.fill: parent
            model: meteoApp.forecastTable
            contentWidth: _haveData ? headerRow.width : root.width

            footer: Item {
                width: parent.width
                height: Theme.horizontalPageMargin
            }

            section {
                property: "date"
                criteria: ViewSection.FullString
                // labelPositioning: ViewSection.CurrentLabelAtStart
                delegate: Component {
                    SectionHeader {
                        x: horizontalFlick.contentX + Theme.horizontalPageMargin
                        horizontalAlignment: Text.AlignLeft
                        text: new Date(section).toLocaleString(Qt.locale(), meteoApp.fullDateFormat)
                    }
                }
            }

            VerticalScrollDecorator {
                visible: horizontalFlick.contentWidth > horizontalFlick.width
                anchors.right: undefined // places scrollbar on the left
                flickable: itemList
            }

            VerticalScrollDecorator { flickable: itemList }

            delegate: PaddedDelegate {
                width: 2000
                showOddEven: true
                minContentHeight: Math.max(Theme.itemSizeSmall, Theme.iconSizeMedium)
                opacity: ((model.hour >= new Date().getHours())) ? 1.0 : 0.6
                _showPress: true
                _backgroundColor: model.hour == (new Date().getHours()) ?
                    Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) :
                    "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    width: childrenRect.width
                    spacing: _cw.spacing

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        width: _cw.hour
                        text: {
                            var d = new Date()
                            d.setHours(model.hour)
                            d.toLocaleTimeString(Qt.locale(), "HH:00")
                        }
                        color: Theme.highlightColor
                        verticalAlignment: Text.AlignVCenter
                    }

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        width: _cw.icon
                        height: width
                        sourceSize {
                            width: width
                            height: height
                        }
                        source: Qt.resolvedUrl("../weather-icons/%1.svg".arg(model.icon))
                    }

                    MinMaxTableItem {
                        width: _cw.temperature
                        expected: model.tempExpected
                        min: model.tempMin
                        max: model.tempMax
                        unit: meteoApp.tempUnit
                    }

                    MinMaxTableItem {
                        width: _cw.rain
                        hideZero: true
                        expected: model.rainExpected
                        min: model.rainMin
                        max: model.rainMax
                        unit: meteoApp.rainUnitShort
                    }

                    Label {
                        width: _cw.rainChance
                        text: model.rainChance === Infinity ?
                                  "" : "%1%".arg(model.rainChance)
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: Qt.tint(Theme.primaryColor, "#900000FF")
                        opacity: (model.rainChance || 0) / 100 + 0.3
                    }

                    MinMaxTableItem {
                        width: _cw.sun
                        precision: 0
                        expected: model.sun
                        min: model.sun
                        max: model.sun
                        unit: meteoApp.sunUnit
                        primaryColor: Qt.tint(Theme.primaryColor, "#90FFFF00")
                        opacity: (model.sun || 0) / 60 + 0.3
                    }

                    MinMaxTableItem {
                        width: _cw.wind
                        hideZero: true
                        expected: model.windExpected
                        min: model.windMin
                        max: model.windMax
                        unit: meteoApp.windUnit
                    }

                    MinMaxTableItem {
                        width: _cw.gusts
                        hideZero: false
                        expected: model.gustsExpected
                        min: model.gustsMin
                        max: model.gustsMax
                        unit: meteoApp.windUnit
                    }

                    Column {
                        width: _cw.windDirection
                        height: Math.max(childrenRect.height, 1)
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            visible: model.windDirection !== Infinity
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Theme.fontSizeMedium
                            height: width
                            font.family: "monospace"
                            text: "↑"
                            color: Theme.secondaryColor
                            rotation: 180+(model.windDirection || 0.0)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Label {
                            visible: model.windDirection !== Infinity
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.windDirection + "°"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            horizontalAlignment: Text.AlignHCenter
                            color: Theme.secondaryHighlightColor
                        }
                    }

                    Label {
                        width: _cw.description
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: Strings.weatherSymbolDescription[model.icon] || ""
                    }
                }
            }
        }
    }
}
