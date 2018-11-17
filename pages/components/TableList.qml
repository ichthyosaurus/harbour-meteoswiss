import QtQuick 2.6
import Sailfish.Silica 1.0

import "../../js/strings.js" as Strings


SilicaListView {
    id: table
    width: parent.width
    height: (showAll ? 24 : 8) * Theme.itemSizeSmall
    x: Theme.horizontalPageMargin

    property var data
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
        width: ListView.view.width
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

        Label {
            id: hourLabel
            x: hourTitle.x
            width: 70
            text: hour
            font.pixelSize: Theme.fontSizeSmall
        }

        Image {
            x: hourLabel.x + hourLabel.width + Theme.paddingMedium
            width: 100
            height: Theme.itemSizeSmall
            fillMode: Image.PreserveAspectFit
            source: "../../icons/" + image + ".svg"
            verticalAlignment: Image.AlignVCenter
            anchors.verticalCenter: hourLabel.verticalCenter
            opacity: 1
        }

        Label {
            x: tempTitle.x - Theme.paddingLarge
            width: 250
            text: temp + " °C"
            font.pixelSize: Theme.fontSizeMedium
        }

        Label {
            x: rainTitle.x - Theme.paddingLarge
            width: 250
            text: (rain > 0) ? rain + " mm" : ''
            font.pixelSize: Theme.fontSizeMedium
        }

        Label {
            visible: isLandscape
            x: descriptionTitle.x - Theme.paddingLarge
            width: 800
            text: description
            anchors.verticalCenter: hourLabel.verticalCenter
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
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
        rain = data[day].rainfall
        temp = data[day].temperature

        model.clear()

        for (var i = 0; i < 24; i++) {
            model.append({
                "hour": i,
                "image": temp.datasets[0].symbols[i],
                "temp": temp.datasets[0].data[i],
                "rain": rain.datasets[0].tableData[i],
                "description": Strings.MeteoLang.weatherSymbolDescription[temp.datasets[0].symbols[i]],
            })
        }
    }
}
