/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.About 1.0 as A
import Opal.SupportMe 1.0 as M
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
    signal weekSummaryUpdated()

    // ATTENTION set to "false" before release
    property bool debug: false

    property var forecastData: Forecast.fullData
    property var dataIsReady: ({})
    property var dataTimestamp
    property var overviewTimestamp

    property var sourceBasePath: ""
    property var sourcePathUpdated: new Date("1970-01-01T00:00:00.000Z")

    property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
    property string timeFormat: qsTr("hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")

    property string tempUnit: "°C"
    property string rainUnit: "mm/h"
    property string rainUnitShort: "mm"
    property string windUnit: "km/h"

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
            if (messageObject.type === 'path') {
                // note: age has to be changed before updating the path!
                // When updating all locations, we wait for an updated path to
                // continue after the first locations has been refreshed. See
                // below for details.
                meteoApp.sourcePathUpdated = messageObject.age
                meteoApp.sourceBasePath = messageObject.source
            } else if (messageObject.type === 'weekOverview') {
                meteoApp.overviewTimestamp = messageObject.age;

                for (var i = 0; i < messageObject.data.length; i++) {
                    var d = messageObject.data[i];
                    Storage.setDaySummary(d.locationId, d.dayString, d.symbol, d.precipitation, d.tempMin, d.tempMax);
                }

                weekSummaryUpdated();
            } else {
                meteoApp.dataTimestamp = new Date(messageObject.timestamp)
                meteoApp.forecastData = messageObject.data
                Storage.setData(messageObject.timestamp, messageObject.locationId, messageObject.data)
                meteoApp.dataIsReady[messageObject.locationId] = true
                dataLoaded(messageObject.data, messageObject.locationId)
            }
        }
    }

    function doRefreshData(locationId, force, refreshingAll, notifyUnchangedPath) {
        if (!overviewTimestamp) {
            overviewTimestamp = Storage.getDaySummaryAge();
        }

        var locs;
        if (Date.now() - overviewTimestamp.getTime() > 60*60*1000) {
            overviewTimestamp = new Date()
            locs = Storage.getLocationsList();
            dataLoader.sendMessage({
                type: "weekOverview",
                locations: locs,
            });
        } else if (locationId && force) {
            dataLoader.sendMessage({
                type: "weekOverview",
                locations: [locationId],
            });
        }

        if (locationId) {
            console.log("refreshing " + locationId + "...")
            meteoApp.dataIsReady[locationId] = false
            dataIsLoading(locationId)

            var archived = [];
            if (!force) {
                archived = Storage.getData(locationId, true)
            }

            dataLoader.sendMessage({
                type: "forecast",
                data: archived.length > 0 ? archived[0] : null,
                locationId: locationId,
                source: meteoApp.sourceBasePath,
                sourceAge: meteoApp.sourcePathUpdated,
                notifyUnchangedPath: (notifyUnchangedPath ? false : true)
            })
        } else {
            console.log("refreshing all known locations...")
            locs = Storage.getLocationData();

            if (locs.length === 0) return;

            refreshAll = true;
            locationsToRefresh = locs;
            forceRefreshAll = (force === undefined) ? false : force;

            // Work-around to make sure source path is only extracted once per refresh.
            //
            // Essentially, we wait for the first location to send an updated path to
            // use for the rest. If the path stays unchanged because the first location
            // was already updated less than a certain amount of time before,
            // the main thread will be notified nonetheless so the process can continue.
            // We then accept that the path will be extracted separately for the
            // remaining locations. Note that this can only happen if the user
            // force-refreshes the first location.
            doRefreshData(locationsToRefresh[0].locationId, forceRefreshAll, true);
        }
    }

    // Properties needed for work-around to make sure source path is only
    // extracted once per refresh
    property bool refreshAll: false
    property var  locationsToRefresh
    property bool forceRefreshAll: false

    // Work-around to make sure source path is only extracted once per refresh.
    // Essentially, we wait for the first location to send an updated path to
    // use for the rest. If the path stays unchanged because the first location
    // was already updated less than a certain amount of time before,
    // the main thread will be notified nonetheless so the process can continue.
    // We then accept that the path will be extracted separately for the
    // remaining locations. Note that this can only happen if the user
    // force-refreshes the first location.
    onSourceBasePathChanged: {
        if (refreshAll && locationsToRefresh) {
            refreshAll = false;

            for (var i = 1; i < locationsToRefresh.length; i++) {
                doRefreshData(locationsToRefresh[i].locationId, forceRefreshAll, false)
            }
        }
    }

    MaintenanceOverlay {
        id: maintenanceOverlay
        text: qsTr("Database Maintenance")
        hintText: qsTr("Please be patient and allow up to 30 seconds for this.")
    }

    MaintenanceOverlay {
        id: disableAppOverlay
        text: qsTr("Currently unusable")
        hintText: qsTr("This app is currently unusable, due to a change at the data provider's side.")
    }

    A.ChangelogNews {
        changelogList: Qt.resolvedUrl("Changelog.qml")
    }

    M.AskForSupport {
        contents: Component {
            MySupportDialog {}
        }
    }

    Component.onCompleted: {
        // FIXME disable when everything works again
        // TODO implement a way to detect API breakage and enable the overlay automatically
        // disableAppOverlay.state = "visible";

        if (Storage.dbNeedsMaintenance()) {
            maintenanceOverlay.state = "visible";
            Storage.doDatabaseMaintenance();
            maintenanceOverlay.state = "invisible";
        }

        doRefreshData();
        refreshData.connect(doRefreshData);
    }
}
