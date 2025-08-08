/*
 * This file is part of harbour-meteoswiss.
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QtSql>
#include <QSqlQueryModel>
#include <QHash>
#include <QString>
#include <QModelIndex>
#include <QVariant>

#include <libs/opal/propertymacros/property_macros.h>

class LocationsModel : public QSqlQueryModel {
    Q_OBJECT
    RW_PROPERTY(QString, search, Search, QStringLiteral(""))
    RO_PROPERTY(bool, haveDatabase, true)

public:
    LocationsModel(QObject* parent = 0);

    QVariant data(const QModelIndex& index, int role) const;

    QHash<int, QByteArray> roleNames() const {
        return roleNamesHash;
    }

private slots:
    void updateQuery();

private:
    QHash<int, QByteArray> roleNamesHash;
    QSqlDatabase m_database;
};
