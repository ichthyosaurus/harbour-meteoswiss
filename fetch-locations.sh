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

echo "WARNING: OUTDATED!"
echo "This script is no longer usable to build the locations.js used by the app."
echo "The resulting JS has to be postprocessed using data from this database:"
echo "https://s3-eu-central-1.amazonaws.com/app-prod-static-fra.meteoswiss-app.ch/v1/db.sqlite"

BASE="raw/locations"

fetch() { # 1: two digit code
    if [[ -z "$1" ]]; then
        echo "error: missing base location code!"
        exit 1
    fi

    echo "=== $1 ==="
    mkdir -p "$BASE"

    [[ ! -f "$BASE/locations-$1.json" ]] &&\
        curl -s "https://www.meteoschweiz.admin.ch/etc/designs/meteoswiss/ajax/search/$1.json" |\
        python -m json.tool 2>/dev/null > "$BASE/locations-$1.json"
}

for i in {10..99}; do
    fetch "$i"
done

cd "$BASE"
rm -f full-list

for i in locations-*.json; do
    tail "$i" --lines +2 | head - --lines -1 >> full-list
done

mapfile -t lines <full-list

get() {
    echo "$1" | cut -d';' -f"$2"
}

details="locations-details.js"
overview="locations-overview.js"
locations="locations.js"

echo "var Locations = {" > "$details"
echo "var LocationsList = [" > "$overview"

for i in "${lines[@]}"; do
    base="$(echo "$i" | sed 's/^[ ]*"//g;s/"//g;s/,$//g')"
    echo "$base"
    name="$(get "$base" 6)"
    zip="$(get "$base" 4)"
    searchId="$(get "$base" 1)"
    cantonId="$(get "$base" 2)"

    name="${name% $cantonId}"

    echo "    \"$zip $name ($cantonId)\": $searchId," >> "$details"
    echo "    \"$zip $name ($cantonId)\"," >> "$overview"
done

echo "}" >> "$details"
echo "]" >> "$overview"

echo "
function get(token) {
    return {
        zip: parseInt(token.substr(0, 4), 10),
        searchId: Locations[token],
        cantonId: token.substr(token.length-3, 2),
        canton: token.substr(token.length-3, 2),
        name: token.substr(5, token.length-10),
    }
}"
