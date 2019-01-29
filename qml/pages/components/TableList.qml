import QtQuick 2.6
import Sailfish.Silica 1.0

import "../../js/strings.js" as Strings


SilicaListView {
    id: table
    width: parent.width
    height: (showAll ? 24 : 8) * Theme.itemSizeSmall
    x: Theme.horizontalPageMargin

    property var forecastData
    property bool showAll: false
    signal toggleShowAll

    onToggleShowAll: {
        showAll = !showAll
    }

    Behavior on opacity { NumberAnimation { duration: 500 } }
    opacity: tablePage.loaded ? 1 : 0
    visible: tablePage.loaded ? true : false

    model: ListModel { }

    delegate: Item {
        width: Screen.height
        height: visible ? Theme.itemSizeSmall : 0
        visible: (   hour == 2
                  || hour == 5
                  || hour == 8
                  || hour == 11
                  || hour == 14
                  || hour == 17
                  || hour == 20
                  || hour == 23
                  || showAll)

        Row {
            width: parent.width
            x: parent.x

            spacing: Theme.paddingLarge

            Label {
                id: hourLabel
                width: hourTitle.width
                text: hour
                font.pixelSize: Theme.fontSizeSmall
            }

            Image {
                width: symbolTitle.width
                height: Theme.itemSizeSmall
                fillMode: Image.PreserveAspectFit
                source: "../../weather-icons/" + image + ".svg"
                verticalAlignment: Image.AlignVCenter
                anchors.verticalCenter: hourLabel.verticalCenter
                opacity: 1
            }

            TableListValueElement {
                base: tempTitle
                text: temp
                unit: meteoApp.tempUnit
            }

            TableListValueElement {
                base: rainTitle
                text: (rain > 0) ? rain : ''
                unit: meteoApp.rainUnit
            }

            TableListValueElement {
                base: windTitle
                text: wind
                unit: meteoApp.windUnit
            }

            Label {
                visible: isLandscape
                width: windSymTitle.width
                text: windSym
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                visible: isLandscape
                width: descriptionTitle.width
                text: description
                anchors.verticalCenter: hourLabel.verticalCenter
                truncationMode: TruncationMode.Fade
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                toggleShowAll()
            }
        }
    }

    function refreshModel() {
        rain = forecastData[day].rainfall
        temp = forecastData[day].temperature
        wind = forecastData[day].wind

        model.clear()

        for (var i = 0; i < 24; i++) {
            model.append({
                "hour": i,
                "image": temp.datasets[0].symbols[i],
                "temp": temp.datasets[0].data[i],
                "rain": (rain.haveData ? rain.datasets[0].data[i] : []),
                "wind": wind.datasets[0].data[i],
                "windSym": wind.datasets[0].symbols[i],
                "description": Strings.MeteoLang.weatherSymbolDescription[temp.datasets[0].symbols[i]],
            })
        }
    }
}
