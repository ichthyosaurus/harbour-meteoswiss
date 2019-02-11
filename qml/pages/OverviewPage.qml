import QtQuick 2.6
import Sailfish.Silica 1.0
import "components"

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings

Page {
    id: overviewPage

    signal loadingFinished(var locationId)
    signal dataUpdated(var newData, var locationId)

    function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

    function getTemperatureString(temperature) {
        return (temperature === undefined) ? "" : temperature + " °C";
    }

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
            "temperatureString": getTemperatureString(temperature),
            "symbol": symbol,
        })
    }

    function addLocation(locationData) {
        console.log("add location", locationData.locationId, locationData.name);

        var res = Storage.addLocation(locationData, locationsModel.count);

        if (res > 0) {
            addLocationToModel(locationData, undefined, undefined)
        }

        meteoApp.refreshData(locationData.locationId, true)
    }

    SilicaListView {
        id: locationsListView

        PullDownMenu {
            id: pulley
            busy: false

            Component.onCompleted: {
                overviewPage.dataUpdated.connect(function(newData, locationId) {
                    var readyList = Object.keys(meteoApp.dataIsReady).map(function(k) { return meteoApp.dataIsReady[k]; });
                    if (readyList.every(function(k) { return k ? true : false; })) {
                        busy = false
                    }
                });
                meteoApp.dataIsLoading.connect(function() { busy = true; });
            }

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
                    meteoApp.refreshData(undefined, false);
                }
            }

            Label {
                id: clockLabel
                text: new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        anchors.fill: parent

        header: PageHeader {
            title: qsTr("MeteoSwiss")
        }

        ViewPlaceholder {
            id: placeholder
            enabled: (locationsModel.count === 0 && Storage.getLocationsCount() === 0)
            text: qsTr("Add a location first")
            hintText: qsTr("Pull down to add items")
        }

        property int itemCount: locationsModel.count
        onItemCountChanged: {
            if (itemCount === 0) placeholder.enabled = true;
        }

        ListModel {
            id: locationsModel
        }

        model: locationsModel

        delegate: Loader {
            asynchronous: true
            visible: status == Loader.Ready
            width: (isPortrait ? Screen.width : Screen.height)

            sourceComponent: OverviewListDelegate {
                parentModel: locationsModel
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

    Timer {
        id: clockTimer
        interval: 15*1000
        repeat: true
        running: true
        onTriggered: {
            clockLabel.text = new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
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
            dataUpdated(undefined, undefined);
        }
    }

    onDataUpdated: {
        if (locationId && !meteoApp.dataIsReady[locationId]) {
            console.log("summary not updated: data is not ready yet", meteoApp.dataIsReady[locationId], locationId);
            return;
        }

        console.log("updating overview summaries...");

        for (var i = 0; i < locationsModel.count; i++) {
            if (!locationId || (locationId === locationsModel.get(i).locationId)) {
                var loc = locationsModel.get(i).locationId;
                var summary = Storage.getDataSummary(loc);
                locationsModel.setProperty(i, 'temperatureString', getTemperatureString(summary.temp));
                locationsModel.setProperty(i, 'symbol', summary.symbol);
                loadingFinished(loc);
            }
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(dataUpdated)
        meteoApp.locationAdded.connect(addLocation)
    }
}
