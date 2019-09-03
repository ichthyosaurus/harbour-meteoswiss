/*
 * This file is part of harbour-meteoswiss.
 * Copyright (C) 2018-2019  Mirian Margiani
 *
 * harbour-meteoswiss is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-meteoswiss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

.import "cantons.js" as Cantons
.import "locations-overview.js" as Locations

// convert LV03 corrdinates to international WGS84 coordinates
// source: https://asciich.ch/wordpress/koordinatenumrechner-schweiz-international/
// slightly adapted to fit
function swiss2intl(swissNorth, swissEast) {
    var y = (swissEast  - 600000) / 1000000;
    var x = (swissNorth - 200000) / 1000000;

    var lambda =  2.6779094;
    lambda += 4.728982 * y;
    lambda += 0.791484 * y * x;
    lambda += 0.1306 * y * x * x;
    lambda -= 0.0436 * y * y * y;
    lambda *= 100 / 36;

    var phi =  16.9023892;
    phi += 3.238272 * x;
    phi -= 0.270978 * y * y;
    phi -= 0.002528 * x * x;
    phi -= 0.0447  * y * y * x;
    phi -= 0.0140 * x * x * x;
    phi *= 100/36;

    var intlNorth = phi + '';
    var intlEast  = lambda + '';

    return { north: intlNorth, east: intlEast };
}

function hash(token) {
    var a = token.substr(1, 3);
    var b = token.substr(5, token.length-5-5);

    if (b.length > 6) {
        b = b.substr(0, 2) + b.substr((b.length/2)-1, 3) + b.substr(b.length-2, 1);
        b = b.replace(/[sUBCWDFHIwJELMNOPQWGTfbome ]/g, "");
    } else if (b.length > 3) {
        b = b.substr(0, 2) + b.substr(b.length-1, 1);
        b = b.replace(/[RwUVWACEWGHITKfbome ]/g, "");
    }

    return a + b;
}

function getDetails(token) {
    var hashstr = hash(token);

    Qt.include("locations-details/locations-details-" + hashstr.substr(0, 2) + ".js")

    var coords = swiss2intl(Locations[hashstr].la, Locations[hashstr].lo);
    var cantonId = token.substr(token.length-3, 2);

    return {
        locationId: Locations[hashstr].i,
        altitude: Locations[hashstr].al,
        latitude: coords.north,
        longitude: coords.east,
        zip: parseInt(token.substr(0, 4), 10),
        cantonId: cantonId,
        canton: Cantons.Cantons[cantonId],
        name: token.substr(5, token.length-10),
    }
}

function search(string) {
    var ret = [];
    for (var i = 0; i < Locations.LocationsList.length; i++) {
        if (string != "" && Locations.LocationsList[i].indexOf(string) >= 0) {
            ret.push({"name": Locations.LocationsList[i]});
        }
        if (ret.length == 50) break;
    }
    return ret;
}
