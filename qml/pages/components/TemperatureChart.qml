import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


QChart {
    id: tempChart
    property int minValue: Math.min.apply(Math, temp ? temp.datasets[0].data : [0])
    property bool scaleOnly: false
    property bool isToday: false

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
        datasetFill: false,
        datasetFillDiff23: true,
        pointDotRadius: 6,
        currentHourLine: isToday,

        fillColor: ["rgba(234,77,79,0)", "rgba(234,77,79,0.2)", "rgba(234,77,79,0.2)"],
        strokeColor: ["rgba(234,77,79,1)", "rgba(234,77,79,0.6)", "rgba(234,77,79,0.6)"],
        pointColor: ["rgba(234,77,79,1)", "rgba(234,77,79,0.3)", "rgba(234,77,79,0.3)"],
        pointStrokeColor: ["rgba(234,77,79,1)", "rgba(234,77,79,0.3)", "rgba(234,77,79,0.3)"],
    })
}
