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
    signal refreshData(var location)

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

    function doRefreshData(location) {
        if (location) {
            console.log("refreshing... " + location)
            meteoApp.dataIsReady = false
            dataIsLoading()
            var archived = Storage.getData(location, true)
            dataLoader.sendMessage({
                data: archived.length > 0 ? archived[0] : null,
                zip: location,
                // dummy: DummyData.archived_forecast,
            })
        } else {
            console.log("failed to refresh: no location given")
            console.log("DEBUG refreshing for 4143:")
            doRefreshData(4143)
        }
    }

    Component.onCompleted: {
        doRefreshData()
        refreshData.connect(doRefreshData)
    }
}
