/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.About 1.0 as A
import Opal.SupportMe 1.0 as M
import Opal.LocalStorage 1.0 as L
import "pages"

import "js/forecast.js" as Forecast
import "js/storage.js" as Storage

ApplicationWindow {
    id: meteoApp

    initialPage: entryPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    signal dataLoaded(var data, var locationId)
    signal dataIsLoading(var locationId)
    signal refreshData(var location, var force)
    signal locationAdded(var locationData)
    signal locationDisabled(var locationId)
    signal weekSummaryUpdated()

    // ATTENTION set to "false" before release
    property bool debug: false

    property var forecastData: []
    property ListModel forecastTable: ListModel {
        ListElement {
            // This is here to enforce the correct types.
            // It will be removed when the real data is loaded.
            date: ''
            hour: 0
            icon: 0
            tempExpected: 0
            tempMin: 0
            tempMax: 0
            rainExpected: 0
            rainMin: 0
            rainMax: 0
            rainChance: 0
            windExpected: 0
            windMin: 0
            windMax: 0
            windDirection: 0
            gustsExpected: 0
            gustsMin: 0
            gustsMax: 0
            sun: 0
        }
    }
    property var dataIsReady: ({})
    property var dataTimestamp: new Date(0)
    property var overviewTimestamp: new Date(0)

    property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
    property string dateFormat: qsTr("d MMM yyyy")
    property string timeFormat: qsTr("hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")

    property string tempUnit: "°C"
    property string rainUnit: "mm/h"
    property string rainUnitShort: "mm"
    property string sunUnit: "min/h"
    property string windUnit: "km/h"

    property bool haveWallClock: wallClock != null
    property QtObject wallClock

    property var symbolHours: [2,5,8,11,14,17,20,23]
    property int noonHour: symbolHours[((symbolHours.length - symbolHours.length%2)/2)-1]

    // We have to explicitly set the \c _defaultPageOrientations property
    // to \c Orientation.All so the page stack's default placeholder page
    // will be allowed to be in landscape mode. (The default value is
    // \c Orientation.Portrait.) Without this setting, pushing multiple pages
    // to the stack using \c animatorPush() while in landscape mode will cause
    // the view to rotate back and forth between orientations.
    // [as of 2021-02-17, SFOS 3.4.0.24, sailfishsilica-qt5 version 1.1.110.3-1.33.3.jolla]
    _defaultPageOrientations: Orientation.All
    allowedOrientations: Orientation.All

    Component {
        id: entryPage
        OverviewPage { }
    }

    WorkerScript {
        id: dataLoader
        source: "js/forecast.js"
        onMessage: {
            if (messageObject.type === 'weekOverview') {
                meteoApp.overviewTimestamp = new Date(messageObject.timestamp)

                for (var i = 0; i < messageObject.data.length; i++) {
                    var d = messageObject.data[i]
                    Storage.setDaySummary(d.locationId, d.dayString, d.symbol, d.precipitation, d.tempMin, d.tempMax)
                }

                weekSummaryUpdated()
            } else if (messageObject.type === 'data') {
                meteoApp.dataTimestamp = new Date(messageObject.timestamp)
                meteoApp.forecastData = messageObject.data
                Storage.setData(messageObject.timestamp, messageObject.locationId, messageObject.data, messageObject.rawData)
                meteoApp.dataIsReady[messageObject.locationId] = true
                dataLoaded(messageObject.data, messageObject.locationId)

                if (messageObject.data[0].isSane === false) {
                    locationDisabled(messageObject.locationId)
                }
            } else if (messageObject.type === 'disable-location') {
                locationDisabled(messageObject.locationId)
                var disabledData = [{isSane: false}]
                Storage.disableLocation(messageObject.locationId)
                Storage.setData((new Date()).getTime(), messageObject.locationId, disabledData, {})
                meteoApp.dataIsReady[messageObject.locationId] = true
                dataLoaded(disabledData, messageObject.locationId)
            } else {
                console.error("received worker message of unknown type: %1".arg(messageObject.type))
                console.error(JSON.stringify(messageObject))
            }
        }
    }

    function refreshTableModel(locationId) {
        var archived = Storage.getData(locationId, true)
        dataLoader.sendMessage({
            type: "updateTableModel",
            locationId: locationId,
            data: archived,
            tableModel: forecastTable,
        })
    }

    function doRefreshData(locationId, force) {
        function refreshSingle(locationId, force) {
            console.log("refreshing " + locationId + "...")
            meteoApp.dataIsReady[locationId] = false
            dataIsLoading(locationId)

            var archived = null
            var archiveTimestamp = 0

            if (!force) {
                archived = Storage.getData(locationId, true)
                archived = archived.length > 0 ? archived[0] : null
                archiveTimestamp = !!archived ? archived.timestamp : 0
            }

            dataLoader.sendMessage({
                type: "forecast",
                locationId: locationId,
                data: archived,
                lastRefreshed: new Date(archiveTimestamp),
            })
        }

        var allLocations = Storage.getActiveLocationsList()

        dataLoader.sendMessage({
            type: "weekOverview",
            locations: allLocations,
            lastRefreshed: overviewTimestamp,
        });

        if (locationId) {
            refreshSingle(locationId, force)
        } else {
            console.log("refreshing all locations...")
            for (var i = 0; i < allLocations.length; ++i) {
                refreshSingle(allLocations[i], force)
            }
        }
    }

    L.MaintenanceOverlay {}

    /* L.MaintenanceOverlay {
        id: disableAppOverlay
        text: qsTr("Currently unusable")
        hintText: qsTr("This app is currently unusable, " +
                       "due to a change at the data provider's side.")
        busy: false
        autoShowOnMaintenance: false
    } */

    A.ChangelogNews {
        changelogList: Qt.resolvedUrl("Changelog.qml")
    }

    M.AskForSupport {
        contents: Component {
            MySupportDialog {}
        }
    }

    Component.onCompleted: {
        // Avoid hard dependency on Nemo.Time and load it in a complicated
        // way to make Jolla's validator script happy.
        wallClock = Qt.createQmlObject("
            import QtQuick 2.0
            import %1 1.0
            WallClock {
                enabled: Qt.application.active
                updateFrequency: WallClock.Minute
            }".arg("Nemo.Time"), meteoApp, 'WallClock')

        // TODO implement a way to detect API breakage and enable the overlay automatically
        // disableAppOverlay.show()
        // return

        overviewTimestamp = Storage.getDaySummaryAge()
        doRefreshData();
        refreshData.connect(doRefreshData);
    }
}
