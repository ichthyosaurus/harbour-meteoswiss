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

Row {
    property var place
    property alias text: titleLabel.text
    property string unit: ''

    spacing: Theme.paddingMedium
    x: Theme.horizontalPageMargin
    y: place.y

    visible: forecast.loaded
    Behavior on opacity { NumberAnimation { duration: 500 } }
    opacity: forecast.loaded ? 1 : 0

    Label {
        id: titleLabel
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
    }

    Label {
        text: (unit == " " ? " " : String("(%1)").arg(unit))
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        anchors.baseline: titleLabel.baseline
    }
}
