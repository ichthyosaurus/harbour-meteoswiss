import QtQuick 2.6
import Sailfish.Silica 1.0
import "components"


Page {
    id: mainPage
    property int activeDay: 0

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
                onClicked: main.refreshData()
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: "MeteoSwiss"
            }

            ForecastItem {
                id: d0
                dayId: 0
                title: "Today"
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d1
                dayId: 1
                title: "Montag, 12. 11. 2018"
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d2
                dayId: 2
                title: "Dienstag, 13. 11. 2018"
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d3
                dayId: 3
                title: "Mittwoch, 14. 11. 2018"
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d4
                dayId: 4
                title: "Donnerstag, 15. 11. 2018"
                active: (activeDay == dayId)
            }

            ForecastItem {
                id: d5
                dayId: 5
                title: "Freitag, 16. 11. 2018"
                active: (activeDay == dayId)
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
