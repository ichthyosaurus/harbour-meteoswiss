/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    property alias text: valueLabel.text
    property string unit
    property var base

    width: base.width - Theme.paddingLarge
    x: base.x - Theme.paddingLarge

    Label {
        id: valueLabel
        font.pixelSize: Theme.fontSizeMedium
        anchors.right: unitLabel.left
    }

    Label {
        id: unitLabel
        text: (valueLabel.text == '') ? ' ' : ' ' + unit
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors.baseline: valueLabel.baseline
        anchors.right: parent.right
    }
}
