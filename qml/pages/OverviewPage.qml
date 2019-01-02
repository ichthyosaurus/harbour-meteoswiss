import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "components"

import "../js/storage.js" as Storage

Page {
    SilicaListView {
        id: locationsListView

        PullDownMenu {
            MenuItem {
                text: qsTrId("About")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTrId("New location")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("LocationSearchPage.qml"))
            }

            MenuItem {
                text: qsTrId("Refresh")
                onClicked: reloadTimer.restart()

                Timer {
                    id: reloadTimer
                    interval: 60*60*1000
                    onTriggered: meteoApp.refreshData()
                }
            }
        }

        anchors.fill: parent

        header: PageHeader {
            title: qsTrId("MeteoSwiss")
        }

        model: ListModel { id: locationsModel }

        delegate: ListItem {
            id: locationItem

            function remove() {
                locationsModel.remove(model.index)
            }

            ListView.onAdd: AddAnimation { target: locationItem }
            ListView.onRemove: animateRemoval()

            menu: contextMenuComp

            Component {
                id: contextMenuComp
                ContextMenu {
                    property bool moveItemsWhenClosed
                    property bool menuOpen: height > 0

                    onMenuOpenChanged: {
                        if (!menuOpen && moveItemsWhenClosed) {
                            locationsModel.moveToTop(model.index)
                            moveItemsWhenClosed = false
                        }
                    }

                    MenuItem {
                        text: qsTrId("Remove")
                        onClicked: remove()
                    }

                    // MenuItem {
                    //     text: "Move to top"
                    //     visible: model.index !== 0
                    //     onClicked: moveItemsWhenClosed = true
                    // }
                }
            }

            contentHeight: labelColumn.implicitHeight + 2*Theme.paddingMedium

            onClicked: {
                meteoApp.refreshData(locationId)
                pageStack.animatorPush("ForecastPage.qml", {
                    "activeDay": 0,
                    "location": locationId,
                    "title": model.locationId + " " + model.name + " (" + model.cantonId + ")",
                })
            }

            Image {
                id: icon
                visible: model.symbol ? true : false
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: labelColumn.verticalCenter
                width: 2.5*Theme.horizontalPageMargin
                height: width
                source: "../weather-icons/" + (model.symbol ? model.symbol : "0") + ".svg"
            }

            Column {
                id: labelColumn

                y: Theme.paddingMedium
                height: locationLabel.height + descriptionLabel.lineHeight

                anchors {
                    left: icon.right
                    right: temperatureLabel.left
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                }

                Label {
                    id: locationLabel
                    width: parent.width
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: model.name
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    id: descriptionLabel
                    property real lineHeight: height/lineCount

                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: model.locationId + " - " + model.canton + " (" + model.cantonId + ")"
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                }
            }

            Label {
                id: temperatureLabel
                text: model.savedTemperature ? model.savedTemperature + " °C" : ''
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeHuge

                anchors {
                    verticalCenter: labelColumn.verticalCenter
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
            }
        }

        Component.onCompleted: {
            Storage.addLocation(4143, "Dornach", "Solothurn", "SO")
            Storage.addLocation(4001, "Basel", "Basel-Stadt", "BS")
            Storage.addLocation(8001, "Zürich", "Zürich", "ZH")

            console.log("loading all known locations...")
            var locs = Storage.getLocationData()
            for (var i = 0; i < locs.length; i++) {
                locationsModel.append({
                    "locationId": locs[i].zip,
                    "name": locs[i].name,
                    "canton": locs[i].canton,
                    "cantonId": locs[i].cantonId,
                    "savedTemperature": null,
                    "symbol": null,
                })
            }
        }

        VerticalScrollDecorator {}
    }
}
