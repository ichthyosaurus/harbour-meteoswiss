import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property var descriptionLabel
    property string description
    property alias label: item.label
    property alias value: item.value

    onClicked: {
        if (descriptionLabel && descriptionLabel.text) {
            descriptionLabel.text = String(qsTr("%1: %2", "sun time title (1) with description (2)")).arg(label).arg(description)
        }
    }

    DetailItem {
        id: item
        label: ""
        value: ""
    }
}
