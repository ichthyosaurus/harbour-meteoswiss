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

import QtQuick 2.6
import Sailfish.Silica 1.0
import "components"

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings
import "../sf-about-page/about.js" as About

Page {
    id: overviewPage
    allowedOrientations: Orientation.All

    signal loadingFinished(var locationId)
    signal dataUpdated(var newData, var locationId)

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
                onClicked: About.pushAboutPage(pageStack)
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
            asynchronous: false
            visible: status == Loader.Ready
            width: (isPortrait ? Screen.width : Screen.height)

            sourceComponent: OverviewListDelegate {
                parentModel: locationsModel

                Component.onCompleted: {
                    loadingFinished.connect(function(loc) {
                        if (locationId === loc) {
                            refreshWeekSummary();
                        }
                    });
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


        for (var i = locationsModel.count-1; i >= 0; i--) {
            if (!locationId || (locationId === locationsModel.get(i).locationId)) {
                console.log("updating overview summary... " + i);
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
