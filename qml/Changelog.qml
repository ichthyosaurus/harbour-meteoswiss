/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: Mirian Margiani
 */

import QtQuick 2.0
import "modules/Opal/About"

ChangelogList {
    ChangelogItem {
        version: "2.0.0-1"
        date: "2025-07-22"
        paragraphs: [
            "- Added a fancy new table view that shows all available data, accessible from the pulley menu (try scrolling sideways to see everything)<br>" +
            "- Added a new wind gusts graph, showing the range of expected gusts per hour<br>" +
            "- Added a new sunshine duration graph, showing minutes of sunshine per hour<br>" +
            "- Added expected chance of precipitation (percentage) in 3h intervals<br>" +
            "- Added wind direction display to wind speed graph<br>" +
            "- Improved logging of data conversion errors and database errors<br>" +
            "- Improved error handling for cases when locations are no longer supported, or data loading fails<br>" +
            "- Updated data refresh interval from 60min to 30min for forecasts, and to 15min for week overviews<br>" +
            "- Updated wind speed graph to show data in 1h intervals<br>" +
            "- Updated graph colors and spacing to be more legible<br>" +
            "- Fixed precipitation display in multiple places<br>" +
            "- Fixed precipitation calculation: expected amount, minimum, and maximum are visible again in charts<br>" +
            "- Fixed broken locations showing up on the cover screen<br>" +
            "- Fixed no longer supported locations breaking data loading: if a location is detected as broken, it will be disabled automatically now<br>" +
            "- Fixed charts breaking when some data points are missing<br>" +
            "- Fixed blurry weather icons on low resolution screens like the C2<br>" +
            "- Fixed precipitation charts seemingly starting at negative values (#10)<br>" +
            "- Large changes under the hood:<br>" +
            "- > switched to Opal.LocalStorage for database handling<br>" +
            "- > improved the charting library<br>" +
            "- > removed a lot of dead code<br>" +
            "- > updated Opal modules bringing in translation updates and bug fixes<br>" +
            "- > backported fixes from Dashboard, Expenditure, and Captain's Log<br>" +
            "- > and much more<br>" +
            "- Note: switching to an older version after this update is not possible due to changes to the database schema"
        ]
    }
    ChangelogItem {
        version: "1.4.0-1"
        date: "2024-10-13"
        paragraphs: [
            "- This is mainly a maintenance release to bring the app back into shape for future development<br>" +
            "- Fixed overflowing text in day summaries<br>" +
            "- Added a support dialog for donations, a proper about page, and an internal changelog<br>" +
            "- Added translations through Weblate, you are invited to contribute!<br>" +
            "- Added and updated many translations from Opal<br>" +
            "- Updated packaging and infrastructure"
        ]
    }
    ChangelogItem {
        version: "1.3.1-2"
        date: "2022-03-24"
        paragraphs: [
            "- Added a Sailjail profile so the app hopefully keeps working in SFOS >= 4.4<br>" +
            "- Only permission is \"Internet\" for fetching forecasts"
        ]
    }
    ChangelogItem {
        version: "1.3.1-1"
        date: "2022-03-24"
        paragraphs: [
            "- Accidental release, skip to version 1.3.1-2"
        ]
    }
    ChangelogItem {
        version: "1.3.0-2"
        date: "2020-12-21"
        paragraphs: [
            "- Changed an internal comment to make Sailfish SDK's RPM validation script happy"
        ]
    }
    ChangelogItem {
        version: "1.3.0-1"
        date: "2020-06-16"
        paragraphs: [
            "- Important: the app is working again<br>" +
            "- See the last changelog for some changes that became visible with this release<br>" +
            "- Switch to the official app's API<br>" +
            "- Fix bug where day summaries were not correctly refreshed<br>" +
            "- Update app description in a few places<br>" +
            "- Update translations"
        ]
    }
    ChangelogItem {
        version: "1.2.9-1"
        date: "2020-06-10"
        paragraphs: [
            "- Important: the app is currently unusable due to external API changes<br>" +
            "- Disable the whole app for now (prevents unnecessary network usage)<br>" +
            "- Changes (currently not visible):<br>" +
            "- > Animate details table<br>" +
            "- > Make the app usable in landscape mode<br>" +
            "- > Remove broken summary background<br>" +
            "- > Show the corresponding small graph when tapping on a day instead of switching<br>" +
            "    to the forecast page (tap on the graph or the title to switch)<br>" +
            "- > Update About page<br>" +
            "- > Internal clean-ups<br>" +
            "- > Fix some small warnings"
        ]
    }
    ChangelogItem {
        version: "1.2.8-1"
        date: "2020-04-19"
        paragraphs: [
            "- Fix About page to show correct license<br>" +
            "- Fix typo in French translation<br>" +
            "- Add Contributors page"
        ]
    }
    ChangelogItem {
        version: "1.2.7-1"
        date: "2019-12-16"
        paragraphs: [
            "- Implement extensive database maintenance which will be done every 60 days<br>" +
            "- Round precipitation value in (generated) day summaries<br>" +
            "- Update Chinese translation<br>" +
            "- Always prune old weather data from database"
        ]
    }
    ChangelogItem {
        version: "1.2.6-2"
        date: "2019-12-11"
        paragraphs: [
            "- Generate day summaries if none could be downloaded<br>" +
            "- Fix typo in French translation<br>" +
            "- Add Chinese translation (thanks dashinfantry!)"
        ]
    }
    ChangelogItem {
        version: "1.2.5-1"
        date: "2019-09-05"
        paragraphs: [
            "- Make app translatable to French and Italian<br>" +
            "- Translate weather descriptions to French and Italian"
        ]
    }
    ChangelogItem {
        version: "1.2.4-1"
        date: "2019-03-24"
        paragraphs: [
            "- Improve startup time"
        ]
    }
    ChangelogItem {
        version: "1.2.3-1"
        date: "2019-03-21"
        paragraphs: [
            "- Fix missing loading indicators on overview page"
        ]
    }
    ChangelogItem {
        version: "1.2.2-1"
        date: "2019-03-18"
        paragraphs: [
            "- Fix some visual glitches<br>" +
            "- Improve data validation to make sure downloaded data is reliable"
        ]
    }
    ChangelogItem {
        version: "1.2.1-1"
        date: "2019-02-11"
        paragraphs: [
            "- Heavily decrease network load<br>" +
            "- Fix some visual glitches<br>" +
            "- Heavily improve loading performance<br>" +
            "- Heavily improve location adding performance<br>" +
            "- Fix refreshing week summary on overview page"
        ]
    }
    ChangelogItem {
        version: "1.2.0-1"
        date: "2019-02-09"
        paragraphs: [
            "- Backwards incompatible: store more locations details and week summaries in database<br>" +
            "- Include more details in shipped list of locations<br>" +
            "- Attempt to reduce network load by caching source paths<br>" +
            "- Make clock on overview page non-clickable<br>" +
            "- Highlight items on overview page to make them more distinct<br>" +
            "- Prevent day summaries from flickering when selected<br>" +
            "- Improve some error messages<br>" +
            "- Mark current day in overview page's week overview<br>" +
            "- Use API fromt he official app to load better week summaries<br>" +
            "- Improve handling of missing data<br>" +
            "- Show sunrise and other sun times for each day<br>" +
            "- Fix saving locations order (regression from version 1.1.0)<br>" +
            "- Indicate current hour only in today's charts<br>" +
            "- Greatly improve performance:<br>" +
            "- > general loading<br>" +
            "- > data loading from network<br>" +
            "- > search page, searching<br>" +
            "- > details page<br>" +
            "- Add tiny overview charts to overview page<br>" +
            "- Plus some minor visual improvements"
        ]
    }
    ChangelogItem {
        version: "1.1.1-1"
        date: "2019-01-29"
        paragraphs: [
            "- Visually overhaul forecast page<br>" +
            "- Show week overview for first 3 locations on overview page<br>" +
            "- Visually polish table<br>" +
            "- Fine-tune colors throughout<br>" +
            "- Fix wrong wind speed unit<br>" +
            "- Show weather description when clicking on a summary item on forecast page<br>" +
            "- Improve code quality"
        ]
    }
    ChangelogItem {
        version: "1.1.0-2"
        date: "2019-01-28"
        paragraphs: [
            "- Fix version number in About page"
        ]
    }
    ChangelogItem {
        version: "1.1.0-1"
        date: "2019-01-28"
        paragraphs: [
            "- Backwards incompatible: store less data in database<br>" +
            "- Show variance data in graphs (temperature and rain)<br>" +
            "- Improve data loading performance"
        ]
    }
    ChangelogItem {
        version: "1.0.3-1"
        date: "2019-01-27"
        paragraphs: [
            "- Improve translations<br>" +
            "- Hide scales and overview on forecast page while loading<br>" +
            "- Make status line dynamic<br>" +
            "- Show zip code on overview page<br>" +
            "- Add clock on overview page<br>" +
            "- Small performance improvement while loading<br>" +
            "- Add wind graph (with details in the table)<br>" +
            "- Detect clicks everywhere on table list entries<br>" +
            "- Add descriptions to graphs<br>" +
            "- Fix slight difference in size of main scale and overlay scale"
        ]
    }
    ChangelogItem {
        version: "1.0.2-1"
        date: "2019-01-26"
        paragraphs: [
            "- Use straight lines in temperature chart<br>" +
            "- Add forecast summaries with symbols to the main forecast page<br>" +
            "- Fix issues with graph width<br>" +
            "- Visually align temperature and precipitation graphs"
        ]
    }
    ChangelogItem {
        version: "1.0.1-1"
        date: "2019-01-05"
        paragraphs: [
            "- Refactor visuals of forecast page<br>" +
            "- Show weather string instead of zip and canton in overview<br>" +
            "- Fix temperature sometimes not being shown in overview<br>" +
            "- Don't restart refresh timer when data is manually refreshed<br>" +
            "- Add some busy indicators and animations<br>" +
            "- Performance changes"
        ]
    }
    ChangelogItem {
        version: "1.0.0-1"
        date: "2019-01-04"
        paragraphs: [
            "- Initial release"
        ]
    }
}
