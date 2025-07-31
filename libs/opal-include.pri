# This file is part of Opal.
# SPDX-FileCopyrightText: 2023-2024 Mirian Margiani
# SPDX-License-Identifier: CC-BY-SA-4.0
#
# Include this file in your main .pro file to enable
# Opal modules that use or provide C++ sources and/or headers.
#
# Add this line to your main .pro file:
#       include(libs/opal-include.pri)
#
# You can then use Opal headers by including them in your
# C++ files like this:
#       #include <libs/opal/mymodule/myheader.h>
#
# NOTE: this is a generic helper file used by all Opal source
# modules. You can safely overwrite it when updating a module.
#

# Make headers available for inclusion
INCLUDEPATH += $$relative_path($$PWD/opal)

# Search for any project include files and include them now
message(Searching for Opal source modules...)

OPAL_SOURCE_MODULES = $$files($$PWD/opal/*)
for (module, OPAL_SOURCE_MODULES) {
    module_includes = $$files($$module/*.pri)

    for (to_include, module_includes) {
        message(Enabling Opal source module <libs/$$relative_path($$dirname(to_include))>)
        include($$to_include)
    }
}
