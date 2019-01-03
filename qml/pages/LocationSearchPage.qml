import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    property int locationId
    property string name
    property string canton
    property string cantonId

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        width: parent.width

        Column {
            id: column

            DialogHeader {
                title: qsTr("Add Location")
            }

            width: parent.width
            spacing: Theme.paddingLarge

            TextField {
                id: locationField
                focus: true
                width: parent.width
                placeholderText: "Zip Code"
                label: "Zip Code"
                validator: RegExpValidator { regExp: /^[1-9][0-9]{3}$/ }
                color: errorHighlight ? Theme.highlightColor : Theme.primaryColor
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhDigitsOnly
            }

            TextField {
                id: nameField
                width: parent.width
                placeholderText: "Name of the location"
                label: "Name"
            }

            TextField {
                id: cantonField
                width: parent.width
                placeholderText: "Name of the canton"
                label: "Canton"
            }

            TextField {
                id: cantonIdField
                width: parent.width
                placeholderText: "Short name of the canton"
                label: "Canton's Abbreviation"
            }
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            locationId = parseInt(locationField.text, 10)
            name = nameField.text
            canton = cantonField.text
            cantonId = cantonIdField.text
        }
    }
}
