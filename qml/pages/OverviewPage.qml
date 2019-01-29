import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "components"

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings

Page {
    id: overviewPage

    signal loadingFinished(var locationId)
    signal dataUpdated(var newData, var locationId)

    function getTemperatureString(temperature) {
        return (temperature === undefined) ? "" : temperature + " °C";
    }

    function addLocationToModel(locationData, temperature, symbol) {
        if (!locationData) {
            console.log("error: failed to add location to model: invalid data")
            return
        }

        locationsModel.append({
            "locationId": locationData.locationId,
            "zip": locationData.zip,
            "name": locationData.name,
            "canton": locationData.canton,
            "cantonId": locationData.cantonId,
            "temperature": temperature,
            "temperatureString": getTemperatureString(temperature),
            "symbol": symbol,
        })
    }

    function addLocation(locationData) {
        console.log("add location", locationData.locationId, locationData.name);

        var res = Storage.addLocation(locationData.locationId, locationData.zip, locationData.name, locationData.cantonId, locationData.canton, locationsModel.count);

        if (res > 0) {
            addLocationToModel(locationData, undefined, undefined)
        }

        meteoApp.refreshData(locationData.locationId, true)
    }

    SilicaListView {
        id: locationsListView

        PullDownMenu {
            id: pulley
            busy: false

            Component.onCompleted: {
                overviewPage.dataUpdated.connect(function(newData, locationId) {
                    var readyList = Object.keys(meteoApp.dataIsReady).map(function(k) { return meteoApp.dataIsReady[k]; });
                    if (readyList.every(function(k) { return k ? true : false; })) {
                        busy = false
                    }
                });
                meteoApp.dataIsLoading.connect(function() { busy = true; });
            }

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Add location")
                onClicked: pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"))
            }

            MenuItem {
                text: qsTr("Refresh")
                visible: locationsModel.count > 0
                onClicked: {
                    meteoApp.refreshData(undefined, false);
                }
            }

            MenuItem {
                id: clockLabel
                text: new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
                visible: locationsModel.count > 0
            }
        }

        anchors.fill: parent

        header: PageHeader {
            title: qsTr("MeteoSwiss")
        }

        ViewPlaceholder {
            enabled: (locationsModel.count === 0)
            text: qsTr("Add a location first")
            hintText: qsTr("Pull down to add items")
        }

        model: ListModel { id: locationsModel }

        delegate: ListItem {
            id: locationItem
            property bool isLoading: false

            Component.onCompleted: {
                var idx = index;
                meteoApp.dataIsLoading.connect(function(loc) {
                    var locationId = locationsModel.get(idx).locationId;
                    if (locationId !== loc) return;
                    locationsModel.setProperty(idx, 'isLoading', true);
                });
                overviewPage.loadingFinished.connect(function(loc) {
                    var locationId = locationsModel.get(idx).locationId;
                    if (locationId !== loc) return;
                    locationsModel.setProperty(idx, 'isLoading', false);
                });
            }

            function showRemoveRemorser() {
                var idx = index
                var loc = locationId

                remorse.execute(locationItem, qsTr("Deleting"), function() {
                    locationsModel.remove(idx)
                    Storage.removeLocation(loc)
                }, 3000);
            }

            RemorseItem { id: remorse }

            ListView.onAdd: AddAnimation { target: locationItem }
            ListView.onRemove: animateRemoval()

            menu: contextMenuComp

            Component {
                id: contextMenuComp

                ContextMenu {
                    property bool moveItemsWhenClosed
                    property bool menuOpen: height > 0
                    property int locationId: model.locationId

                    onMenuOpenChanged: {
                        if (!menuOpen && moveItemsWhenClosed) {
                            locationsModel.move(model.index, 0, 1)
                            moveItemsWhenClosed = false

                            var pairs = []
                            for (var i = 0; i < locationsModel.count; i++) {
                                pairs.push({ locationId: locationsModel.get(i).locationId, position: i })
                            }
                            Storage.setOverviewPositions(pairs)
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

            contentHeight: labelColumn.implicitHeight + summaryRow.height + vertSpace.height + 2*Theme.paddingLarge

            function showForecast(activeDay) {
                meteoApp.refreshData(locationId, false)
                pageStack.animatorPush("ForecastPage.qml", {
                    "activeDay": activeDay,
                    "locationId": locationId,
                    "title": String("%1 %2 (%3)").arg(zip).arg(name).arg(cantonId),
                });
            }

            onClicked: {
                showForecast(0);
            }

            Image {
                id: icon
                visible: model.symbol > 0 ? true : false
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: labelColumn.verticalCenter
                width: 2.5*Theme.horizontalPageMargin
                height: width
                opacity: isLoading ? 0.2 : 1.0
                source: String("../weather-icons/%1.svg").arg(model.symbol ? model.symbol : "0")
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
                    text: String("%1 (%2)").arg(model.name).arg(model.cantonId)
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    id: descriptionLabel
                    property real lineHeight: height/lineCount

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

            Item { // vertical spacing
                id: vertSpace
                anchors.top: labelColumn.bottom
                height: Theme.paddingMedium
                width: parent.width
                visible: summaryRow.visible
            }

            Row {
                id: summaryRow
                width: parent.width
                anchors.top: vertSpace.bottom
                property var idx: index

                Repeater {
                    model: 6 // TODO make dynamic

                    DaySummaryItem {
                        location: locationId
                        day: index

                        Component.onCompleted: {
                            summaryClicked.connect(function(day, loc) { showForecast(day); })
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            console.log("loading all known locations...")
            var locs = Storage.getLocationData()
            for (var i = 0; i < locs.length; i++) {
                var summary = Storage.getDataSummary(locs[i].locationId)
                addLocationToModel(locs[i], summary.temperature, summary.symbol)
            }
        }

        VerticalScrollDecorator {}
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

    Timer {
        id: refreshTimer
        interval: 60*15*1000 // every 15 minutes
        repeat: true
        running: true
        onTriggered: {
            if (overviewPage.status === PageStatus.Active) {
                meteoApp.refreshData(undefined, false);
            }
        }
    }

    onStatusChanged: {
        if (overviewPage.status === PageStatus.Active) {
            dataUpdated(undefined, undefined);
        }
    }

    onDataUpdated: {
        if (locationId && !meteoApp.dataIsReady[locationId]) {
            console.log("summary not updated: data is not ready yet", meteoApp.dataIsReady[locationId], locationId);
            return;
        }

        console.log("updating overview summaries...");

        for (var i = 0; i < locationsModel.count; i++) {
            if (!locationId || (locationId === locationsModel.get(i).locationId)) {
                var loc = locationsModel.get(i).locationId;
                var summary = Storage.getDataSummary(loc);
                locationsModel.setProperty(i, 'temperature', summary.temp);
                locationsModel.setProperty(i, 'temperatureString', getTemperatureString(summary.temp));
                locationsModel.setProperty(i, 'symbol', summary.symbol);
                loadingFinished(loc);
            }
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(dataUpdated)
        meteoApp.locationAdded.connect(addLocation)
    }
}
