/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

import MeteoSwiss.Locations 1.0
import Opal.Delegates 1.0

Page {
    id: root

    property string _query
    property var _queryRegex: new RegExp(_query, 'i')
    property Item _searchField

    on_QueryChanged: {
        LocationsModel.search = _query
        _searchField.forceActiveFocus()
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: LocationsModel

        VerticalScrollDecorator {}

        ViewPlaceholder {
           enabled: !LocationsModel.haveDatabase
           text: qsTr("Database missing")
           hintText: qsTr("Try reinstalling the app.")
        }

        ViewPlaceholder {
            enabled: LocationsModel.haveDatabase &&
                     listView.count === 0
            hintText: qsTr("Type to find a location by " +
                           "name or by zip code.")
        }

        header: Column {
            width: root.width

            PageHeader {
                title: qsTr("Add Location")
            }

            SearchField {
                id: searchField
                width: parent.width
                enabled: LocationsModel.haveDatabase
                placeholderText: qsTr("Search")
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: root._query = text
                EnterKey.onClicked: {
                    if (!!text) searchField.focus = false
                }

                Component.onCompleted: {
                    _searchField = searchField
                }
            }
        }

        delegate: TwoLineDelegate {
            id: listItem
            text: Theme.highlightText(model.name, root._queryRegex, Theme.highlightColor)
            description: model.name !== model.primaryName ?
                Theme.highlightText(model.primaryName, root._queryRegex, Theme.highlightColor)
                : " "
            textLabel.font.pixelSize: Theme.fontSizeLarge
            descriptionLabel.font.pixelSize: Theme.fontSizeExtraSmall

            leftItem: DelegateInfoItem {
                alignment: Qt.AlignRight
                text: Theme.highlightText(model.zip, root._queryRegex, Theme.highlightColor)
                textLabel.palette {
                    primaryColor: Theme.secondaryColor
                    highlightColor: Theme.secondaryHighlightColor
                }

                description: model.altitude + "m"
                descriptionLabel.font.pixelSize: Theme.fontSizeExtraSmall
            }

            onClicked: {
                meteoApp.locationAdded({
                    locationId: model.locationId,
                    altitude: model.altitude,
                    latitude: model.latitude,
                    longitude: model.longitude,
                    zip: parseInt(model.zip, 10),
                    name: model.name,
                    active: true,
                })
                pageStack.pop()
            }
        }
    }

    on_SearchFieldChanged: _searchField.forceActiveFocus()
    Component.onCompleted: {
        LocationsModel.search = ""
        _searchField && _searchField.forceActiveFocus()
    }
}
