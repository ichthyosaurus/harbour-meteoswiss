import QtQuick 2.6
import Sailfish.Silica 1.0
import "components"


Page {
    id: mainPage
    property int locationId
    property int activeDay: 0
    property alias title: pageTitle.title
    allowedOrientations: Orientation.All

    signal activateGraph(int dayId)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        PullDownMenu {
            MenuItem {
                text: qsTr("Reload Data")
                onClicked: {
                    meteoApp.refreshData(locationId, true)
                }
            }
        }

        Column {
            id: column
            width: parent.width
            visible: (meteoApp.dataIsReady[locationId] && !meteoApp.forecastData[0].isSane) ? false : true

            PageHeader {
                id: pageTitle
            }

            Row {
                id: summaryRow
                width: parent.width

                Repeater {
                    model: meteoApp.forecastData.length

                    DaySummaryItem {
                        location: locationId
                        day: index
                        primary: true
                        selected: (index == activeDay)

                        Component.onCompleted: {
                            summaryClicked.connect(function(newDay, loc) {
                                activateGraph(newDay);
                            })
                            mainPage.activateGraph.connect(function(newDay) {
                                selected = (newDay == day);
                            })
                        }
                    }
                }
            }

            Repeater {
                model: meteoApp.forecastData.length

                ForecastItem {
                    dayId: index
                    visible: meteoApp.forecastData[index] ? true : false
                    active: (activeDay == index)

                    Component.onCompleted: {
                        mainPage.activateGraph.connect(function(newDay) {
                            active = (dayId == newDay);
                        })
                    }
                }
            }

            VerticalScrollDecorator {}
        }

        Column {
            id: failedColumn
            width: parent.width
            visible: !column.visible

            PageHeader {
                title: qsTr("MeteoSwiss")
            }

            Label {
                id: failed
                x: Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Failed to load data!") // TODO center etc.
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            VerticalScrollDecorator {}
        }
    }
}
