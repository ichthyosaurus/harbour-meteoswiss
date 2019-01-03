import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "components"

import "../js/storage.js" as Storage

Page {
    id: overviewPage

    SilicaListView {
        id: locationsListView

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("New location")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"))
                    dialog.accepted.connect(function() {
                        if (   dialog.locationId
                            && dialog.name
                            && dialog.canton
                            && dialog.cantonId
                        ) {
                            Storage.addLocation(dialog.locationId, dialog.name, dialog.canton, dialog.cantonId, locationsModel.count)
                            locationsModel.append({
                                "locationId": dialog.locationId,
                                "name": dialog.name,
                                "canton": dialog.canton,
                                "cantonId": dialog.cantonId,
                                "savedTemperature": undefined,
                                "symbol": undefined,
                            })
                            meteoApp.refreshData(dialog.locationId, false)
                        } else {
                            console.log("error: failed to add location (invalid info given)")
                        }
                    })
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    meteoApp.refreshData(undefined, false)
                    refreshTimer.restart()
                }
            }
        }

        anchors.fill: parent

        header: PageHeader {
            title: qsTr("MeteoSwiss")
        }

        ViewPlaceholder {
            enabled: (locationsModel.count == 0)
            text: qsTr("Add a location first")
            hintText: qsTr("Pull down to add items")
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
                    property int locationId: model.locationId

                    onMenuOpenChanged: {
                        if (!menuOpen && moveItemsWhenClosed) {
                            locationsModel.move(model.index, 0, 1)
                            moveItemsWhenClosed = false

                            var pairs = []
                            for (var i = 0; i < locationsModel.count; i++) {
                                pairs.push({ zip: locationsModel.get(i).locationId, position: i })
                            }
                            Storage.setOverviewPositions(pairs)
                        }
                    }

                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: {
                            remove()
                            Storage.removeLocation(locationId)
                        }
                    }

                    MenuItem {
                        text: "Move to top"
                        visible: model.index !== 0
                        onClicked: moveItemsWhenClosed = true
                    }
                }
            }

            contentHeight: labelColumn.implicitHeight + 2*Theme.paddingMedium

            onClicked: {
                meteoApp.refreshData(locationId, false)
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
                    truncationMode: TruncationMode.Fade
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
            console.log("loading all known locations...")
            var locs = Storage.getLocationData()
            for (var i = 0; i < locs.length; i++) {
                var summary = Storage.getDataSummary(locs[i].zip)

                locationsModel.append({
                    "locationId": locs[i].zip,
                    "name": locs[i].name,
                    "canton": locs[i].canton,
                    "cantonId": locs[i].cantonId,
                    "savedTemperature": summary.temp,
                    "symbol": summary.symbol,
                })
            }
        }

        VerticalScrollDecorator {}
    }

    function updateSummaries() {
        console.log("DEBUG updating overview summaries")
        for (var i = 0; i < locationsModel.count; i++) {
            var loc = locationsModel.get(i).locationId
            var summary = Storage.getDataSummary(loc)
            locationsModel.get(i).savedTemperature = summary.temp
            locationsModel.get(i).symbol = summary.symbol
        }
    }

    Timer {
        id: refreshTimer
        interval: 60*30*1000 // every 1/2 hour
        repeat: true
        running: true
        onTriggered: meteoApp.refreshData(undefined, false)
    }

    onStatusChanged: {
        if (overviewPage.status == PageStatus.Active) {
            updateSummaries()
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(updateSummaries)
    }
}
