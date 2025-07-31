#include <QStandardPaths>
#include "locations.h"

#define EXPECTED_SCHEMA_VERSION "1"

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
        m_database = QSqlDatabase::addDatabase("QSQLITE", "locations");
        m_database.setDatabaseName(file);

        if (m_database.open()) {
            qDebug() << "[LocationsModel] loading locations.db from" << file;
        } else {
            qDebug() << "[LocationsModel] failed to open locations.db at"
                     << file << ":" << m_database.lastError();
        }

        QStringList tables = m_database.tables();
        if (m_database.tables().contains("locations")) {
            auto version = m_database.exec(R"(SELECT key FROM metadata
                WHERE key = "schema" AND value = )" EXPECTED_SCHEMA_VERSION);
            version.next();

            if (!version.record().isEmpty()) {
                connect(this, &LocationsModel::searchChanged, this, &LocationsModel::updateQuery);
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

void LocationsModel::updateQuery()
{
    // NOTE Remember to update EXPECTED_SCHEMA_VERSION when
    // the database schema changes.

    const static QRegularExpression isNumRe(QStringLiteral("^[0-9]+$"));
    const static QString glob = QStringLiteral("%");
    const static QString esc = QStringLiteral(R"(\%)");
    const static QString start(QStringLiteral(R"(
        SELECT
            locationId,
            primaryName,
            name,
            zip,
            latitude,
            longitude,
            altitude
        FROM locations
    )"));
    const static QString end(QStringLiteral(R"(
        ORDER BY zip
        LIMIT 30;
    )"));
    const static QString zipQueryString(
        start + QStringLiteral(R"(
        WHERE (
            zip LIKE :zipStart AND
            name = primaryName
        )
    )") + end);
    const static QString nameQueryString(
        start + QStringLiteral(R"(
        WHERE (
            name LIKE :nameStart OR
            primaryName LIKE :primaryStart OR
            searchName LIKE :searchStart OR
            name LIKE :nameAny OR
            primaryName LIKE :primaryAny OR
            searchName LIKE :searchAny
        )
    )") + end);

    QSqlQuery query(m_database);

    auto s = m_search.replace(glob, esc);

    if (isNumRe.match(s).hasMatch()) {
        query.prepare(zipQueryString);
        query.bindValue(":zipStart", s + glob);
    } else {
        query.prepare(nameQueryString);
        query.bindValue(":nameStart", s + glob);
        query.bindValue(":primaryStart", s + glob);
        query.bindValue(":searchStart", s + glob);
        query.bindValue(":nameAny", glob + s + glob);
        query.bindValue(":primaryAny", glob + s + glob);
        query.bindValue(":searchAny", glob + s + glob);
    }

    query.exec();
    setQuery(query);
}
