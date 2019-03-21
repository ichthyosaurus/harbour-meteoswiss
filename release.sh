#!/bin/bash
#
# release.sh 0.0.1 (2019-03-21)
# Copyright (C) 2019  Mirian Margiani
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
sed -i "s/^# - Summary of changes$/# - Summary of changes\n\n* $(LC_ALL=en_GB.utf8 date "+%a %d %b %y") $(git config user.name) <$(git config user.email)> $new_version-1\n- /g" rpm/harbour-meteoswiss.changes

echo "updating main qml..."
sed -i "s/property string version: \"$current\"/property string version: \"$new_version\"/g" qml/harbour-meteoswiss.qml

echo "opening changelog for editing..."
$EDITOR "rpm/harbour-meteoswiss.changes"

echo "NOTE: don't forget to commit all changes and tag the release!"
echo "git commit -m \"release version $new_version\" ."
echo "git tag v$new_version-1"
