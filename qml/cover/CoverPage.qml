import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings

CoverBackground {
    id: coverPage
    property int locationId: undefined
    property var summary: undefined
    property var locationData: undefined

    Label {
        id: label
        visible: !locationId
        anchors.centerIn: parent
        text: qsTr("MeteoSwiss")
    }

    Item {
        visible: (locationId ? true : false)
        width: parent.width - 2*Theme.paddingLarge

        Column {
            x: Theme.paddingLarge
            width: parent.width

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                text: (locationData ? (locationData.name ? (summary.temp ? summary.temp + " °C " + locationData.name : locationData.name) : '') : '')
                width: parent.width
                truncationMode: TruncationMode.Fade
            }

            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: summary.symbol ? Strings.weatherSymbolDescription[summary.symbol] : ""  // weather string
                truncationMode: TruncationMode.Fade
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Image {
                x: Theme.paddingLarge
                width: parent.width - 2*x
                height: width
                sourceSize.width: width
                sourceSize.height: height
                source: "../weather-icons/" + (summary.symbol ? summary.symbol : "0") + ".svg"
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                locationId = Storage.getNextCoverLocation(locationId)
                updateData()
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../pages/LocationSearchPage.qml"))
                meteoApp.activate()
            }
        }
    }

    function updateData() {
        Storage.setCoverLocation(locationId)
        summary = Storage.getDataSummary(locationId)
        locationData = Storage.getLocationData(locationId)

        if (locationData) {
            locationData = locationData[0]
        } else {
            console.log("error: failed to load location metadata for", locationId)
        }
    }

    Component.onCompleted: {
        var loc = Storage.getCoverLocation()
        if (!loc) {
            loc = Storage.getNextCoverLocation()
        }

        locationId = loc

        updateData()
        meteoApp.dataLoaded.connect(updateData)
    }
}
