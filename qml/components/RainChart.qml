/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../qchart/"
import "../qchart/QChart.js" as Charts


QChart {
    id: rainChart
    property bool scaleOnly: false
    property bool isToday: false
    property bool asOverview: false

    chartAnimated: false
    chartData: rain ? rain : { labels: [], datasets: [{ fillColor: getFillColor(), strokeColor: getStrokeColor(), pointColor: "rgba(0,0,0,0)", data: [] }]}
    chartType: Charts.ChartType.BAR
    chartOptions: ({
        // common chart options
        // changes must be applied to all charts!
        scaleFontSize: Theme.fontSizeExtraSmall * (asOverview ? (4/5) : 1),
        scaleFontFamily: 'Sail Sans Pro',
        scaleFontColor: Theme.secondaryColor,
        scaleLineColor: Theme.rgba(Theme.secondaryColor, 0.4),
        scaleLineWidth: 0.5,
        scaleOverlay: scaleOnly,
        currentHourLine: isToday,
        currentHourLineColor: Theme.rgba(Theme.secondaryColor, 1.0),
        currentHourLineWidth: 2,
        asOverview: asOverview,

        // custom chart options
        scaleStartValue: 0.0,
        barOverlay: true,

        fillColor: [getFillColor(), "rgba(151,187,205,0.8)", "rgba(151,187,205,0.05)"],
        strokeColor: [getStrokeColor(), "rgba(151,187,205,0.6)", "rgba(151,187,205,0.6)"],
    })

    function getFillColor() {
        if (rain) {
            if (rain.haveData) return "rgba(151,187,205,0.5)";
            else return "rgba(0,0,0,0)";
        } else {
            return "rgba(0,0,0,0)";
        }
    }

    function getStrokeColor() {
        if (rain) {
            if (rain.haveData) return "rgba(151,187,205,1)";
            else return "rgba(0,0,0,0)";
        } else {
            return "rgba(0,0,0,0)";
        }
    }
}
