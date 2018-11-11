import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

import "qchart/"
import "qchart/QChart.js" as Charts
import "data/forecast.js" as ForecastData


ApplicationWindow {
    id: main
    initialPage: Component { Main { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

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
        Main { }
    }

    Component.onCompleted: {
        // pageStack.push(main)
        console.log("ready!")
    }
}
