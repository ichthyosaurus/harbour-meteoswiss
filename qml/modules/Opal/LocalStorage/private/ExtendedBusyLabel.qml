//@ This file is part of opal-localstorage.
//@ https://github.com/Pretty-SFOS/opal-localstorage
//@ SPDX-License-Identifier: GPL-3.0-or-later
//@ SPDX-FileCopyrightText: 2025 Mirian Margiani

import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: root

    property alias running: indicator.running
    property alias text: label.text
    property alias hintText: hintLabel.text

    readonly property bool _portrait: (__silica_applicationwindow_instance.orientation
                                      & Orientation.PortraitMask) !== 0

    y: Math.round(_portrait ? Screen.height/4 : Screen.width/4)
    spacing: Theme.paddingLarge
    width: parent.width

    BusyIndicator {
        id: indicator
        running: true
        size: BusyIndicatorSize.Large
        anchors.horizontalCenter: parent.horizontalCenter

        opacity: running ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator { duration: 400 } }
    }

    InfoLabel {
        id: label
    }

    InfoLabel {
        id: hintLabel
        color: Theme.secondaryHighlightColor
        opacity: Theme.opacityHigh
        font.pixelSize: Theme.fontSizeLarge
    }
}
