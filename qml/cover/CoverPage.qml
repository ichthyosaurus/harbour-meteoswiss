import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../js/storage.js" as Storage

CoverBackground {
    id: coverPage
    property int location: 0
    property var summary: null
    property var locationData: null

    Label {
        id: label
        anchors.centerIn: parent
        text: qsTrId("MeteoSwiss")
    }

    Item {
        Column {
            x: Theme.paddingLarge
            width: parent.width - 2*x

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                text: summary.temp + " °C " + locationData.name
                width: parent.width
                truncationMode: TruncationMode.Fade
            }

            Label {
                width: parent.width
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: ''  // weather string
            }
        }

        Image {
            height: width
            width: parent.width - Theme.paddingLarge
            sourceSize.width: width
            sourceSize.height: width
            source: "../weather-icons/" + (summary.symbol ? summary.symbol : "0") + ".svg"
            anchors {
                centerIn: parent
                verticalCenterOffset: Theme.paddingSmall
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                location = Storage.getNextCoverZip(location)
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
        Storage.setCoverZip(location)
        summary = Storage.getDataSummary(location)
        locationData = Storage.getLocationData(location)

        if (locationData) {
            locationData = locationData[0]
        } else {
            console.log("error: failed to load location metadata")
        }
    }

    Component.onCompleted: {
        location = Storage.getCoverZip()
        location = location > 0 ? location : Storage.getNextCoverZip()
        updateData()
    }
}
