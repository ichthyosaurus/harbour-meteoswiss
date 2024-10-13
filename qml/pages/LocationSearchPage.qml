/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/locations.js" as Locations

Page {
    id: searchPage
    Component.onCompleted: searchField.forceActiveFocus()

    function addLocation(token) {
        var details = Locations.getDetails(token)
        meteoApp.locationAdded(details)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        PullDownMenu {
            busy: false
            visible: meteoApp.debug

            MenuItem {
                text: qsTr("Bootstrap debug locations")
                onClicked: {
                    addLocation("4001 Basel (BS)");
                    addLocation("6600 Locarno (TI)");
                    addLocation("7450 Tiefencastel (GR)");
                    addLocation("3975 Randogne (VS)");
                    addLocation("1470 Bollion (FR)");
                }
            }
        }

        Column {
            id: column
            width: searchPage.width

            PageHeader {
                title: qsTr("Add Location")
            }

            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Search")
                inputMethodHints: Qt.ImhNoPredictiveText

                onTextChanged: listModel.update()

                EnterKey.onClicked: {
                    if (text != "") searchField.focus = false
                }
            }

            Repeater {
                width: parent.width

                model: ListModel {
                    id: listModel

                    function update() {
                        clear()

                        if (searchField.text != "") {
                            append(Locations.search(searchField.text));
                        }
                    }

                    Component.onCompleted: update()
                }

                delegate: ListItem {
                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                            leftMargin: searchField.textLeftMargin
                            rightMargin: searchField.textRightMargin
                            verticalCenter: parent.verticalCenter
                        }
                        text: model.name
                        truncationMode: TruncationMode.Fade
                    }
                    onClicked: {
                        addLocation(model.name);
                        pageStack.pop()
                    }
                }
            }
        }
    }
}
