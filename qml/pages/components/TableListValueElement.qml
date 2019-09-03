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
