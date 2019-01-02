import QtQuick 2.6
import Sailfish.Silica 1.0
import "components"


Page {
    id: mainPage
    property int location
    property int activeDay: 0
    property alias title: pageTitle.title
    allowedOrientations: Orientation.All

    signal activateGraph(int dayId)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: meteoApp.refreshData(location)
            }
        }

        Column {
            id: column
            width: parent.width
            visible: (meteoApp.dataIsReady && !meteoApp.forecastData[0].isSane) ? false : true

            PageHeader {
                id: pageTitle
            }

            ForecastItem {
                id: d0
                dayId: 0
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d1
                dayId: 1
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d2
                dayId: 2
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d3
                dayId: 3
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d4
                dayId: 4
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d5
                dayId: 5
                active: (activeDay == dayId)
            }

            VerticalScrollDecorator {}
        }

        Column {
            id: failedColumn
            width: parent.width
            visible: !column.visible

            PageHeader {
                title: qsTrId("MeteoSwiss")
            }

            Label {
                id: failed
                x: Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTrId("Failed to load data!") // TODO center etc.
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            VerticalScrollDecorator {}
        }
    }

    onActivateGraph: {
        if (dayId == 0) {
            d0.active = true
            d1.active = false
            d2.active = false
            d3.active = false
            d4.active = false
            d5.active = false
        } else if (dayId == 1) {
            d0.active = false
            d1.active = true
            d2.active = false
            d3.active = false
            d4.active = false
            d5.active = false
        } else if (dayId == 2) {
            d0.active = false
            d1.active = false
            d2.active = true
            d3.active = false
            d4.active = false
            d5.active = false
        } else if (dayId == 3) {
            d0.active = false
            d1.active = false
            d2.active = false
            d3.active = true
            d4.active = false
            d5.active = false
        } else if (dayId == 4) {
            d0.active = false
            d1.active = false
            d2.active = false
            d3.active = false
            d4.active = true
            d5.active = false
        } else if (dayId == 5) {
            d0.active = false
            d1.active = false
            d2.active = false
            d3.active = false
            d4.active = false
            d5.active = true
        }
    }
}
