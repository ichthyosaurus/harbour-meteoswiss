/*
 * This file is part of harbour-meteoswiss.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QtQuick>
#include <sailfishapp.h>
#include "requires_defines.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("harbour-meteoswiss"); // needed for Sailjail
    app->setApplicationName("harbour-meteoswiss");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("APP_VERSION", QString(APP_VERSION));
    view->rootContext()->setContextProperty("APP_RELEASE", QString(APP_RELEASE));

    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString());
    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
