import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings

CoverBackground {
    id: coverPage
    property int location: 0
    property var summary: undefined
    property var locationData: undefined

    Label {
        id: label
        visible: location == 0
        anchors.centerIn: parent
        text: qsTr("MeteoSwiss")
    }

    Item {
        visible: location != 0
        width: parent.width - 2*Theme.paddingLarge

        Column {
            x: Theme.paddingLarge
            width: parent.width

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                text: (summary.temp === undefined) ? locationData.name : summary.temp + " °C " + locationData.name
                width: parent.width
                truncationMode: TruncationMode.Fade
            }

            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: Strings.MeteoLang.weatherSymbolDescription[summary.symbol]  // weather string
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
        meteoApp.dataLoaded.connect(updateData)
    }
}
