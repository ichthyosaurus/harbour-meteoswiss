import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


QChart {
    id: tempChart
    property int minValue: Math.min.apply(Math, temp.datasets[0].data)

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

    Component.onCompleted: {
        console.log("loaded: temp", height, width)
    }
}
