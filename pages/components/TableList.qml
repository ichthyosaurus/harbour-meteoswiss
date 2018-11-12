import QtQuick 2.6
import Sailfish.Silica 1.0


SilicaListView {
    width: parent.width
    height: 24*Theme.itemSizeSmall
    x: Theme.horizontalPageMargin

    property var data

    Behavior on opacity { NumberAnimation { duration: 500 } }
    opacity: tablePage.loaded ? 1 : 0
    visible: tablePage.loaded ? true : false

    model: ListModel { }

    delegate: Item {
        width: ListView.view.width
        height: Theme.itemSizeSmall

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
    }

    function refreshModel() {
        rain = data[day].rainfall
        temp = data[day].temperature

        model.clear()
        model.append({"hour": 0 , "image": temp.datasets[0].symbols[0 ], "temp": temp.datasets[0].data[0 ], "rain": rain.datasets[0].tableData[0 ] })
        model.append({"hour": 1 , "image": temp.datasets[0].symbols[1 ], "temp": temp.datasets[0].data[1 ], "rain": rain.datasets[0].tableData[1 ] })
        model.append({"hour": 2 , "image": temp.datasets[0].symbols[2 ], "temp": temp.datasets[0].data[2 ], "rain": rain.datasets[0].tableData[2 ] })
        model.append({"hour": 3 , "image": temp.datasets[0].symbols[3 ], "temp": temp.datasets[0].data[3 ], "rain": rain.datasets[0].tableData[3 ] })
        model.append({"hour": 4 , "image": temp.datasets[0].symbols[4 ], "temp": temp.datasets[0].data[4 ], "rain": rain.datasets[0].tableData[4 ] })
        model.append({"hour": 5 , "image": temp.datasets[0].symbols[5 ], "temp": temp.datasets[0].data[5 ], "rain": rain.datasets[0].tableData[5 ] })
        model.append({"hour": 6 , "image": temp.datasets[0].symbols[6 ], "temp": temp.datasets[0].data[6 ], "rain": rain.datasets[0].tableData[6 ] })
        model.append({"hour": 7 , "image": temp.datasets[0].symbols[7 ], "temp": temp.datasets[0].data[7 ], "rain": rain.datasets[0].tableData[7 ] })
        model.append({"hour": 8 , "image": temp.datasets[0].symbols[8 ], "temp": temp.datasets[0].data[8 ], "rain": rain.datasets[0].tableData[8 ] })
        model.append({"hour": 9 , "image": temp.datasets[0].symbols[9 ], "temp": temp.datasets[0].data[9 ], "rain": rain.datasets[0].tableData[9 ] })
        model.append({"hour": 10, "image": temp.datasets[0].symbols[10], "temp": temp.datasets[0].data[10], "rain": rain.datasets[0].tableData[10] })
        model.append({"hour": 11, "image": temp.datasets[0].symbols[11], "temp": temp.datasets[0].data[11], "rain": rain.datasets[0].tableData[11] })
        model.append({"hour": 12, "image": temp.datasets[0].symbols[12], "temp": temp.datasets[0].data[12], "rain": rain.datasets[0].tableData[12] })
        model.append({"hour": 13, "image": temp.datasets[0].symbols[13], "temp": temp.datasets[0].data[13], "rain": rain.datasets[0].tableData[13] })
        model.append({"hour": 14, "image": temp.datasets[0].symbols[14], "temp": temp.datasets[0].data[14], "rain": rain.datasets[0].tableData[14] })
        model.append({"hour": 15, "image": temp.datasets[0].symbols[15], "temp": temp.datasets[0].data[15], "rain": rain.datasets[0].tableData[15] })
        model.append({"hour": 16, "image": temp.datasets[0].symbols[16], "temp": temp.datasets[0].data[16], "rain": rain.datasets[0].tableData[16] })
        model.append({"hour": 17, "image": temp.datasets[0].symbols[17], "temp": temp.datasets[0].data[17], "rain": rain.datasets[0].tableData[17] })
        model.append({"hour": 18, "image": temp.datasets[0].symbols[18], "temp": temp.datasets[0].data[18], "rain": rain.datasets[0].tableData[18] })
        model.append({"hour": 19, "image": temp.datasets[0].symbols[19], "temp": temp.datasets[0].data[19], "rain": rain.datasets[0].tableData[19] })
        model.append({"hour": 20, "image": temp.datasets[0].symbols[20], "temp": temp.datasets[0].data[20], "rain": rain.datasets[0].tableData[20] })
        model.append({"hour": 21, "image": temp.datasets[0].symbols[21], "temp": temp.datasets[0].data[21], "rain": rain.datasets[0].tableData[21] })
        model.append({"hour": 22, "image": temp.datasets[0].symbols[22], "temp": temp.datasets[0].data[22], "rain": rain.datasets[0].tableData[22] })
        model.append({"hour": 23, "image": temp.datasets[0].symbols[23], "temp": temp.datasets[0].data[23], "rain": rain.datasets[0].tableData[23] })
    }
}
