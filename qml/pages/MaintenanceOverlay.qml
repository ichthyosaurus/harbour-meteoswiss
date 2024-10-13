/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
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
