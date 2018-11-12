import QtQuick 2.6
import Sailfish.Silica 1.0

import "../data/forecast.js" as ForecastData


Page {
    property string name
    property var rainData
    property var tempData

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Detailed Forecast"
            }

            Label {
                id: title
                x: Theme.horizontalPageMargin
                text: name
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Row {
                id: headers
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge
                padding: Theme.horizontalPageMargin

                Label {
                    id: hourTitle
                    width: 150+Theme.paddingLarge+100+Theme.paddingLarge
                    text: "Hour"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: tempTitle
                    width: 300
                    text: "Temp."
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: rainTitle
                    width: 400
                    text: "Precip."
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }
            }

            SilicaListView {
                width: parent.width
                height: 24*Theme.itemSizeSmall
                x: Theme.horizontalPageMargin

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
                        source: "../icons/" + image + ".svg"
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

                Component.onCompleted: {
                    model.append({"hour": 0 , "image": tempData.datasets[0].symbols[0 ], "temp": tempData.datasets[0].data[0 ], "rain": rainData.datasets[0].data[0 ] })
                    model.append({"hour": 1 , "image": tempData.datasets[0].symbols[1 ], "temp": tempData.datasets[0].data[1 ], "rain": rainData.datasets[0].data[1 ] })
                    model.append({"hour": 2 , "image": tempData.datasets[0].symbols[2 ], "temp": tempData.datasets[0].data[2 ], "rain": rainData.datasets[0].data[2 ] })
                    model.append({"hour": 3 , "image": tempData.datasets[0].symbols[3 ], "temp": tempData.datasets[0].data[3 ], "rain": rainData.datasets[0].data[3 ] })
                    model.append({"hour": 4 , "image": tempData.datasets[0].symbols[4 ], "temp": tempData.datasets[0].data[4 ], "rain": rainData.datasets[0].data[4 ] })
                    model.append({"hour": 5 , "image": tempData.datasets[0].symbols[5 ], "temp": tempData.datasets[0].data[5 ], "rain": rainData.datasets[0].data[5 ] })
                    model.append({"hour": 6 , "image": tempData.datasets[0].symbols[6 ], "temp": tempData.datasets[0].data[6 ], "rain": rainData.datasets[0].data[6 ] })
                    model.append({"hour": 7 , "image": tempData.datasets[0].symbols[7 ], "temp": tempData.datasets[0].data[7 ], "rain": rainData.datasets[0].data[7 ] })
                    model.append({"hour": 8 , "image": tempData.datasets[0].symbols[8 ], "temp": tempData.datasets[0].data[8 ], "rain": rainData.datasets[0].data[8 ] })
                    model.append({"hour": 9 , "image": tempData.datasets[0].symbols[9 ], "temp": tempData.datasets[0].data[9 ], "rain": rainData.datasets[0].data[9 ] })
                    model.append({"hour": 10, "image": tempData.datasets[0].symbols[10], "temp": tempData.datasets[0].data[10], "rain": rainData.datasets[0].data[10] })
                    model.append({"hour": 11, "image": tempData.datasets[0].symbols[11], "temp": tempData.datasets[0].data[11], "rain": rainData.datasets[0].data[11] })
                    model.append({"hour": 12, "image": tempData.datasets[0].symbols[12], "temp": tempData.datasets[0].data[12], "rain": rainData.datasets[0].data[12] })
                    model.append({"hour": 13, "image": tempData.datasets[0].symbols[13], "temp": tempData.datasets[0].data[13], "rain": rainData.datasets[0].data[13] })
                    model.append({"hour": 14, "image": tempData.datasets[0].symbols[14], "temp": tempData.datasets[0].data[14], "rain": rainData.datasets[0].data[14] })
                    model.append({"hour": 15, "image": tempData.datasets[0].symbols[15], "temp": tempData.datasets[0].data[15], "rain": rainData.datasets[0].data[15] })
                    model.append({"hour": 16, "image": tempData.datasets[0].symbols[16], "temp": tempData.datasets[0].data[16], "rain": rainData.datasets[0].data[16] })
                    model.append({"hour": 17, "image": tempData.datasets[0].symbols[17], "temp": tempData.datasets[0].data[17], "rain": rainData.datasets[0].data[17] })
                    model.append({"hour": 18, "image": tempData.datasets[0].symbols[18], "temp": tempData.datasets[0].data[18], "rain": rainData.datasets[0].data[18] })
                    model.append({"hour": 19, "image": tempData.datasets[0].symbols[19], "temp": tempData.datasets[0].data[19], "rain": rainData.datasets[0].data[19] })
                    model.append({"hour": 20, "image": tempData.datasets[0].symbols[20], "temp": tempData.datasets[0].data[20], "rain": rainData.datasets[0].data[20] })
                    model.append({"hour": 21, "image": tempData.datasets[0].symbols[21], "temp": tempData.datasets[0].data[21], "rain": rainData.datasets[0].data[21] })
                    model.append({"hour": 22, "image": tempData.datasets[0].symbols[22], "temp": tempData.datasets[0].data[22], "rain": rainData.datasets[0].data[22] })
                    model.append({"hour": 23, "image": tempData.datasets[0].symbols[23], "temp": tempData.datasets[0].data[23], "rain": rainData.datasets[0].data[23] })
                }
            }

            VerticalScrollDecorator {}
        }
    }
}
