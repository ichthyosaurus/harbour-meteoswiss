/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    property string unit: ""
    property string value: ""
    property string valueMax: ""

    function getText() {
        if (value == "") {
            value = valueMax;
        }

        var ret = "";
        if (valueMax == "" || value == valueMax) {
            ret = value;
        } else {
            ret = String("%1 | %2").arg(value).arg(valueMax);
        }

        if (unit != "" && value != "") {
            ret = String("%1 %2").arg(ret).arg(unit);
        }

        return ret;
    }

    function refresh() {
        text = getText();
    }

    text: getText()

    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 2 * Theme.paddingSmall
    color: parent.textColor ? parent.textColor : Theme.primaryColor

    truncationMode: TruncationMode.Fade
    minimumPixelSize: 0.8 * Theme.fontSizeTiny
    fontSizeMode: Text.Fit
    font.pixelSize: Theme.fontSizeTiny
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
