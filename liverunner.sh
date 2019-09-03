#!/bin/bash
#
# This file is part of harbour-meteoswiss.
# Copyright (C) 2018-2019  Mirian Margiani
#
# harbour-meteoswiss is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# harbour-meteoswiss is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
#

while sleep_until_modified qml/qchart/*.* qml/*.qml qml/**/*.qml qml/**/**/*.qml qml/js/*.*; do
    killall qml
    qml qml/harbour-meteoswiss.qml &
done
