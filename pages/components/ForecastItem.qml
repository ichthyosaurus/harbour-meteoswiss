import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


Item {
    height: chart.height
    width: parent.width - (Theme.horizontalPageMargin * 2)
    x: Theme.horizontalPageMargin
    clip: true

    property var dataRain
    property var dataTemp
    property string title

    SilicaFlickable {
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick

        contentHeight: row.height
        contentWidth: row.width

        Row {
            id: row
            width: chart.width + (2 * spacing)
            height: chart.height
            spacing: Theme.paddingLarge

            Column {
                id: chart
                height: 1500
                width: 2000
                spacing: Theme.paddingLarge

                Column {
                    width: mainPage.width

                    BackgroundItem {
                        width: parent.width
                        height: Theme.itemSizeSmall

                        onClicked: pageStack.push(Qt.resolvedUrl("../Table.qml"), {})

                        Label {
                            id: titleLabel
                            anchors {
                                rightMargin: Theme.paddingMedium
                                verticalCenter: parent.verticalCenter
                            }
                            text: title
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Image {
                            id: moreImage
                            anchors {
                                left: titleLabel.right
                                rightMargin: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
                                verticalCenter: parent.verticalCenter
                            }
                            source: "image://theme/icon-m-right?" + Theme.highlightColor
                        }
                    }
                }

                QChart {
                    id: tempChart
                    property int minValue: Math.min.apply(Math, dataTemp.datasets[0].data)
                    width: parent.width
                    height: 500
                    chartAnimated: false
                    chartData: dataTemp
                    chartType: Charts.ChartType.LINE
                    chartOptions: ({
                        scaleFontSize: Theme.fontSizeExtraSmall,
                        scaleFontFamily: 'Sail Sans Pro',
                        scaleFontColor: Theme.secondaryColor,
                        scaleLineColor: Theme.secondaryColor,
                        bezierCurve: true,
                        scaleStartValue: (minValue == 0) ? 0 : minValue - 1,
                        datasetStrokeWidth: 2,
                        pointDotRadius: 6,
                    })
                }

                QChart {
                    id: rainChart
                    width: parent.width
                    height: 290
                    chartAnimated: false
                    chartData: dataRain
                    chartType: Charts.ChartType.BAR
                    chartOptions: ({
                        scaleFontSize: Theme.fontSizeExtraSmall,
                        scaleFontFamily: 'Sail Sans Pro',
                        scaleFontColor: Theme.secondaryColor,
                        scaleLineColor: Theme.secondaryColor,
                        scaleShowLabels: true,
                        scaleStartValue: 0.0,
                    })
                }
            }
        }
    }
}
