import QtQuick 2.6
import Sailfish.Silica 1.0
import "components"

Page {
    SilicaListView {
        id: locationsListView

        PullDownMenu {
            MenuItem {
                text: qsTrId("New location")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("LocationSearchPage.qml"))
            }

            MenuItem {
                text: qsTrId("Refresh")
                onClicked: reloadTimer.restart()

                Timer {
                    id: reloadTimer
                    interval: 60*60*1000
                    onTriggered: meteoApp.refreshData()
                }
            }
        }

        anchors.fill: parent

        header: PageHeader {
            title: qsTrId("MeteoSwiss")
        }

        model: ListModel { id: locationsModel }

        delegate: ListItem {
            id: locationItem

            function remove() {
                locationsModel.remove(model.index)
            }

            ListView.onAdd: AddAnimation { target: locationItem }
            ListView.onRemove: animateRemoval()

            menu: contextMenuComp

            Component {
                id: contextMenuComp
                ContextMenu {
                    property bool moveItemsWhenClosed
                    property bool menuOpen: height > 0

                    onMenuOpenChanged: {
                        if (!menuOpen && moveItemsWhenClosed) {
                            locationsModel.moveToTop(model.index)
                            moveItemsWhenClosed = false
                        }
                    }

                    MenuItem {
                        text: qsTrId("Remove")
                        onClicked: remove()
                    }

                    // MenuItem {
                    //     text: "Move to top"
                    //     visible: model.index !== 0
                    //     onClicked: moveItemsWhenClosed = true
                    // }
                }
            }

            contentHeight: labelColumn.implicitHeight + 2*Theme.paddingMedium

            onClicked: {
                meteoApp.refreshData(locationId)
                pageStack.animatorPush("ForecastPage.qml", {
                    "activeDay": 0,
                    "location": locationId,
                    "title": model.locationId + " " + model.name + " (" + model.cantonId + ")",
                })
            }

            Image {
                id: icon
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: labelColumn.verticalCenter
                width: 2.5*Theme.horizontalPageMargin
                height: width
                source: "../weather-icons/" + model.symbol + ".svg"
            }

            Column {
                id: labelColumn

                y: Theme.paddingMedium
                height: locationLabel.height + descriptionLabel.lineHeight

                anchors {
                    left: icon.right
                    right: temperatureLabel.left
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                }

                Label {
                    id: locationLabel
                    width: parent.width
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: model.name
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    id: descriptionLabel
                    property real lineHeight: height/lineCount

                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: model.locationId + " - " + model.canton + " (" + model.cantonId + ")"
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                }
            }

            Label {
                id: temperatureLabel
                text: model.savedTemperature + " °C"
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeHuge

                anchors {
                    verticalCenter: labelColumn.verticalCenter
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
            }
        }

        Component.onCompleted: {
            locationsModel.append({
                "locationId": 4143,
                "name": "Dornach",
                "canton": "Solothurn",
                "cantonId": "SO",
                "savedTemperature": 10,
                "symbol": 3,
            })
            locationsModel.append({
                "locationId": 4001,
                "name": "Basel",
                "canton": "Basel-Stadt",
                "cantonId": "BS",
                "savedTemperature": 7,
                "symbol": 14,
            })
            locationsModel.append({
                "locationId": 8001,
                "name": "Zürich",
                "canton": "Zürich",
                "cantonId": "ZH",
                "savedTemperature": 0,
                "symbol": 1,
            })
        }

        VerticalScrollDecorator {}
    }
}
