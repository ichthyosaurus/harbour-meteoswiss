#include <QStandardPaths>
#include <sailfishapp.h>
#include "locations.h"

#define EXPECTED_SCHEMA_VERSION "1"

LocationsModel::LocationsModel(QObject* parent) : QSqlQueryModel(parent) {
    m_haveDatabase = false;

    roleNamesHash.insert(Qt::UserRole,     QByteArray("locationId"));
    roleNamesHash.insert(Qt::UserRole + 1, QByteArray("primaryName"));
    roleNamesHash.insert(Qt::UserRole + 2, QByteArray("name"));
    roleNamesHash.insert(Qt::UserRole + 3, QByteArray("zip"));
    roleNamesHash.insert(Qt::UserRole + 4, QByteArray("latitude"));
    roleNamesHash.insert(Qt::UserRole + 5, QByteArray("longitude"));
    roleNamesHash.insert(Qt::UserRole + 6, QByteArray("altitude"));

    auto file = QStandardPaths::locate(
        QStandardPaths::StandardLocation::AppDataLocation,
        QStringLiteral("db/locations.db"),
        QStandardPaths::LocateOption::LocateFile
    );

    if (file.isEmpty()) {
        file = SailfishApp::pathTo("qml/db/locations.db").toLocalFile();
    }

    if (!file.isEmpty() && QFileInfo::exists(file)) {
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
                m_haveDatabase = true;
            } else {
                qDebug() << "[LocationsModel] failed to load locations: unsupported schema";
            }
        } else {
            qDebug() << "[LocationsModel] failed to load locations: main table missing";
        }
    } else {
        qDebug() << "[LocationsModel] could not find locations.db at" <<
                    QStandardPaths::standardLocations(QStandardPaths::StandardLocation::AppDataLocation) <<
                    ", got" << file;
    }

    emit haveDatabaseChanged();
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

    if (m_search.isEmpty()) {
        setQuery("");
        return;
    }

    const static QRegularExpression isNumRe(QStringLiteral("^[0-9]+$"));
    const static QString glob = QStringLiteral("%");
    const static QString esc = QStringLiteral(R"(\%)");
    const static QString select(QStringLiteral(R"(
        SELECT
            locationId,
            primaryName,
            name,
            zip,
            latitude,
            longitude,
            altitude
    )"));
    const static QString limit(QStringLiteral(R"(
        LIMIT 30;
    )"));
    const static QString zipQueryString(
        select + QStringLiteral(R"(
        FROM locations
        WHERE (
            zip LIKE :zipStart AND
            name = primaryName
        )
        ORDER BY zip
    )") + limit);
    const static QString nameQueryString(
        QStringLiteral(R"(
        WITH cte AS (
            SELECT *, RANK() OVER (ORDER BY
                (name LIKE :nameStart) +
                (searchName LIKE :searchNameStart) +
                (primaryName LIKE :primaryNameStart) +
                (searchPrimary LIKE :searchPrimaryStart) +
                (searchName LIKE :searchNameAny) +
                (searchPrimary LIKE :searchPrimaryAny) +
                0 DESC) rn
            FROM locations
        ) )") + select + QStringLiteral(R"(
        FROM cte
        ORDER BY rn
    )") + limit);

    QSqlQuery query(m_database);

    auto s = m_search.replace(glob, esc);

    if (isNumRe.match(s).hasMatch()) {
        query.prepare(zipQueryString);
        query.bindValue(":zipStart", s + glob);
    } else {
        query.prepare(nameQueryString);
        query.bindValue(":nameStart", s + glob);
        query.bindValue(":searchNameStart", s + glob);
        query.bindValue(":primaryNameStart", s + glob);
        query.bindValue(":searchPrimaryStart", s + glob);
        query.bindValue(":searchNameAny", glob + s + glob);
        query.bindValue(":searchPrimaryAny", glob + s + glob);
    }

    query.exec();
    setQuery(query);
}
