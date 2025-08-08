//@ This file is part of opal-localstorage.
//@ https://github.com/Pretty-SFOS/opal-localstorage
//@ SPDX-License-Identifier: GPL-3.0-or-later
//@ SPDX-FileCopyrightText: 2018-2025 Mirian Margiani
import QtQuick 2.0
import Sailfish.Silica 1.0
import"private"
import"."
Item{id:root
signal userSignalReceived(var event,var handle,var busy,var data)
property var __events:({})
property var __userEvents:({})
readonly property string _lc:"[Opal.LocalStorage] MessageHandler:"
signal __databaseSignalReceived(var event,var handle,var busy,var data)
function showOverlay(handle,title,description,busy){var obj=overlayComponent.createObject(__silica_applicationwindow_instance,{text:title,hintText:description,busy:busy})
if(obj===null){console.error(_lc,"failed to show status overlay!")
}else{obj.show()
}if(__events.hasOwnProperty(handle)){console.warn(_lc,"replacing event with handle",handle)
_hideOverlay(handle)
}__events[handle]=obj
}function hideOverlay(handle){if(__events.hasOwnProperty(handle)){__events[handle].hide(true)
delete __events[handle]
}}function allowDismissOverlay(handle){}function _register(force){if(!force&&!!LocalStorage._DB_STATUS_SIGNAL){console.warn(_lc,"database status signal already set!")
}else{LocalStorage._DB_STATUS_SIGNAL=__databaseSignalReceived
}}visible:false
parent:__silica_applicationwindow_instance
on__DatabaseSignalReceived:{if(/^user-/ .test(handle)){__userEvents[handle]=1
userSignalReceived(event,handle,busy,data)
return
}function _show(title,hint){showOverlay(handle,title,hint,busy)
}
switch(event){case"end":if(!__userEvents.hasOwnProperty(handle)){hideOverlay(handle)
}break
case"init":case"upgrade":break
case"query-failed":break
case"upgrade-failed":_show(qsTranslate("Opal.LocalStorage","Database upgrade failed"),"<p>"+qsTranslate("Opal.LocalStorage","An error occurred while upgrading "+"the database from version %1 to version %2. "+"Please report this issue.").arg(data.from).arg(data.to)+"</p><p><font size='2'><br><b>"+qsTranslate("Opal.LocalStorage","Developer information:")+"</b><br>\n                    %1<br>\n                    Stack:<br>%2\n                  </font></p>\n                  ".arg(data.exception).arg(data.exception.stack.split("\n").join("<br><br>")))
break
case"invalid-version":_show(qsTranslate("Opal.LocalStorage","Invalid database version"),qsTranslate("Opal.LocalStorage","The app cannot start because "+"the database has version %1 "+"but only version %2 is supported.").arg(data.got).arg(data.expected))
break
case"maintenance":_show(qsTranslate("Opal.LocalStorage","Database Maintenance"),qsTranslate("Opal.LocalStorage","Please be patient and allow up to 30 seconds for this."))
break
default:_show(qsTranslate("Opal.LocalStorage","Database issue"),"<p>"+qsTranslate("Opal.LocalStorage","An unexpected issue occurred in the database. Try restarting the app.")+"</p><p><font size='2'>\n                   <br><b>"+qsTranslate("Opal.LocalStorage","Developer information:")+"</b><br>\n                   Event: %1<br>\n                   Data: %2\n                   </font></p>".arg(event).arg(JSON.stringify(data)))
break
}}Component{id:overlayComponent
BlockingOverlay{}}Component.onCompleted:{_register()
}}