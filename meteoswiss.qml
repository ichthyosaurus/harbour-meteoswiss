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
    signal refreshData()

    property var data: Forecast.fullData
    property bool dataIsReady: false

    Component {
        id: entryPage
        OverviewPage { }
    }

    WorkerScript {
        id: dataLoader
        source: "js/forecast.js"
        onMessage: {
            meteoApp.data = messageObject.data
            meteoApp.dataIsReady = true
            dataLoaded(messageObject.data)

            Storage.init()
            Storage.setData(messageObject.timestamp, messageObject.zip, JSON.stringify(messageObject.data), JSON.stringify(messageObject.raw))
        }
    }

    function doRefreshData(message) {
        console.log("refreshing...")
        meteoApp.dataIsReady = false
        dataIsLoading()
        var archived = Storage.getData(4143, true)
        dataLoader.sendMessage({
            data: archived.length > 0 ? archived[0] : null,
            // dummy: DummyData.archived_forecast,
        })
    }

    Component.onCompleted: {
        doRefreshData()
        refreshData.connect(doRefreshData)
    }
}
