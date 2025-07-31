#include <QStandardPaths>
#include "locations.h"

LocationsModel::LocationsModel(QObject* parent) : QSqlQueryModel(parent) {
    roleNamesHash.insert(Qt::UserRole,     QByteArray("locationId"));
    roleNamesHash.insert(Qt::UserRole + 1, QByteArray("primaryName"));
    roleNamesHash.insert(Qt::UserRole + 2, QByteArray("name"));
    roleNamesHash.insert(Qt::UserRole + 3, QByteArray("zip"));
    roleNamesHash.insert(Qt::UserRole + 4, QByteArray("latitude"));
    roleNamesHash.insert(Qt::UserRole + 5, QByteArray("longitude"));
    roleNamesHash.insert(Qt::UserRole + 6, QByteArray("altitude"));

    auto file = QStandardPaths::locate(
        QStandardPaths::StandardLocation::AppDataLocation,
        QStringLiteral("locations.db"),
        QStandardPaths::LocateOption::LocateFile
    );

    if (!file.isEmpty()) {
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "locations");
        db.setDatabaseName(file);

        if (db.open()) {
            qDebug() << "[LocationsModel] loading locations.db from" << file;
        } else {
            qDebug() << "[LocationsModel] failed to open locations.db at"
                     << file << ":" << db.lastError();
        }

        QStringList tables = db.tables();
        if (db.tables().contains("locations")) {
            // TODO define supported schema version and main query
            // somewhere else
            auto version = db.exec(R"(SELECT key FROM metadata
                WHERE key = "schema" AND value = 1)");
            version.next();

            qDebug() << "VERSION" << version.size() << version.record() << version.record() << version.lastError();

            if (!version.record().isEmpty()) {
                setQuery(R"(
                    SELECT
                        locationId,
                        primaryName,
                        name,
                        zip,
                        latitude,
                        longitude,
                        altitude
                    FROM locations
                )", db);
                qDebug() << "ERROR:" << lastError();
            } else {
                qDebug() << "[LocationsModel] failed to load locations: unsupported schema";
            }
        } else {
            qDebug() << "[LocationsModel] failed to load locations: main table missing";
        }
    } else {
        qDebug() << "[LocationsModel] could not find locations.db at" <<
                    QStandardPaths::standardLocations(QStandardPaths::StandardLocation::AppDataLocation);
    }
}

QVariant LocationsModel::data(const QModelIndex& index, int role) const {
    if (role < Qt::UserRole) {
        return QSqlQueryModel::data(index, role);
    }

    QSqlRecord r = record(index.row());
    return r.value(role - Qt::UserRole);
}
