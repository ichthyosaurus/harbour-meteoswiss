/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


QChart {
    id: tempChart
    property int minValue: Math.min.apply(Math, temp ? temp.datasets[0].data : [0])
    property bool scaleOnly: false
    property bool isToday: false
    property bool asOverview: false

    chartAnimated: false
    chartData: temp ? temp : { labels: [], datasets: [{ fillColor: "rgba(0,0,0,0)", strokeColor: "rgba(0,0,0,0)", pointColor: "rgba(0,0,0,0)", data: [] }]}
    chartType: Charts.ChartType.LINE
    chartOptions: ({
        scaleFontSize: Theme.fontSizeExtraSmall * (asOverview ? (4/5) : 1),
        scaleFontFamily: 'Sail Sans Pro',
        scaleFontColor: Theme.secondaryColor,
        scaleLineColor: Theme.secondaryColor,
        scaleOverlay: scaleOnly,
        bezierCurve: false,
        datasetStrokeWidth: 2,
        datasetFill: false,
        datasetFillDiff23: true,
        pointDotRadius: 6,
        currentHourLine: isToday,
        asOverview: asOverview,

        fillColor: ["rgba(234,77,79,0)", "rgba(234,77,79,0.2)", "rgba(234,77,79,0.2)"],
        strokeColor: ["rgba(234,77,79,1)", "rgba(234,77,79,0.6)", "rgba(234,77,79,0.6)"],
        pointColor: ["rgba(234,77,79,1)", "rgba(234,77,79,0.3)", "rgba(234,77,79,0.3)"],
        pointStrokeColor: ["rgba(234,77,79,1)", "rgba(234,77,79,0.3)", "rgba(234,77,79,0.3)"],
    })
}
