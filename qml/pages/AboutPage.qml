/*
 * This file is part of harbour-meteoswiss.
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * Translators:
 * Please add yourself to the list of translators in TRANSLATORS.json.
 * If your language is already in the list, add your name to the 'entries'
 * field. If you added a new translation, create a new section in the 'extra' list.
 *
 * Other contributors:
 * Please add yourself to the relevant list of contributors below.
 *
*/

import QtQuick 2.0
import Sailfish.Silica 1.0 as S
import Opal.About 1.0 as A

A.AboutPageBase {
    id: page

    appName: Qt.application.name
    appIcon: Qt.resolvedUrl("../images/%1.png".arg(Qt.application.name))
    appVersion: APP_VERSION
    appRelease: APP_RELEASE

    allowDownloadingLicenses: true  // this app requires an internet connection anyway
    sourcesUrl: "https://github.com/ichthyosaurus/%1".arg(Qt.application.name)
    homepageUrl: "https://forum.sailfishos.org/t/apps-by-ichthyosaurus/15753"
    translationsUrl: "https://hosted.weblate.org/projects/%1".arg(Qt.application.name)
    changelogList: Qt.resolvedUrl("../Changelog.qml")
    licenses: A.License { spdxId: "GPL-3.0-or-later" }

    donations.text: donations.defaultTextCoffee
    donations.services: [
        A.DonationService {
            name: "Liberapay"
            url: "https://liberapay.com/ichthyosaurus"
        }
    ]

    description: qsTr("This is an unofficial client to the weather forecast services provided by the Federal Office of Meteorology and Climatology (MeteoSwiss).")
    mainAttributions: ["2018-%1 Mirian Margiani".arg((new Date()).getFullYear())]
    autoAddOpalAttributions: true

    extraSections: A.InfoSection {
        title: qsTr("Data")
        text: qsTr("Copyright, Federal Office of Meteorology and Climatology MeteoSwiss.") + "\n" +
              qsTr('Weather icons by Zeix.')
        enabled: true
        onClicked: openOrCopyUrl('https://www.meteoswiss.admin.ch/')
    }

    attributions: [
        A.Attribution {
            name: "QChart"
            entries: ["2014 Julien Wintz", "adapted by Mirian Margiani"]
            // the original source code repository is no longer available
            homepage: "https://web.archive.org/web/20180611014447/https://github.com/jwintz/qchart.js"
        },
        A.Attribution {
            name: qsTr("Coordinates calculator", "MeteoSwiss uses the Swiss local coordinate system that must be converted to global coordinates")
            entries: ["2013 Reto Hasler (ascii_ch)", "adapted by Mirian Margiani"]
            homepage: "https://asciich.ch/wordpress/koordinatenumrechner-schweiz-international/"
        },
        A.Attribution {
            name: "suncalc.js"
            entries: ["2011-2015 Vladimir Agafonkin", "2018-2024 Mirian Margiani"]
            licenses: A.License { spdxId: "BSD-2-Clause" }
            sources: "https://github.com/mourner/suncalc"
        }
    ]

    contributionSections: [
        A.ContributionSection {
            title: qsTr("Development")
            groups: [
                A.ContributionGroup {
                    title: qsTr("Programming")
                    entries: ["Mirian Margiani"]
                },
                A.ContributionGroup {
                    title: qsTr("Weather icons")
                    entries: ["Zeix"]
                },
                A.ContributionGroup {
                    title: qsTr("Weather descriptions")
                    entries: ["MeteoSwiss"]
                }
            ]
        },
        //>>> GENERATED LIST OF TRANSLATION CREDITS
        A.ContributionSection {
            title: qsTr("Translations")
            groups: [
                A.ContributionGroup {
                    title: qsTr("Ukrainian")
                    entries: [
                        "Максим Горпиніч"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Turkish")
                    entries: [
                        "Burak Hüseyin Ekseli"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Tamil")
                    entries: [
                        "தமிழ்நேரம்"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Spanish")
                    entries: [
                        "Kamborio",
                        "gallegonovato"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Italian")
                    entries: [
                        "J. Lavoie"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("German")
                    entries: [
                        "J. Lavoie",
                        "Mirian Margiani"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("French")
                    entries: [
                        "J. Lavoie",
                        "Robin Grenet"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Estonian")
                    entries: [
                        "Priit Jõerüüt"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("English")
                    entries: [
                        "Mirian Margiani"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Chinese")
                    entries: [
                        "dashinfantry"
                    ]
                }
            ]
        }
        //<<< GENERATED LIST OF TRANSLATION CREDITS
    ]
}
