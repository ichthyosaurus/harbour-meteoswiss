import QtQuick 2.2
import Sailfish.Silica 1.0


Cover {
    width: Theme.coverSizeLarge.width
    height: Theme.coverSizeLarge.height
    allowResize: true

    Label {
        id: label
        anchors.centerIn: parent
        text: "Weather"
        x: Theme.paddingSmall
        width: parent.width
        // horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        truncationMode: TruncationMode.Fade
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
        opacity: Theme.highlightBackgroundOpacity
    }

    Image {
        id: background_image
        z: -1
        source: "cover.png"
        opacity: 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sourceSize.height * width / sourceSize.width
    }

//     CoverActionList {
//         id: coverAction
//
//         CoverAction {
//             iconSource: "image://theme/icon-cover-search"
//             onTriggered: console.log("trigger cover action")
//         }
//     }
}
