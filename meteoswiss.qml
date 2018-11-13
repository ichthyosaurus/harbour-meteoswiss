import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "pages"

import "data/forecast.js" as Forecast
import "data/storage.js" as Storage
import "data/dummy.js" as DummyData


ApplicationWindow {
    id: main
    initialPage: mainPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    signal dataLoaded(var data)
    signal dataIsLoading()
    signal refreshData()

    property var data: Forecast.fullData
    property bool dataIsReady: false

    Component {
        id: mainPage
        Main { activeDay: 0 }
    }

    WorkerScript {
        id: dataLoader
        source: "data/forecast.js"
        onMessage: {
            main.data = messageObject.data
            main.dataIsReady = true
            dataLoaded(messageObject.data)

            Storage.init()
            Storage.setData(messageObject.timestamp, messageObject.zip, JSON.stringify(messageObject.data), JSON.stringify(messageObject.raw))
        }
    }

    function doRefreshData(message) {
        console.log("refreshing...")
        main.dataIsReady = false
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
