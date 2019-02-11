import QtQuick 2.6
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage
import "../../js/strings.js" as Strings

ListItem {
    id: locationItem

    property bool isLoading: false
    contentHeight: labelColumn.height + (overviewColumn.visible ? overviewColumn.height : 0) + vertSpace.height + labelColumn.y

    signal orderChanged()

    menu: Component {
        ContextMenu {
            property bool moveItemsWhenClosed
            property bool menuOpen: height > 0
            property int locationId: model.locationId

            onMenuOpenChanged: {
                if (!menuOpen && moveItemsWhenClosed) {
                    orderChanged();
                    moveItemsWhenClosed = false;
                }
            }

            MenuItem {
                text: qsTr("Remove")
                onClicked: showRemoveRemorser()
            }

            MenuItem {
                text: qsTr("Move to top")
                visible: model.index !== 0
                onClicked: moveItemsWhenClosed = true
            }
        }
    }

    Image {
        id: icon
        visible: model.symbol > 0 ? true : false
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: labelColumn.verticalCenter
        width: 2.5*Theme.horizontalPageMargin
        height: width
        opacity: isLoading ? 0.2 : 1.0
        source: String("../../weather-icons/%1.svg").arg(model.symbol ? model.symbol : "0")
        fillMode: Image.PreserveAspectFit
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    BusyIndicator {
        anchors.centerIn: icon
        visible: isLoading ? true : false
        running: visible
    }

    Column {
        id: labelColumn

        y: Theme.paddingMedium
        height: locationLabel.height + descriptionLabel.height

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
            text: String("%1 (%2)").arg(model.name).arg(model.cantonId)
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: descriptionLabel
            width: parent.width
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            text: (!Strings.MeteoLang.weatherSymbolDescription[model.symbol] ? zip : String("%1 – %2").arg(zip).arg(Strings.MeteoLang.weatherSymbolDescription[model.symbol]))
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade
            wrapMode: Text.Wrap

            onTextChanged:
                NumberAnimation {
                    target: descriptionLabel
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.InOutQuad
                    from: 0.0
                    to: 1.0
                }
        }
    }

    Label {
        id: temperatureLabel
        text: temperatureString
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeHuge

        onTextChanged:
            NumberAnimation {
                target: temperatureLabel
                property: "opacity"
                duration: 500
                easing.type: Easing.InOutQuad
                from: 0.0
                to: 1.0
            }

        anchors {
            verticalCenter: labelColumn.verticalCenter
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
    }

    VerticalSpacing {
        id: vertSpace
        anchors.top: labelColumn.bottom
    }

    Column {
        id: overviewColumn
        visible: index < 3 // show only first 3 locations with details
        anchors.top: vertSpace.bottom

        Loader {
            asynchronous: true
            visible: status == Loader.Ready
            width: (isPortrait ? Screen.width : Screen.height) - Theme.paddingMedium
            height: labelColumn.height

            Component.onCompleted: {
                setSource("DayOverviewGraphItem.qml", {location: locationId, day: 0})
            }
        }

        Row {
            id: summaryRow
            width: parent.width
            property var full: defaultFor(Storage.getData(locationId), [{date: Date.now(), dayCount: 0}])

            Repeater {
                model: summaryRow.full[0] && summaryRow.full[0].dayCount

                DaySummaryItem {
                    location: locationId
                    day: index
                    dayCount: summaryRow.full[0] && summaryRow.full[0].dayCount

                    Component.onCompleted: {
                        summaryClicked.connect(function(day, loc) { showForecast(day); })
                    }
                }
            }
        }
    }

    Rectangle {
        visible: index >= 3 || overviewColumn.height == 0
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.secondaryColor, 0.05) }
        }
    }


    ListView.onAdd: AddAnimation { target: locationItem }

    ListView.onRemove: {
        animateRemoval()
    }

    onClicked: {
        showForecast(0);
    }

    Component.onCompleted: {
        meteoApp.dataIsLoading.connect(function(loc) {
            if (locationId == loc) isLoading = true;
        });

        overviewPage.loadingFinished.connect(function(loc) {
            if (locationId == loc) isLoading = false;
        });
    }

    RemorseItem { id: remorse }

    function showRemoveRemorser() {
        remorse.execute(locationItem, qsTr("Deleting"), function() {
            ListView.remove(index)
            Storage.removeLocation(locationId)
        }, 3000);
    }

    function showForecast(activeDay) {
        meteoApp.refreshData(locationId, false)
        pageStack.animatorPush("../ForecastPage.qml", {
            "activeDay": activeDay,
            "locationId": locationId,
            "title": String("%1 %2 (%3)").arg(zip).arg(name).arg(cantonId),
        });
    }
}
