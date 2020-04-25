/*
 * This file is part of sf-about-page.
 * Copyright (C) 2020  Mirian Margiani
 *
 * sf-about-page is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sf-about-page is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with sf-about-page.  If not, see <http://www.gnu.org/licenses/>.
 *
 * *** CHANGELOG: ***
 *
 * 2020-04-25:
 * - remove version numbers, use changelog instead
 * - backwards-incompatible changes are marked with "[breaking]"
 *
 * 2020-04-17:
 * - initial release
 *
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

Repeater {
    id: base
    property string label
    property var values

    model: values.length
    delegate: DetailItem {
        label: index === 0 ? base.label : ""
        value: base.values[index]
    }
}
