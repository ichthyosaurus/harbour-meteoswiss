/*
 * This file is part of harbour-meteoswiss.
 * Copyright (C) 2018-2019  Mirian Margiani
 *
 * harbour-meteoswiss is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-meteoswiss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
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
