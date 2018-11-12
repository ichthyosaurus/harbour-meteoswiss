import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

import "data/forecast.js" as Forecast


ApplicationWindow {
    id: main
    initialPage: mainPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property var data: Forecast.convert_raw(Forecast.raw_meteo_forecast)

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

    Component.onCompleted: {
        // Forecast.theData = Forecast.convert_raw(Forecast.raw_meteo_forecast)
    }
}
