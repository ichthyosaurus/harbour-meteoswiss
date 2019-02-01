import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../../js/strings.js" as Strings
import "../../js/suncalc.js" as SunCalc
import "../../js/storage.js" as Storage


Column {
    id: forecast
    property string title: meteoApp.dataIsReady[locationId] ? formatTitleDate() : qsTr('Loading...')
    property bool active
    property int dayId

    width: parent.width

    Column {
        width: parent.width

        BackgroundItem {
            width: parent.width
            height: Theme.itemSizeSmall

            onClicked: active ? (
                meteoApp.dataIsReady[locationId] ? pageStack.push(
                    Qt.resolvedUrl("../TablePage.qml"), { name: title, day: dayId }
                ) : console.log("table locked")
            ) : mainPage.activateGraph(dayId)

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width-x-moreImage.width-moreImage.anchors.rightMargin
                id: titleLabel
                anchors {
                    rightMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                text: title
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Image {
                id: moreImage
                anchors {
                    left: titleLabel.right
                    rightMargin: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                source: "image://theme/icon-m-right?" + Theme.highlightColor
            }

            Rectangle {
                anchors.fill: parent
                z: -1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    Column {
        x: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
        width: parent.width - 2*x
        height: summaryRow.height + descriptionLabel.height + spacing

        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: graph.loaded ? 1 : 0
        visible: active

        spacing: Theme.paddingSmall

        Row {
            id: summaryRow
            width: parent.width

            Repeater {
                model: meteoApp.symbolHours.length

                ForecastSummaryItem {
                    visible: graph.loaded
                    hour: meteoApp.symbolHours[index]
                    day: dayId
                    clickedCallback: function(hour, symbol) {
                            descriptionLabel.text = String(
                                qsTr("%1: %2", "time (1) with weather description (2)")).arg(hour).arg(
                                    Strings.MeteoLang.weatherSymbolDescription[symbol]);
                        };
                }
            }
        }

        Label {
            id: descriptionLabel
            x: (parent.x + parent.width/2) - (width/2)
            width: parent.width - 4*parent.x

            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }


    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    ForecastGraphItem {
        id: graph
        visible: active
        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: active ? 1 : 0
        day: dayId
    }

    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    Label {
        id: sunTitle
        text: qsTr("Sun Times")
        x: titleLabel.x
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
    }

    Row {
        x: 0
        width: Screen.width

        Column {
            spacing: Theme.paddingSmall
            width: parent.width/2

            DetailItem {
                id: sunrise
                label: qsTr("Sunrise")
                value: ""
            }
            DetailItem {
                id: dawn
                label: qsTr("Dawn")
                value: ""
            }
            DetailItem {
                id: morningGoldenHourEnd
                label: qsTr("Golden Hour End")
                value: ""
            }
            DetailItem {
                id: solarNoon
                label: qsTr("Solar Noon")
                value: ""
            }
        }

        Column {
            spacing: Theme.paddingSmall
            width: parent.width/2

            DetailItem {
                id: eveningGoldenHour
                label: qsTr("Golden Hour")
                value: ""
            }
            DetailItem {
                id: sunset
                label: qsTr("Sunset")
                value: ""
            }
            DetailItem {
                id: night
                label: qsTr("Night")
                value: ""
            }
            DetailItem {
                id: nadir
                label: qsTr("Nadir")
                value: ""
            }
        }

        Component.onCompleted: {
            var locData = Storage.getLocationData(locationId);
            var date = new Date(meteoApp.forecastData[dayId].date);
            var times = SunCalc.SunCalc.getTimes(date, locData[0].latitude, locData[0].longitude);

            function set(target, value) {
                target.value = value.toLocaleString(Qt.locale(), meteoApp.timeFormat);
            }

            set(sunrise, times.sunrise);
            set(dawn, times.dawn);
            set(morningGoldenHourEnd, times.goldenHourEnd);
            set(solarNoon, times.solarNoon);
            set(eveningGoldenHour, times.goldenHour);
            set(sunset, times.sunset);
            set(night, times.night);
            set(nadir, times.nadir);
        }
    }

    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    Row {
        id: statusRow
        x: titleLabel.x
        visible: active ? (meteoApp.dataIsReady[locationId] ? true : false) : false

        property var textColor: Theme.secondaryColor
        property var textSize: Theme.fontSizeTiny

        Label {
            text: qsTr("status: ")
            color: parent.textColor
            font.pixelSize: parent.textSize
        }

        Label {
            id: statusLabel
            text: meteoApp.dataTimestamp ? meteoApp.dataTimestamp.toLocaleString(Qt.locale(), meteoApp.dateTimeFormat) : qsTr("unknown")
            color: parent.textColor
            font.pixelSize: parent.textSize
        }

        Label {
            text: " – " + qsTr("now: ")
            color: parent.textColor
            font.pixelSize: parent.textSize
        }

        Label {
            id: clockLabel
            text: new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
            color: parent.textColor
            font.pixelSize: parent.textSize
        }
    }

    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    function formatTitleDate() {
        return new Date(meteoApp.forecastData[dayId].date).toLocaleString(Qt.locale(), meteoApp.fullDateFormat);
    }

    function refreshTitle(data) {
        title = meteoApp ? (meteoApp.forecastData[dayId].date ? formatTitleDate() : qsTr('Failed...')) : qsTr('Failed...')

        if (statusRow) {
            statusLabel.text = (meteoApp ?
                (meteoApp.forecastData[dayId].date ?
                    meteoApp.dataTimestamp.toLocaleString(Qt.locale(), meteoApp.dateTimeFormat) : qsTr('unknown')) : qsTr('unknown'))
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(refreshTitle)
        meteoApp.dataIsLoading.connect(function(){
            title = qsTr("Loading...");

            if (statusRow) {
                statusLabel.text = qsTr("unknown")
            }
        })
    }

    Timer {
        id: clockTimer
        interval: 15*1000
        repeat: true
        running: true
        onTriggered: {
            clockLabel.text = new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
        }
    }
}
