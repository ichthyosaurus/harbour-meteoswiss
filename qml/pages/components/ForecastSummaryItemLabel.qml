import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    property string unit: ""
    property string value: ""

    text: ((unit == "" || value == "") ? value : String("%1 %2").arg(value).arg(unit))

    width: parent.width
    color: parent.textColor

    font.pixelSize: Theme.fontSizeTiny
    horizontalAlignment: Text.AlignHCenter
}
