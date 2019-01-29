import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage


Column {
    id: summaryItem

    property int hour
    property int day
    property var textColor: (meteoApp.dataTimestamp.toDateString() == new Date().toDateString() && day == 0) ? (hour >= Storage.getCurrentSymbolHour() ? Theme.primaryColor : Theme.highlightColor) : Theme.highlightColor

    width: parent.width/8

    ForecastSummaryItemLabel {
        value: hour
        font.pixelSize: Theme.fontSizeSmall
    }

    Image {
        id: image
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
