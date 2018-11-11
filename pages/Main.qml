import QtQuick 2.0
import Sailfish.Silica 1.0
import "components"

import "../data/forecast.js" as ForecastData


Page {
    id: mainPage

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
                title: "Today"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
            }

            ForecastItem {
                title: "Montag, 12. 11. 2018"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
            }

            ForecastItem {
                title: "Dienstag, 13. 11. 2018"
                dataTemp: ForecastData.forecastTemp
                dataRain: ForecastData.forecastRain
            }

            VerticalScrollDecorator {}
        }
    }
}
