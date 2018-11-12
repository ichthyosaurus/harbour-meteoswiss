import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


QChart {
    id: rainChart
    width: parent.width
    height: chart.rainHeight
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
