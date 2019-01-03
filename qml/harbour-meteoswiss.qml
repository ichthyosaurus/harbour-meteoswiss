import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "pages"

import "js/forecast.js" as Forecast
import "js/storage.js" as Storage
import "js/dummy.js" as DummyData


ApplicationWindow {
    id: meteoApp
    initialPage: entryPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    signal dataLoaded(var data)
    signal dataIsLoading()
    signal refreshData(var location, var force)
    signal locationAdded(var locationData)

    property var forecastData: Forecast.fullData
    property bool dataIsReady: false

    Component {
        id: entryPage
        OverviewPage { }
    }

    WorkerScript {
        id: dataLoader
        source: "js/forecast.js"
        onMessage: {
            meteoApp.forecastData = messageObject.data
            meteoApp.dataIsReady = true
            dataLoaded(messageObject.data)

            Storage.init()
            Storage.setData(messageObject.timestamp, messageObject.zip, JSON.stringify(messageObject.data), JSON.stringify(messageObject.raw))
        }
    }

    function doRefreshData(location, force) {
        if (location) {
            console.log("refreshing... " + location)
            meteoApp.dataIsReady = false
            dataIsLoading()

            if (force) {
                var archived = []
            } else {
                var archived = Storage.getData(location, true)
            }

            dataLoader.sendMessage({
                data: archived.length > 0 ? archived[0] : null,
                zip: location,
                // dummy: DummyData.archived_forecast,
            })
        } else {
            console.log("refreshing all known locations...")
            var locs = Storage.getLocationData()
            for (var i = 0; i < locs.length; i++) {
                doRefreshData(locs[i].zip)
            }
        }
    }

    Component.onCompleted: {
        doRefreshData()
        refreshData.connect(doRefreshData)
    }
}
