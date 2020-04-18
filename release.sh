#!/bin/bash
#
# release.sh 1.0.0 (2020-04-18)
#
# This file is part of harbour-meteoswiss.
# Copyright (C) 2018-2020  Mirian Margiani
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

show_help() {
script="$(basename "$0")"
    echo "\
** release.sh **

Prepare release of a new version of harbour-meteoswiss.

Usage:
    $script [NEW]
    $script [-h]

Arguments:
    NEW           - new version number
    -h, --help    - show this help and exit
"
}

new_version=
while [[ $# > 0 ]]; do
    case "$1" in
        --help|-h) show_help; exit 0;;
        -*) echo "unknown option: $1";;
        *) new_version="$1";;
    esac
    shift
done

current="$(grep "^Version: " rpm/harbour-meteoswiss.yaml | cut -d':' -f2 | cut -d' ' -f2)"

if [[ -z "$new_version" ]]; then
    echo "current version: $current"
    exit 0
fi

echo "new version: $new_version"

if [[ -n "$(git status -s -u no)" ]]; then
    echo "error: there are uncommitted changes!"
    exit 1
fi

echo "updating translations..."
lupdate-qt5 -noobsolete qml -ts translations/*.ts

echo "updating rpm config..."
sed -i "s/^Version: $current$/Version: $new_version/g" rpm/harbour-meteoswiss.yaml
sed -i "s/^# - Summary of changes$/# - Summary of changes\n\n* $(LC_ALL=en_GB.utf8 date "+%a %b %d %Y") $(git config user.name) <$(git config user.email)> $new_version-1\n- /g" rpm/harbour-meteoswiss.changes

echo "updating main qml..."
sed -i "s/property string version: \"$current\"/property string version: \"$new_version\"/g" qml/harbour-meteoswiss.qml

echo "opening changelog for editing..."
$EDITOR "rpm/harbour-meteoswiss.changes"

echo "NOTE: don't forget to commit all changes and tag the release!"
echo "git commit -m \"release version $new_version\" ."
echo "git tag v$new_version-1"
