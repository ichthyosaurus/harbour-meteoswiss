import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    property var place
    property alias text: titleLabel.text
    property string unit: ''

    spacing: Theme.paddingMedium
    x: Theme.horizontalPageMargin
    y: place.y

    visible: forecast.loaded
    Behavior on opacity { NumberAnimation { duration: 500 } }
    opacity: forecast.loaded ? 1 : 0

    Label {
        id: titleLabel
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
    }

    Label {
        text: (unit == " " ? " " : String("(%1)").arg(unit))
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        anchors.baseline: titleLabel.baseline
    }
}
