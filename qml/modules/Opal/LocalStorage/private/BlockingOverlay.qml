//@ This file is part of opal-localstorage.
//@ https://github.com/Pretty-SFOS/opal-localstorage
//@ SPDX-License-Identifier: GPL-3.0-or-later
//@ SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
import QtQuick 2.0
import Sailfish.Silica 1.0
import"."
Rectangle{id:root
objectName:"BlockingOverlay"
property alias text:label.text
property alias hintText:label.hintText
property alias busy:label.running
property bool _destroyAfterHiding:false
readonly property bool _portrait:(__silica_applicationwindow_instance.orientation&Orientation.PortraitMask)!==0
function show(){state="shown"
}function hide(destroyAfter){state="hidden"
_destroyAfterHiding=destroyAfter
}state:"hidden"
visible:false
opacity:0.0
parent:__silica_applicationwindow_instance.contentItem
rotation:__silica_applicationwindow_instance._rotatingItem.rotation
color:Theme.highlightDimmerColor
anchors.centerIn:parent
width:_portrait?parent.width:parent.height
height:_portrait?parent.height:parent.width
SilicaFlickable{id:flick
anchors.fill:parent
anchors.centerIn:parent
contentHeight:label.height
contentWidth:root.width
VerticalScrollDecorator{flickable:flick
}ExtendedBusyLabel{id:label
running:root.visible
}}states:[State{name:"shown"
PropertyChanges{target:root
visible:true
}PropertyChanges{target:root
opacity:1.0
}},State{name:"hidden"
PropertyChanges{target:root
opacity:0.0
}PropertyChanges{target:root
visible:false
}}]transitions:[Transition{to:"shown"
SequentialAnimation{NumberAnimation{target:root
property:"visible"
duration:0
}NumberAnimation{target:root
property:"opacity"
duration:200
easing.type:Easing.InOutQuad
}}},Transition{to:"hidden"
SequentialAnimation{NumberAnimation{target:root
property:"opacity"
duration:300
easing.type:Easing.InOutQuad
}NumberAnimation{target:root
property:"visible"
duration:0
}ScriptAction{script:{if(root._destroyAfterHiding){root.destroy()
}}}}}]}