import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


QChart {
    id: tempChart
    property int minValue: Math.min.apply(Math, temp ? temp.datasets[0].data : [0])
    property bool scaleOnly: false

    chartAnimated: false
    chartData: temp ? temp : { labels: [], datasets: [{ fillColor: "rgba(0,0,0,0)", strokeColor: "rgba(0,0,0,0)", pointColor: "rgba(0,0,0,0)", data: [] }]}
    chartType: Charts.ChartType.LINE
    chartOptions: ({
        scaleFontSize: Theme.fontSizeExtraSmall,
        scaleFontFamily: 'Sail Sans Pro',
        scaleFontColor: Theme.secondaryColor,
        scaleLineColor: Theme.secondaryColor,
        scaleOverlay: scaleOnly,
        bezierCurve: false,
        scaleStartValue: (minValue == 0) ? 0 : minValue - 1,
        datasetStrokeWidth: 2,
        pointDotRadius: 6,
        currentHourLine: true,
    })
}
