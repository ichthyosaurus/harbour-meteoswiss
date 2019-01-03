#!/bin/bash

fetch() { # 1: code
    if [[ -z "$1" ]]; then
        echo "error: missing language code!"
        exit 1
    fi

    mkdir -p qml/js
    # curl "https://www.meteoschweiz.admin.ch/etc/designs/meteoswiss/clientlibs/lang/$1.min.6c80a637e791fe0918ccaca7e4ca95d8.js" > "qml/js/strings-$1.js"
}

fetch de
fetch en
fetch it
fetch fr
