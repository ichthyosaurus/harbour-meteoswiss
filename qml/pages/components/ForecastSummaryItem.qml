import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage

BackgroundItem {
    property int hour
    property int day
    property var clickedCallback

    width: parent.width/8
    height: column.height

    signal summaryClicked(int hour, int symbol)
    onClicked: summaryClicked(hour, forecastData[day].temperature.datasets[0].symbols[hour])

    Component.onCompleted: {
        summaryClicked.connect(clickedCallback);

        if (   (day == 0 && meteoApp.dataTimestamp.toDateString() == new Date().toDateString() && hour == Storage.getCurrentSymbolHour())
            || hour == meteoApp.noonHour
        ) {
            summaryClicked(hour, forecastData[day].temperature.datasets[0].symbols[hour]);
        }
    }

    Column {
        id: column
        width: parent.width

        property var textColor: ((meteoApp.dataTimestamp.toDateString() == new Date().toDateString() && day == 0) ?
            (hour >= Storage.getCurrentSymbolHour() ? Theme.primaryColor : Theme.highlightColor) : Theme.highlightColor)

        ForecastSummaryItemLabel {
            value: hour
            font.pixelSize: Theme.fontSizeSmall
        }

        Image {
            width: 100
            height: Theme.itemSizeSmall
            fillMode: Image.PreserveAspectFit
            source: "../../weather-icons/" + forecastData[day].temperature.datasets[0].symbols[hour] + ".svg"
            verticalAlignment: Image.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 1
        }

        ForecastSummaryItemLabel {
            value: forecastData[day].temperature.datasets[0].data[hour]
            unit: meteoApp.tempUnit
        }

        ForecastSummaryItemLabel {
            property var rain: forecastData[day].rainfall.haveData ? forecastData[day].rainfall.datasets[0].data[hour] : 0
            value: rain > 0 ? rain : ""
            unit: meteoApp.rainUnitShort
        }
    }
}
