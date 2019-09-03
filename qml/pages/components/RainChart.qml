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
    id: rainChart
    property bool scaleOnly: false
    property bool isToday: false
    property bool asOverview: false

    chartAnimated: false
    chartData: rain ? rain : { labels: [], datasets: [{ fillColor: getFillColor(), strokeColor: getStrokeColor(), pointColor: "rgba(0,0,0,0)", data: [] }]}
    chartType: Charts.ChartType.BAR
    chartOptions: ({
        scaleFontSize: Theme.fontSizeExtraSmall * (asOverview ? (4/5) : 1),
        scaleFontFamily: 'Sail Sans Pro',
        scaleFontColor: Theme.secondaryColor,
        scaleLineColor: Theme.secondaryColor,
        scaleShowLabels: true,
        scaleStartValue: 0.0,
        scaleOverlay: scaleOnly,
        currentHourLine: isToday,
        barOverlay: true,
        asOverview: asOverview,

        fillColor: [getFillColor(), "rgba(151,187,205,0.1)", "rgba(151,187,205,0.1)"],
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
