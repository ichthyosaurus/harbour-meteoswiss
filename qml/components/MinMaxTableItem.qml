/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

Column {
    property double expected
    property double min
    property double max
    property string unit
    property int precision: 1
    property color primaryColor: Theme.highlightColor
    property color secondaryColor: Theme.secondaryHighlightColor

    property bool hideZero: false
    readonly property bool _hide: hideZero &&
        expected.toFixed(precision) == 0.0 &&
        min.toFixed(precision) == 0.0 &&
        max.toFixed(precision) == 0.0

    anchors.verticalCenter: parent.verticalCenter
    height: Math.max(childrenRect.height, 1)

    Label {
        visible: _hide
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "⸺"
        color: Theme.highlightColor
    }

    Label {
        visible: !_hide
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: expected.toFixed(precision) +
              " <small>" + unit + "</small>"
        color: primaryColor
        textFormat: Text.RichText
    }

    Label {
        visible: !_hide && (min != expected || max != expected)
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: min.toFixed(precision) + " - " + max.toFixed(precision)
        color: secondaryColor
        font.pixelSize: Theme.fontSizeSmall
    }
}
