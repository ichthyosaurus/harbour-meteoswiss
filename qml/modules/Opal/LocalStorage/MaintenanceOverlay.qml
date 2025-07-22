//@ This file is part of opal-localstorage.
//@ https://github.com/Pretty-SFOS/opal-localstorage
//@ SPDX-License-Identifier: GPL-3.0-or-later
//@ SPDX-FileCopyrightText: 2018-2025 Mirian Margiani

import QtQuick 2.0
import Sailfish.Silica 1.0
import "private"
import "."

Rectangle {
    id: root
    objectName: "MaintenanceOverlay"

    property alias text: label.text
    property alias hintText: label.hintText
    property alias busy: label.running

    property bool autoShowOnMaintenance: true

    readonly property bool _portrait: (__silica_applicationwindow_instance.orientation
                                      & Orientation.PortraitMask) !== 0

    signal maintenanceStarted
    signal maintenanceFinished

    function show() { state = "shown" }
    function hide() { state = "hidden" }

    function registerSignals(force) {
        if (!force && !!StorageHelper.maintenanceStartSignal) {
            console.warn("[Opal.LocalStorage] %1: maintenance start signal already set!".arg(objectName))
        } else {
            StorageHelper.maintenanceStartSignal = function(){ maintenanceStarted() }
        }

        if (!force && !!StorageHelper.maintenanceEndSignal) {
            console.warn("[Opal.LocalStorage] %1: maintenance end signal already set!".arg(objectName))
        } else {
            StorageHelper.maintenanceEndSignal = function(){ maintenanceFinished() }
        }
    }

    visible: false
    parent: __silica_applicationwindow_instance.contentItem
    rotation: __silica_applicationwindow_instance._rotatingItem.rotation
    color: Theme.highlightDimmerColor
    anchors.centerIn: parent
    width: _portrait ? parent.width : parent.height
    height: _portrait ? parent.height : parent.width

    onAutoShowOnMaintenanceChanged: {
        if (autoShowOnMaintenance) {
            registerSignals()
        }
    }

    Connections {
        target: autoShowOnMaintenance ? root : null
        onMaintenanceStarted: show()
        onMaintenanceFinished: hide()
    }

    ExtendedBusyLabel {
        id: label
        running: root.visible
        text: qsTr("Database Maintenance")
        hintText: qsTr("Please be patient and allow up to 30 seconds for this.")
    }

    states: [
        State {
            name: "shown"
            PropertyChanges {
                target: root
                opacity: 1.0
            }
            PropertyChanges{
                target: root
                visible: true
            }
        },
        State {
            name:"hidden"
            PropertyChanges {
                target: root
                opacity: 0.0
            }
            PropertyChanges {
                target: root
                visible: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            to: "hidden"

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

    Component.onCompleted: {
        if (autoShowOnMaintenance) {
            registerSignals()
        }
    }
}
