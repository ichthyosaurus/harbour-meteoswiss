import QtQuick 2.0
import Sailfish.Silica 1.0


Column {
    id: summaryItem

    property int hour
    property int day

    width: parent.width/8

    Text {
        id: hourLabel
        width: parent.width
        text: hour
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        color: Theme.highlightColor
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
        color: Theme.highlightColor
    }

    Text {
        id: rainLabel
        width: parent.width
        text: forecastData[day].rainfall.datasets[0].tableData[hour] + " mm"
        font.pixelSize: Theme.fontSizeTiny
        horizontalAlignment: Text.AlignHCenter
        color: Theme.highlightColor
    }
}
