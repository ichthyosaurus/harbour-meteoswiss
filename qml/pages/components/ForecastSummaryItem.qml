import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage


Column {
    id: summaryItem

    property int hour
    property int day
    property var textColor: (meteoApp.dataTimestamp.toDateString() == new Date().toDateString() && day == 0) ? (hour >= Storage.getCurrentSymbolHour() ? Theme.primaryColor : Theme.highlightColor) : Theme.highlightColor

    width: parent.width/8

    Text {
        id: hourLabel
        width: parent.width
        text: hour
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        color: textColor
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

    Text {
        id: tempLabel
        width: parent.width
        text: forecastData[day].temperature.datasets[0].data[hour] + " °C"
        font.pixelSize: Theme.fontSizeTiny
        horizontalAlignment: Text.AlignHCenter
        color: textColor
    }

    Text {
        id: rainLabel
        width: parent.width
        property var rain: forecastData[day].rainfall.datasets[0].tableData[hour]
        text: rain > 0 ? rain + " mm" : ""
        font.pixelSize: Theme.fontSizeTiny
        horizontalAlignment: Text.AlignHCenter
        color: textColor
    }
}
