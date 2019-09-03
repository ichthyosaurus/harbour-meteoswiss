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

    width: parent.width
    color: parent.textColor ? parent.textColor : Theme.primaryColor

    font.pixelSize: Theme.fontSizeTiny
    horizontalAlignment: Text.AlignHCenter
}
