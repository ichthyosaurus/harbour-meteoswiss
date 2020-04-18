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
