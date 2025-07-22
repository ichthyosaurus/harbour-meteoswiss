/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../qchart/"
import "../qchart/QChart.js" as Charts


QChart {
    id: windChart
    property bool scaleOnly: false
    property bool isToday: false

    chartAnimated: false
    chartData: wind ? wind : { labels: [], datasets: [{ fillColor: "rgba(0,0,0,0)", strokeColor: "rgba(0,0,0,0)", pointColor: "rgba(0,0,0,0)", data: [] }]}
    chartType: Charts.ChartType.LINE
    chartOptions: ({
        scaleFontSize: Theme.fontSizeExtraSmall,
        scaleFontFamily: 'Sail Sans Pro',
        scaleFontColor: Theme.secondaryColor,
        scaleLineColor: Theme.secondaryColor,
        scaleOverlay: scaleOnly,
        bezierCurve: true,
        scaleStartValue: 0,
        datasetStrokeWidth: 2,
        datasetFill: false,
        datasetFillDiff23: true,
        pointDotRadius: 6,
        pointDot: false,
        currentHourLine: isToday,

        fillColor: [
            "rgba(190,133,255,0)", "rgba(190,133,255,0.2)", "rgba(190,133,255,0.2)",
            "rgba(120,84,161,0)", "rgba(120,84,161,0.2)", "rgba(120,84,161,0.2)"
        ],
        strokeColor: [
            "rgba(190,133,255,1)", "rgba(190,133,255,0.6)", "rgba(190,133,255,0.6)",
            "rgba(120,84,161,1)", "rgba(120,84,161,0.6)", "rgba(120,84,161,0.6)"
        ],
        pointColor: [
            "rgba(190,133,255,1)", "rgba(190,133,255,0.3)", "rgba(190,133,255,0.3)",
            "rgba(120,84,161,1)", "rgba(120,84,161,0.3)", "rgba(120,84,161,0.3)"
        ],
        pointStrokeColor: [
            "rgba(190,133,255,1)", "rgba(190,133,255,0.3)", "rgba(190,133,255,0.3)",
            "rgba(120,84,161,1)", "rgba(120,84,161,0.3)", "rgba(120,84,161,0.3)"
        ],
    })
}
