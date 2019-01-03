import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/locations-overview.js" as Locations
import "../js/locations-details.js" as LocationDetails
import "../js/cantons.js" as Cantons

Page {
    id: searchPage
    Component.onCompleted: searchField.forceActiveFocus()

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

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
                        for (var i = 0; i < Locations.LocationsList.length; i++) {
                            if (searchField.text != "" && Locations.LocationsList[i].indexOf(searchField.text) >= 0) {
                                append({
                                    "name": Locations.LocationsList[i],
                                })
                            }
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
                        var details = LocationDetails.get(model.name)
                        details.canton = Cantons.Cantons[details.cantonId]

                        meteoApp.locationAdded(details)
                        pageStack.pop()
                    }
                }
            }
        }
    }
}
