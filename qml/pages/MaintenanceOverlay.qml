/*
 * This file is part of harbour-meteoswiss.
 * Copyright (C) 2018-2019  Mirian Margiani
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

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: Theme.highlightDimmerColor
    visible: false

    property alias text: placeholder.text
    property alias hintText: placeholder.hintText

    SilicaListView {
        anchors.fill: parent
        model: 0

        ViewPlaceholder {
            id: placeholder
            enabled: true
        }
    }

    states: [
        State{
            name: "visible"
            PropertyChanges{ target: root; opacity: 1.0 }
            PropertyChanges{ target: root; visible: true }
        },
        State{
            name:"invisible"
            PropertyChanges{ target: root; opacity: 0.0 }
            PropertyChanges{ target: root; visible: false }
        }
    ]

    transitions: [
        Transition {
            from: "visible"
            to: "invisible"

            SequentialAnimation {
               NumberAnimation {
                   target: root
                   property: "opacity"
                   duration: 500
                   easing.type: Easing.InOutQuad
               }
               NumberAnimation {
                   target: root
                   property: "visible"
                   duration: 0
               }
            }
        }
    ]
}
