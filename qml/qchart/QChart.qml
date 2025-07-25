/*
 * This file is part of QChart.js, adapted for harbour-meteoswiss, harbour-forecasts, harbour-captains-log, and harbour-dashboard.
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2014  Julien Wintz
 * SPDX-FileCopyrightText: 2018-2019, 2022-2024  Mirian Margiani
 */

/* QChart.qml ---
 *
 * Author: Julien Wintz
 * Created: Thu Feb 13 20:59:40 2014 (+0100)
 * Version:
 * Last-Updated: jeu. mars  6 12:55:14 2014 (+0100)
 *           By: Julien Wintz
 *     Update #: 69
 */

/* Change Log:
 *
 */

// ADAPTED FOR HARBOUR-METEOSWISS
//
// Changes:
// - remove all chart types except line and bar
//


import QtQuick 2.0

import "QChart.js" as Charts

Canvas {

  id: canvas;

// ///////////////////////////////////////////////////////////////

  property   var chart;
  property   var chartData;
  property   int chartType: 0;
  property  bool chartAnimated: true;
  property alias chartAnimationEasing: chartAnimator.easing.type;
  property alias chartAnimationDuration: chartAnimator.duration;
  property   int chartAnimationProgress: 0;
  property   var chartOptions: ({})

  readonly property int chartStartX: __chartStartX
  readonly property int chartEndX: __chartEndX
  readonly property int chartValueHop: __chartValueHop

  property int __chartStartX: 20
  property int __chartEndX: width
  property int __chartValueHop: {
      if (chartData && chartData.hasOwnProperty('labels') &&
              chartData.labels.length > 0) {
          width / chartData.labels[0].length
      } else {
          10
      }
  }

// /////////////////////////////////////////////////////////////////
// Callbacks
// /////////////////////////////////////////////////////////////////

  onPaint: {
      var ctx = canvas.getContext("2d");
      /* Reset the canvas context to allow resize events to properly redraw
         the surface with an updated window size */
      ctx.reset()

      switch(chartType) {
      case Charts.ChartType.BAR:
          chart = new Charts.Chart(canvas, ctx).Bar(chartData, chartOptions);
          break;
      case Charts.ChartType.LINE:
          chart = new Charts.Chart(canvas, ctx).Line(chartData, chartOptions);
          break;
      default:
          console.log('Chart type should be specified.');
      }

      var metadata = chart.init();
      __chartStartX = metadata.chartStartX
      __chartEndX = metadata.chartEndX
      __chartValueHop = metadata.valueHop

      if (chartAnimated)
          chartAnimator.start();
      else
          chartAnimationProgress = 100;

      chart.draw(chartAnimationProgress/100);
  }

  onHeightChanged: {
    requestPaint();
  }

  onWidthChanged: {
    requestPaint();
  }

  onChartAnimationProgressChanged: {
      requestPaint();
  }

  onChartDataChanged: {
      requestPaint();
  }

// /////////////////////////////////////////////////////////////////
// Functions
// /////////////////////////////////////////////////////////////////

  function repaint() {
      chartAnimationProgress = 0;
      chartAnimator.start();
  }

// /////////////////////////////////////////////////////////////////
// Internals
// /////////////////////////////////////////////////////////////////

  PropertyAnimation {
             id: chartAnimator;
         target: canvas;
       property: "chartAnimationProgress";
             to: 100;
       duration: 500;
    easing.type: Easing.InOutQuad;
  }
}
