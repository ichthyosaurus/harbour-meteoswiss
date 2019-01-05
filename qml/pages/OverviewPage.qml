import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "components"

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings

Page {
    id: overviewPage

    function addLocationToModel(locationData, temperature, symbol) {
        if (!locationData) {
            console.log("error: failed to add location to model: invalid data")
            return
        }

        locationsModel.append({
            "locationId": locationData.locationId,
            "zip": locationData.zip,
            "name": locationData.name,
            "canton": locationData.canton,
            "cantonId": locationData.cantonId,
            "temperature": temperature,
            "symbol": symbol,
        })
    }

    function addLocation(locationData) {
        console.log("add location", locationData.locationId, locationData.name);

        var res = Storage.addLocation(locationData.locationId, locationData.zip, locationData.name, locationData.cantonId, locationData.canton, locationsModel.count);

        if (res > 0) {
            addLocationToModel(locationData, undefined, undefined)
        }

        meteoApp.refreshData(locationData.locationId, true)
    }

    SilicaListView {
        id: locationsListView

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Add location")
                onClicked: pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"))
            }

            MenuItem {
                text: qsTr("Refresh")
                visible: locationsModel.count > 0
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
            enabled: (locationsModel.count === 0)
            text: qsTr("Add a location first")
            hintText: qsTr("Pull down to add items")
        }

        model: ListModel { id: locationsModel }

        delegate: ListItem {
            id: locationItem

            function showRemoveRemorser() {
                var idx = index
                var loc = locationId

                remorse.execute(locationItem, qsTr("Deleting"), function() {
                    locationsModel.remove(idx)
                    Storage.removeLocation(loc)
                }, 3000);
            }

            RemorseItem { id: remorse }

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
                                pairs.push({ locationId: locationsModel.get(i).locationId, position: i })
                            }
                            Storage.setOverviewPositions(pairs)
                        }
                    }

                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: showRemoveRemorser()
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
                    "locationId": locationId,
                    "title": zip + " " + name + " (" + cantonId + ")",
                });
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
                    text: model.name + " (" + model.cantonId + ")"
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    id: descriptionLabel
                    property real lineHeight: height/lineCount

                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: Strings.MeteoLang.weatherSymbolDescription[model.symbol]  // weather string
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    wrapMode: Text.Wrap
                }
            }

            Label {
                id: temperatureLabel
                text: (model.temperature === undefined) ? '' : model.temperature + " °C"
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
                var summary = Storage.getDataSummary(locs[i].locationId)
                addLocationToModel(locs[i], summary.temperature, summary.symbol)
            }
        }

        VerticalScrollDecorator {}
    }

    function updateSingleSummary(locationId, index) {
        if (!locationId || index === undefined) return;
        var summary = Storage.getDataSummary(locationId);
        locationsModel.set(index, {temperature: summary.temp, symbol: summary.symbol});
    }

    function updateSummaries(newData, locationId) {
        if (locationId && !meteoApp.dataIsReady[locationId]) {
            console.log("summaries not updated: data is not ready yet", meteoApp.dataIsReady[locationId], locationId);
            return;
        } else {
            console.log("updating overview summaries...");
        }

        if (locationId) {
            for (var i = 0; i < locationsModel.count; i++) {
                if (locationsModel.get(i).locationId === locationId) {
                    updateSingleSummary(locationId, i);
                }
            }
        } else {
            for (var j = 0; j < locationsModel.count; j++) {
                updateSingleSummary(locationsModel.get(j).locationId, j)
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 60*15*1000 // every 15 minutes
        repeat: true
        running: true
        onTriggered: {
            if (overviewPage.status === PageStatus.Active) {
                meteoApp.refreshData(undefined, false);
            }
        }
    }

    onStatusChanged: {
        if (overviewPage.status === PageStatus.Active) {
            updateSummaries();
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(updateSummaries)
        meteoApp.locationAdded.connect(addLocation)
    }
}
