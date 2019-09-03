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
