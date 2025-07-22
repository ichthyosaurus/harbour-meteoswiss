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
    id: root
    property bool scaleOnly: false
    property bool isToday: false

    chartAnimated: false
    chartData: sun ? sun : { labels: [], datasets: [{ fillColor: "rgba(0,0,0,0)", strokeColor: "rgba(0,0,0,0)", pointColor: "rgba(0,0,0,0)", data: [] }]}
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
        datasetFill: true,
        datasetFillDiff23: false,
        pointDotRadius: 6,
        pointDot: false,
        currentHourLine: isToday,

        fillColor: ["rgba(255,255,0,0.2)"],
        strokeColor: ["rgba(255,255,0,1)"],
        pointColor: ["rgba(255,255,0,1)"],
        pointStrokeColor: ["rgba(255,255,0,1)"],
    })
}
