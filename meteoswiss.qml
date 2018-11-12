import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

import "data/forecast.js" as Forecast


ApplicationWindow {
    id: main
    initialPage: mainPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    signal dataLoaded(var data)
    signal dataIsLoading()
    signal refreshData()

    property var data: Forecast.fullData
    property bool dataIsReady: false

//     Python {
//         id: py
//         Component.onCompleted: {
//             importModule('os', function() {});
//             importModule('urllib.request', function() {});
//             setHandler('download_finished', function (Id) {
//                 console.log('New entries from ' + Id);
//             });
//         }
//     }

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
        }
    }

    function doRefreshData(message) {
        console.log("refreshing...")
        main.dataIsReady = false
        dataIsLoading()
        dataLoader.sendMessage()
    }

    Component.onCompleted: {
        doRefreshData()
        refreshData.connect(doRefreshData)
    }
}
