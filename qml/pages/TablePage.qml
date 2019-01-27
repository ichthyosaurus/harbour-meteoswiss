import QtQuick 2.6
import Sailfish.Silica 1.0


Page {
    id: tablePage
    property string name
    property int day
    property var rain
    property var temp
    property var wind
    property bool loaded: false
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Detailed Forecast")
            }

            Label {
                id: title
                x: Theme.horizontalPageMargin
                text: name
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Row {
                id: headers
                width: parent.width
                x: parent.x

                spacing: Theme.paddingLarge
                padding: Theme.horizontalPageMargin

                Label {
                    id: hourTitle
                    width: 70
                    text: qsTr("Hour")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: symbolTitle
                    width: 100
                }

                Label {
                    id: tempTitle
                    width: 200
                    text: qsTr("Temp.")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: rainTitle
                    width: 250
                    text: qsTr("Precip.")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: windTitle
                    width: 250
                    text: qsTr("Wind")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: windSymTitle
                    visible: isLandscape
                    width: 100
                }

                Label {
                    id: descriptionTitle
                    visible: isLandscape
                    width: 500
                    text: qsTr("Description")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                }
            }

            Column {
                id: waitingForData
                width: tablePage.width

                Behavior on opacity { NumberAnimation { duration: 500 } }
                opacity: tablePage.loaded ? 0 : 1
                visible: tablePage.loaded ? false : true

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: !tablePage.loaded
                    size: BusyIndicatorSize.Medium
                }
            }

            Loader {
                id: tableLoader
                onLoaded: {
                    tablePage.loaded = true
                    item.refreshModel()
                }
            }

            VerticalScrollDecorator {}
        }
    }

    function loadTable(msgData) {
        if (day === null) return
        console.log("loading table for day " + day + "...")
        tableLoader.setSource("components/TableList.qml", {
            width: parent.width,
            forecastData: msgData ? msgData : meteoApp.forecastData
        })
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(loadTable)
        meteoApp.dataIsLoading.connect(function(){ if (tablePage) tablePage.loaded = false })

        if (meteoApp.dataIsReady) {
            loadTable()
        }
    }
}
