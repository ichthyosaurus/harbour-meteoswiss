import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


Item {
    property var rain
    property var temp

    height: chart.height
    width: parent.width
    clip: true

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
                    property int minValue: Math.min.apply(Math, temp.datasets[0].data)
                    width: parent.width
                    height: 500
                    chartAnimated: false
                    chartData: temp
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
                    chartData: rain
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
