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

BackgroundItem {
    property var descriptionLabel
    property string description
    property alias label: descLabel.text
    property alias value: valLabel.text

    onClicked: {
        if (descriptionLabel && descriptionLabel.text) {
            descriptionLabel.text = String(qsTr("%1: %2", "sun time title (1) with description (2)")).arg(label.split('\x9c')[0]).arg(description)
        }
    }

    Label {
        id: descLabel

        anchors {
            left: parent.left
            right: parent.horizontalCenter
            margins: Theme.paddingSmall
            baseline: valLabel.baseline
        }

        horizontalAlignment: Text.AlignRight
        color: Theme.secondaryHighlightColor
        maximumLineCount: 2
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeSmall

        text: ""
    }

    Label {
        id: valLabel

        anchors {
            left: parent.horizontalCenter
            right: parent.right
            margins: Theme.paddingSmall
        }

        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WordWrap
        color: Theme.highlightColor
        maximumLineCount: 2


        text: ""
    }
}
