import QtQuick 2.0
import Sailfish.Silica 1.0
import "components"

import "../data/forecast.js" as ForecastData


Page {
    id: mainPage
    property int activeDay: 0

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
                title: "MeteoSwiss"
            }

            ForecastItem {
                dayId: 0
                title: "Today"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
                active: (activeDay == dayId)
            }

            ForecastItem {
                dayId: 1
                title: "Montag, 12. 11. 2018"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
                active: (activeDay == dayId)
            }

            ForecastItem {
                dayId: 2
                title: "Dienstag, 13. 11. 2018"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
                active: (activeDay == dayId)
            }

            ForecastItem {
                dayId: 3
                title: "Mittwoch, 14. 11. 2018"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
                active: (activeDay == dayId)
            }

            ForecastItem {
                dayId: 4
                title: "Donnerstag, 15. 11. 2018"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
                active: (activeDay == dayId)
            }

            ForecastItem {
                dayId: 5
                title: "Freitag, 16. 11. 2018"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
                active: (activeDay == dayId)
            }

            VerticalScrollDecorator {}
        }
    }
}
