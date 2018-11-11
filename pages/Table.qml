import QtQuick 2.0
import Sailfish.Silica 1.0

import "../qchart/"
import "../qchart/QChart.js" as Charts
import "../data/forecast.js" as ForecastData


Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: "TABLE"
            }

            Item {
                height: chart.height
                width: parent.width - (Theme.horizontalPageMargin * 2)
                x: Theme.horizontalPageMargin
                clip: true

                SilicaFlickable {
                    anchors.fill: parent
                    flickableDirection: Flickable.HorizontalFlick

                    contentHeight: row.height
                    contentWidth: row.width

                    Row {
                        id: row
                        width: chart.width + (2 * spacing)
                        height: chart.height
                        spacing: Theme.paddingLarge

                        Column {
                            id: chart
                            height: 1500
                            width: 2000
                            spacing: Theme.paddingLarge

                            Label {
                                id: titleLabel
                                text: "Today"
                                color: Theme.secondaryHighlightColor
                                font.bold: true
                            }

                            QChart {
                                id: tempChart
                                width: parent.width
                                height: 500
                                chartAnimated: false
                                chartData: ForecastData.forecastTemp
                                chartType: Charts.ChartType.LINE
                                chartOptions: ({
                                    scaleFontSize: Theme.fontSizeExtraSmall,
                                    scaleFontFamily: 'Sail Sans Pro',
                                    scaleFontColor: Theme.secondaryColor,
                                    scaleLineColor: Theme.secondaryColor,
                                    scaleStepWidth: 0.5,
                                    bezierCurve: true,
                                })
                            }

                            QChart {
                                id: rainChart
                                width: parent.width
                                height: 290
                                chartAnimated: false
                                chartData: ForecastData.forecastRain
                                chartType: Charts.ChartType.BAR
                                chartOptions: ({
                                    scaleFontSize: Theme.fontSizeExtraSmall,
                                    scaleFontFamily: 'Sail Sans Pro',
                                    scaleFontColor: Theme.secondaryColor,
                                    scaleLineColor: Theme.secondaryColor,
                                    scaleShowLabels: true,
                                })
                            }
                        }
                    }
                }
            }

            VerticalScrollDecorator {}
        }
    }
}
