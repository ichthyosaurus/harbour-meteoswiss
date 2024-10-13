# This file is part of harbour-meteoswiss.
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2018-2024 Mirian Margiani

# sort locations-details.js > lod-s.js
#
# for i in {0..99}; do
#     n="$(printf "%02d" "$i")"
#     grep "^\"$n" lod-s.js > locations-details-"$n".js
#     wc -l locations-details-"$n".js
# done
#
# for i in {0..99}; do
#     n="$(printf "%02d" "$i")"
#     cat <(echo "var Locations={") "locations-details-$n.js" <(echo "}") > "locations-details-$n.js_2"
# done
#
# for i in {0..99}; do
#     n="$(printf "%02d" "$i")"
#     perl -pe 's/\n//g' "locations-details-$n.js_2" > "locations-details-$n.js"
#     rm "locations-details-$n.js_2"
# done

sort locations-details.js > lod-s.js
mkdir -p locations-details
for i in {0..99}; do
    n="$(printf "%02d" "$i")"
    cat <(echo "var Locations={") <(grep "^\"$n" lod-s.js) <(echo "}") | perl -pe 's/\n//g' > "locations-details/locations-details-$n.js"
done
rm lod-s.js
