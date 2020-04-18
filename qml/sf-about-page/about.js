.pragma library

// This script is a library. This improves performance, but it means that no
// variables from the outside can be accessed.

var VERSION_NUMBER // set in main.qml's Component.onCompleted

var DEVELOPMENT = [
    {label: qsTr("Programming"), values: ["Mirian Margiani"]},
    {label: qsTr("Weather Icons"), values: ["Zeix"]}
]

var TRANSLATIONS = [
    {label: qsTr("Weather Descriptions"), values: ["MeteoSwiss"]},
    {label: qsTr("English, German"), values: ["Mirian Margiani"]},
    {label: qsTr("Chinese"), values: ["dashinfantry"]}
]

var APPINFO = {
    appName: qsTr("MeteoSwiss"),
    iconPath: "../weather-icons/harbour-meteoswiss.svg",
    versionNumber: VERSION_NUMBER,
    description: qsTr("This is an unofficial client app for the national weather service's web interface."),
    author: "Mirian Margiani",
    dataInformation: qsTr("Copyright, Federal Office of Meteorology and Climatology MeteoSwiss.") + "\n" +
                     qsTr('Weather icons by Zeix.'),
    dataLink: qsTr('https://www.meteoschweiz.admin.ch/'),
    dataLinkText: "", // use default button text
    sourcesLink: "https://github.com/ichthyosaurus/harbour-meteoswiss",
    sourcesText: qsTr("Sources on GitHub"),

    enableContributorsPage: true, // whether to enable 'ContributorsPage.qml'
    contribDevelopment: DEVELOPMENT,
    contribTranslations: TRANSLATIONS
}

function aboutPageUrl() {
    return Qt.resolvedUrl("AboutPage.qml");
}

function pushAboutPage(pageStack) {
    pageStack.push(aboutPageUrl(), APPINFO);
}
