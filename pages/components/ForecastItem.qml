import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


Column {
    property var dataRain
    property var dataTemp
    property string title
    property bool active
    property int dayId

    width: parent.width - (Theme.horizontalPageMargin * 2)
    x: Theme.horizontalPageMargin

    Column {
        width: parent.width

        BackgroundItem {
            width: parent.width
            height: Theme.itemSizeSmall

            onClicked: active ? pageStack.push(Qt.resolvedUrl("../Table.qml"), {}) : pageStack.replace(Qt.resolvedUrl("../Main.qml"), { activeDay: dayId })

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

    Item {
        height: chart.height
        width: parent.width
        clip: true
        visible: active

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
                    height: tempChart.height + spacing + rainChart.height
                    width: 2000
                    spacing: Theme.paddingLarge

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
}
