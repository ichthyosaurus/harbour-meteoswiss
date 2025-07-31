/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

import MeteoSwiss.Locations 1.0
import Opal.Delegates 1.0

Page {
    id: root

    property string _query
    property var _queryRegex: new RegExp(_query, 'i')
    property Item _searchField

    on_QueryChanged: {
        LocationsModel.search = _query
        _searchField.forceActiveFocus()
    }

    function addLocation(token) {
        var details = {
            locationId: 0,
            altitude: 0,
            latitude: coords.north,
            longitude: coords.east,
            zip: parseInt(token.substr(0, 4), 10),
            name: token.substr(5, token.length-10),
            active: true,
        }
        meteoApp.locationAdded(details)
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: LocationsModel

        VerticalScrollDecorator {}

        ViewPlaceholder {
           enabled: !LocationsModel.haveDatabase
           text: qsTr("Database missing")
           hintText: qsTr("Try reinstalling the app.")
        }

        ViewPlaceholder {
            enabled: LocationsModel.haveDatabase &&
                     listView.count === 0
            hintText: qsTr("Type to find a location by " +
                           "name or by zip code.")
        }

        header: Column {
            width: root.width

            PageHeader {
                title: qsTr("Add Location")
            }

            SearchField {
                id: searchField
                width: parent.width
                enabled: LocationsModel.haveDatabase
                placeholderText: qsTr("Search")
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: root._query = text
                EnterKey.onClicked: {
                    if (!!text) searchField.focus = false
                }

                Component.onCompleted: {
                    _searchField = searchField
                }
            }
        }

        delegate: TwoLineDelegate {
            id: listItem
            text: Theme.highlightText(model.name, root._queryRegex, Theme.highlightColor)
            description: model.name !== model.primaryName ?
                model.primaryName : " "
            textLabel.font.pixelSize: Theme.fontSizeLarge
            descriptionLabel.font.pixelSize: Theme.fontSizeExtraSmall

            leftItem: DelegateInfoItem {
                alignment: Qt.AlignRight
                text: Theme.highlightText(model.zip, root._queryRegex, Theme.highlightColor)
                textLabel.palette {
                    primaryColor: Theme.secondaryColor
                    highlightColor: Theme.secondaryHighlightColor
                }

                description: model.altitude + "m"
                descriptionLabel.font.pixelSize: Theme.fontSizeExtraSmall
            }
        }
    }

//    SilicaFlickable {
//        anchors.fill: parent
//        contentHeight: column.height

//        VerticalScrollDecorator {}

//        PullDownMenu {
//            busy: false
//            visible: meteoApp.debug

//            MenuItem {
//                text: qsTr("Bootstrap debug locations")
//                onClicked: {
//                    addLocation("4001 Basel (BS)");
//                    addLocation("6600 Locarno (TI)");
//                    addLocation("7450 Tiefencastel (GR)");
//                    addLocation("3975 Randogne (VS)");
//                    addLocation("1470 Bollion (FR)");
//                }
//            }
//        }

//        Column {
//            id: column
//            width: searchPage.width

//            PageHeader {
//                title: qsTr("Add Location")
//            }

//            SearchField {
//                id: searchField
//                width: parent.width
//                placeholderText: qsTr("Search")
//                inputMethodHints: Qt.ImhNoPredictiveText

//                onTextChanged: listModel.update()

//                EnterKey.onClicked: {
//                    if (text != "") searchField.focus = false
//                }
//            }

//            Repeater {
//                width: parent.width

//                model: ListModel {
//                    id: listModel

//                    function update() {
//                        clear()

//                        if (searchField.text != "") {
//                            append(Locations.search(searchField.text));
//                        }
//                    }

//                    Component.onCompleted: update()
//                }

//                delegate: ListItem {
//                    Label {
//                        anchors {
//                            left: parent.left
//                            right: parent.right
//                            leftMargin: searchField.textLeftMargin
//                            rightMargin: searchField.textRightMargin
//                            verticalCenter: parent.verticalCenter
//                        }
//                        text: model.name
//                        truncationMode: TruncationMode.Fade
//                    }
//                    onClicked: {
//                        addLocation(model.name);
//                        pageStack.pop()
//                    }
//                }
//            }
//        }
//    }

    on_SearchFieldChanged: _searchField.forceActiveFocus()
    Component.onCompleted: {
        LocationsModel.search = ""
        _searchField && _searchField.forceActiveFocus()
    }
}
