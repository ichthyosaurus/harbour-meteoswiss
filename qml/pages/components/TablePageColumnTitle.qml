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

Column {
    property alias text: titleLabel.text
    property string unit: ''

    Label {
        id: titleLabel
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
        truncationMode: TruncationMode.Fade
    }

    Label {
        text: (unit == '') ? ' ' : String("(%1)").arg(unit)
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
    }
}
