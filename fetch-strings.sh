#!/bin/bash
#
# This file is part of harbour-meteoswiss.
#
# fetch-strings 0.0.1 (2019-09-05)
# Copyright (C) 2019  Mirian Margiani
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

DEPENDENCIES=(curl awk lupdate-qt5)

dependencies() { # 1: echo/no-echo
    ret=0
    print=
    if [[ "$1" == "echo" ]]; then
        print=true
        echo -e "\nDependencies:"
    fi

    for i in "${DEPENDENCIES[@]}"; do
        if which "$i" 2> /dev/null >&2; then
            if [[ -n "$print" ]]; then
                echo "    - $i: $(which "$i")"
            fi
        else
            if [[ -n "$print" ]]; then
                echo "    - $i: missing"
                ret=1
            else
                return 1
            fi
        fi
    done

    return "$ret"
}

version() {
    echo "\
fetch-strings 0.0.1 (2019-09-05)
Copyright (C) 2019  Mirian Margiani
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."
    dependencies echo
}

if ! dependencies no-echo; then
    version
    echo -e "\nerror: missing dependencies" >/dev/stderr
    exit 255
fi

show_help() {
script="$(basename "$0")"
    echo "\
** fetch-strings **

Fetch weather description strings for harbour-meteoswiss.

Note: this is backported from the current development branch.

Usage:
    $script
    $script [-h] [-V]

Arguments:
    -V, --version - show version and license information
    -h, --help    - show this help and exit
"
}

while [[ $# > 0 ]]; do
    case "$1" in
        --help|-h) show_help; exit 0;;
        --version|-V) version; exit 0;;
        -*) echo "unknown option: $1";;
        *) shift; continue;;
    esac
    shift
done

translations="qml/js/strings.js"
mkdir -p "qml/js"

if [[ -f "$translations" ]]; then
    mv --backup=t "$translations" "$translations.bak"
fi

phrase_book_base="translations/phrase_books"
mkdir -p "$phrase_book_base"

shopt -s nullglob
for i in "$phrase_book_base/"*.qph; do
    mv --backup=t "$i" "$i.bak"
done
shopt -u nullglob

cat <<EOF > "$translations"
// NOTE This file is auto-generated! Do not edit, as all changes will be overwritten!
.pragma library

var weatherSymbolDescription = {
EOF

add_translation() { # 1: group 2: string, 3: comment, 4..: default translations, e.g. 'de_CH:Schweiz' with string=Switzerland
    local group="${1//\"/}"
    local comment="$3"

    local string="${2//\"/}"
    local id="${string%%|*}"
    local string="${string#*|}"

    shift 3 # remove all args up to the default translations

    if [[ -n "$comment" ]]; then
        echo "/*: $comment */" >> "$translations"
    fi

    echo "    \"$id\": qsTr(\"$string\")," >> "$translations"

    if [[ $# > 0 ]]; then
        for i in "$@"; do
            local locale="${i%%:*}"
            local qph="$phrase_book_base/$locale.qph"

            if [[ "$locale" == "" ||"$locale" == "$i" ]]; then
                echo "warning: invalid default translation for $group: $string ('$i')"
                continue
            fi

            local translation="${i#*:}"

            if [[ ! -f "$qph" ]]; then
                echo "<!DOCTYPE QPH><QPH language=\"$locale\">" > "$qph"
            fi

            echo "<phrase><source>$string</source><target>$translation</target><definition>Locations: $group</definition></phrase>" >> "$qph"
        done
    fi
}

add_value_string() { # 1: target, 2..: values
    case "$1" in
        weather_descriptions) echo -n;; # ok
        *)  echo "[add_value_string] error: invalid target name given: '$1'"
            exit 1
        ;;
    esac

    local target="$1"
    local values="("
    shift

    for i in "$@"; do
        values+="'${i//\'/\'\'}', "
    done

    values="${values%, }"
    values+="),"

    eval "${target}+=\"$values\""
}

weather_descriptions=
add_description() { # 1: id, 2: string, 3..: default translations (see add_translation for details)
    add_value_string weather_descriptions "$1" "$2"

    local id="$1"
    local s="$2"
    local args=2; (( $# > $args )) && shift $args || shift $# # remove all args up to the default translations

    add_translation "Weather Descriptions" "$id|$s" "" "$@"
}

assemble_meteoswiss() {
    # Descriptions
    echo "assembling descriptions..."
    local dir="raw/strings"
    local string_base="$dir/strings"

    mch_fetch_strings_list() { # 1: code
        local file="$string_base-$1.js"
        [[ ! -f "$file" ]] &&\
            curl "https://www.meteoschweiz.admin.ch/etc/designs/meteoswiss/clientlibs/lang/$1.min.6c80a637e791fe0918ccaca7e4ca95d8.js" > "$file"
    }

    for i in en de fr it; do
        mch_fetch_strings_list "$i"

        if [[ ! -f "$string_base-$i.js" ]]; then
            echo "error: failed to download strings for $i"
            continue
        fi

        local l1=""
        local l2=""

        case "$i" in
            en) l1="en_GB"; l2="en_US";;
            de) l1="de_CH"; l2="de_DE";;
            fr) l1="fr_CH"; l2="fr_FR";;
            it) l1="it_CH"; l2="it_IT";;
        esac

        grep -Poe 'weatherSymbolDescription:{.*?}' "$string_base-$i.js" |\
            grep -Poe '{.*?}' |\
            python -m json.tool |\
            perl -CD -pe 's/\\u([\dA-Fa-f]{4})/chr(hex($1))/eg' |\
            iconv -f "windows-1258" -t "UTF-8" - |\
            grep ":" |\
            sed -Ee "s/[ ]*\"([0-9]+)\": \"(.*?)\",/\1|$l1:\2|$l2:\2/g" |\
            sort > "$string_base-$i.clean"
    done

    join     -j 1 -t '|' "$string_base-en.clean" "$string_base-de.clean" |\
        join -j 1 -t '|' - "$string_base-fr.clean" |\
        join -j 1 -t '|' - "$string_base-it.clean" > "$string_base"

    # 1: id, 2: string, 3..: default translations
    local strings_eval="$(cat "$string_base" | awk -F'|' '{
        transl=$2;
        gsub(/en_GB:/, "", transl);

        cmd="add_description " $1 " \"" transl "\"";

        for (i=2; i<=NF; i++) {
            cmd=cmd " \"" ($i) "\"";
        }

        print cmd;
    }')"

    eval "$strings_eval"
}

# load data
assemble_meteoswiss

# finish default translation files
echo "finishing phrase books..."

shopt -s nullglob
for i in "$phrase_book_base/"*.qph; do
    echo "</QPH>" >> "$i"
done
shopt -u nullglob

echo "finishing translation base..."
echo "}" >> "$translations"

lupdate-qt5 harbour-meteoswiss.pro
