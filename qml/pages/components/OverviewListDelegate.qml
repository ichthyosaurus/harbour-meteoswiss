/*
 * This file is part of harbour-meteoswiss.
 * Copyright (C) 2018-2020  Mirian Margiani
 *
 * harbour-meteoswiss is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-meteoswiss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage
import "../../js/strings.js" as Strings

ListItem {
    id: locationItem

    // parent list model, because 'model' property is not a full
    // ListModel but only a relay for the item's data (QQmlDMAbstractItemModelData)
    property var parentModel

    property bool isLoading: false
    property bool initialLoadingDone: false
    contentHeight: labelColumn.height + (overviewColumn.visible ? overviewColumn.height : 0) + vertSpace.height + labelColumn.y

    signal orderChanged()
    signal refreshWeekSummary()

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
                onClicked: removeWithRemorser()
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
        anchors {
            left: parent.left; leftMargin: Theme.horizontalPageMargin
            verticalCenter: labelColumn.verticalCenter
        }

        width: 2.5*Theme.horizontalPageMargin; height: width
        source: String("../../weather-icons/%1.svg").arg(model.symbol ? model.symbol : "0")
        fillMode: Image.PreserveAspectFit

        opacity: isLoading ? 0.2 : 1.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        BusyIndicator {
            anchors.centerIn: parent
            visible: isLoading ? true : false
            running: visible
        }
    }

    Column {
        id: labelColumn
        anchors {
            top: parent.top; topMargin: Theme.paddingMedium
            left: icon.right; leftMargin: Theme.paddingMedium
            right: temperatureLabel.left; rightMargin: Theme.paddingSmall
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
            text: (!Strings.weatherSymbolDescription[model.symbol] ? zip : String("%1 – %2").arg(zip).arg(Strings.weatherSymbolDescription[model.symbol]))
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade
            wrapMode: Text.Wrap

            onTextChanged: NumberAnimation {
                target: descriptionLabel; property: "opacity"
                duration: 500
                easing.type: Easing.InOutQuad
                from: 0.0; to: 1.0
            }
        }
    }

    Label {
        id: temperatureLabel
        text: temperatureString
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeHuge

        onTextChanged: NumberAnimation {
            target: temperatureLabel; property: "opacity"
            duration: 500
            easing.type: Easing.InOutQuad
            from: 0.0; to: 1.0
        }

        anchors {
            top: parent.top; topMargin: Theme.paddingSmall
            right: parent.right; rightMargin: Theme.horizontalPageMargin
        }
    }

    VerticalSpacing { id: vertSpace; anchors.top: labelColumn.bottom }

    Column {
        id: overviewColumn
        visible: index < 3 // show only first 3 locations with details
        width: parent.width
        anchors.top: vertSpace.bottom

        DayOverviewGraphItem {
            id: chart
            location: locationId
            day: -1
            width: parent.width
            height: 1.5*icon.height
            property string dayToShow: ""
        }

        Row {
            id: summaryRow
            width: parent.width
            property int dayCount: 0

            signal refresh(var newDayCount)
            onRefresh: {
                // changing the model forces the repeater to rebuild its children
                var oldCount = dayCount; dayCount = 0;
                if (oldCount === newDayCount || newDayCount === undefined) {
                    dayCount = oldCount;
                } else {
                    dayCount = newDayCount;
                }
            }

            Repeater {
                id: summaryRepeater
                model: summaryRow.dayCount
                property int currentSelection: 0

                DaySummaryItem {
                    location: locationId
                    day: index
                    dayCount: summaryRow.dayCount
                    selected: summaryRepeater.currentSelection === index
                    highlightedColor: "transparent"

                    onSummaryClicked: {
                        if (summaryRepeater.currentSelection === index) return
                        showDayChart(index)
                    }
                    onIsTodayChanged: {
                        if (isToday) { // reset chart and selection to today
                            showDayChart(index)
                        }
                    }
                }
            }
        }
    }

    onRefreshWeekSummary: {
        var meta = Storage.getLatestMetadata(locationId);
        var dayCount = (overviewColumn.visible && meta && meta.dayCount) ? meta.dayCount : 0
        summaryRow.refresh(dayCount);
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.secondaryColor, 0.05) }
        }
    }

    RemorseItem { id: remorse }

    function removeWithRemorser() {
        remorse.execute(locationItem, qsTr("Deleting"), function() {
            Storage.removeLocation(locationId);
            var idx = index; // index is reset in animateRemoval() but item is not removed
            animateRemoval(parent);
            parentModel.remove(idx);
        }, 3000);
    }

    function showForecast(activeDay) {
        meteoApp.refreshData(locationId, false)

        // there seems to be a bug in the page stack implementation
        // that breaks animatorPush in landscape mode (as of 2020-04-25)
        var pusher = pageStack.animatorPush // pushes, then load the page
        if (isLandscape) pusher = pageStack.push // first loads the page, then pushes

        pusher("../ForecastPage.qml", {
            "activeDay": activeDay,
            "locationId": locationId,
            "title": String("%1 %2 (%3)").arg(zip).arg(name).arg(cantonId),
        });
    }

    function showDayChart(index) {
        summaryRepeater.currentSelection = index
        chart.loadChart(index)
    }

    onClicked: showForecast(summaryRepeater.currentSelection);

    Timer {
        id: loadingCooldown
        interval: 500
        repeat: false
        running: false
        onTriggered: isLoading = false;
    }

    Timer {
        id: loadingMinWait
        interval: 1000
        repeat: false
        running: false
    }

    Timer {
        id: initialLoadingTimer
        interval: 50
        repeat: false
        running: false
        onTriggered: {
            if (meteoApp.dataIsReady[locationId]) {
                isLoading = false;
            } else {
                restart();
            }
        }
    }

    Component.onCompleted: {
        // This is needed to circumvent a nasty visual bug: when
        // refreshing immediately after finishing the main component, the busy
        // indicator of the first entry won't be triggered. Therefore we need
        // to initially "force show" the spinner.
        isLoading = true;
        initialLoadingTimer.restart();

        meteoApp.dataIsLoading.connect(function(loc) {
            if (locationId === loc) {
                isLoading = true;
                loadingMinWait.restart();
            }
        });

        meteoApp.dataLoaded.connect(function(unused, newLocation) {
            if (newLocation !== undefined && newLocation !== locationId) return
            else refreshWeekSummary(); // force refresh summaries
        })

        overviewPage.loadingFinished.connect(function(loc) {
            if (locationId === loc) {
                if (initialLoadingDone) {
                    if (loadingMinWait.running) {
                        loadingCooldown.restart();
                    } else {
                        isLoading = false;
                    }
                } else {
                    initialLoadingDone = true;
                    isLoading = false;
                }
            }
        });

        orderChanged.connect(function() {
            parentModel.move(index, 0, 1)

            var pairs = []
            for (var i = 0; i < parentModel.count; i++) {
                pairs.push({ locationId: parentModel.get(i).locationId, viewPosition: i })
            }

            Storage.setOverviewPositions(pairs)
        });
    }
}
