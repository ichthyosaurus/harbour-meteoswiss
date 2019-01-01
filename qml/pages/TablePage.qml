import QtQuick 2.6
import Sailfish.Silica 1.0


Page {
    id: tablePage
    property string name
    property int day
    property var rain
    property var temp
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
                title: "Detailed Forecast"
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
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge
                padding: Theme.horizontalPageMargin

                Label {
                    id: hourTitle
                    width: 150+Theme.paddingLarge+100+Theme.paddingLarge
                    text: "Hour"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: tempTitle
                    width: 300
                    text: "Temp."
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: rainTitle
                    width: 250
                    text: "Precip."
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: descriptionTitle
                    width: 700
                    text: "Description"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                    visible: isLandscape
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
        console.log("loading table for day " + day + "...")
        tableLoader.setSource("components/TableList.qml", {
            width: parent.width,
            data: msgData != null ? msgData : meteoApp.data
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
