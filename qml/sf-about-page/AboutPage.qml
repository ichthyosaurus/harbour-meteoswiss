/*
 * This file is part of sf-about-page.
 * Copyright (C) 2020  Mirian Margiani
 *
 * sf-about-page is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sf-about-page is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with sf-about-page.  If not, see <http://www.gnu.org/licenses/>.
 *
 * FILE VERSION: 1.0 (2020-04-17)
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property string appName: "this app"  // the name of your app
    property string iconPath: ""         // e.g. "/usr/share/icons/hicolor/172x172/apps/harbour-jammy.png"
    property string versionNumber: "1.0" // e.g. 'VERSION_NUMBER' if you configured it via C++
    property string description: ""      // a rich text description of your app
    property string author: ""           // the main author(s) or maintainer(s)
    property string dataInformation: ""  // if your app uses data from an external provider, add e.g. copyright
                                         // info here
    property string dataLink: ""         // a link to the website of an external provider
    property string dataLinkText: ""     // custom button text
    property string sourcesLink: ""      // where users can get your app's source code
    property string sourcesText: ""      // custom button text, e.g. qsTr("Sources on GitHub")

    property bool enableContributorsPage: false // whether to enable 'ContributorsPage.qml'
    property var contribDevelopment: []
    property var contribTranslations: []

    // don't change this unless you change license.html
    property string shortLicenseText: "GNU GPL version 3 or later.\n" +
                                      "This is free software: you are free to change and redistribute it." +
                                      "There is NO WARRANTY, to the extent permitted by law."

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            PageHeader {
                title: qsTr("About %1").arg(appName)
            }

            width: parent.width
            spacing: Theme.paddingLarge

            Image {
                x: (parent.width/2)-(Theme.itemSizeExtraLarge/2)
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                source: iconPath
                verticalAlignment: Image.AlignVCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: String(qsTr("Version %1")).arg(versionNumber)
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                x: 2*Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: '<style type="text/css">A { color: "#ffffff"; }</style>' + description
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeMedium
            }

            Item { width: parent.width; height: Theme.paddingMedium }
            BackgroundItem {
                anchors.left: parent.left; anchors.right: parent.right
                height: contributorsColumn.height
                onClicked: pageStack.push(Qt.resolvedUrl("ContributorsPage.qml"), {
                    development: contribDevelopment,
                    translations: contribTranslations
                })
                enabled: enableContributorsPage

                Column {
                    id: contributorsColumn
                    x: Theme.horizontalPageMargin; width: parent.width - 2*x
                    spacing: Theme.paddingSmall

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: enableContributorsPage ? qsTr("Development") : qsTr("Author")
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeLarge
                    }
                    Item { width: parent.width; height: Theme.paddingMedium }
                    Label {
                        width: parent.width; horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap; font.pixelSize: Theme.fontSizeMedium
                        text: author
                    }
                    Row {
                        anchors.right: parent.right; spacing: Theme.paddingSmall
                        visible: enableContributorsPage
                        Label {
                            id: showContributorsLabel
                            textFormat: Text.StyledText; font.pixelSize: Theme.fontSizeExtraSmall
                            text: qsTr("<i>show contributors </i>")
                        }
                        Label { anchors.verticalCenter: showContributorsLabel.verticalCenter; text: "\u2022 \u2022 \u2022" } // three dots
                    }
                }
            }

            Item { width: parent.width; height: Theme.paddingMedium; visible: (dataInformation || dataLink) }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Data")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
                visible: dataInformation || dataLink
            }
            Label {
                x: 2*Theme.horizontalPageMargin
                width: parent.width - 2*x
                visible: dataInformation ? true : false
                text: '<style type="text/css">A { color: "#ffffff"; }</style>' + dataInformation
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeMedium
            }
            Button {
                visible: dataLink ? true : false
                anchors.horizontalCenter: parent.horizontalCenter
                text: dataLinkText ? dataLinkText : qsTr("Website")
                onClicked: { Qt.openUrlExternally(dataLink) }
            }

            Item { width: parent.width; height: Theme.paddingMedium }
            BackgroundItem {
                anchors.left: parent.left; anchors.right: parent.right
                height: aboutColumn.height
                onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))

                Column {
                    id: aboutColumn
                    x: Theme.horizontalPageMargin; width: parent.width - 2*x
                    spacing: Theme.paddingSmall

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("License")
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeLarge
                    }
                    Item { width: parent.width; height: Theme.paddingMedium }
                    Label {
                        width: parent.width; horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap; font.pixelSize: Theme.fontSizeMedium
                        text: shortLicenseText
                    }
                    Row {
                        anchors.right: parent.right; spacing: Theme.paddingSmall
                        Label {
                            id: showLicenseLabel
                            textFormat: Text.StyledText; font.pixelSize: Theme.fontSizeExtraSmall
                            text: qsTr("<i>show license </i>")
                        }
                        Label { anchors.verticalCenter: showLicenseLabel.verticalCenter; text: "\u2022 \u2022 \u2022" } // three dots
                    }
                }
            }

            Button {
                visible: sourcesLink ? true : false
                anchors.horizontalCenter: parent.horizontalCenter
                text: sourcesText ? sourcesText : qsTr("Source Code")
                onClicked: { Qt.openUrlExternally(sourcesLink) }
            }

            Item {
                id: bottomVerticalSpacing
                width: parent.width
                height: Theme.horizontalPageMargin
            }
        }
    }
}
