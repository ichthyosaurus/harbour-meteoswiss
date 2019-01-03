#!/bin/bash

BASE="qml/js/locations"

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

    # echo "\
    # \"$zip $name ($cantonId)\": {
    #     \"name\": \"$name\",
    #     \"zip\": $zip,
    #     \"searchId\": $searchId,
    #     \"cantonId\": \"$cantonId\",
    # }," >> "$details"

    echo "    \"$zip $name ($cantonId)\": $searchId," >> "$details"
    echo "    \"$zip $name ($cantonId)\"," >> "$overview"
done

echo "}" >> "$details"
echo "]" >> "$overview"

# cat "$details" > "$locations"
# echo >> "$locations"
# cat "$overview" >> "$locations"

echo "
function get(token) {
    return {
        zip: parseInt(token.substr(0, 4), 10),
        searchId: Locations[token],
        cantonId: token.substr(token.length-3, 2),
        canton: token.substr(token.length-3, 2),
        name: token.substr(5, token.length-5),
    }
}"
