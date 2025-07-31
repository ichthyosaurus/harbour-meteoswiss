#include <QtSql>
#include <QSqlQueryModel>
#include <QHash>
#include <QString>
#include <QModelIndex>
#include <QVariant>

class LocationsModel : public QSqlQueryModel {
public:
    LocationsModel(QObject* parent = 0);

    QVariant data(const QModelIndex& index, int role) const;

    QHash<int, QByteArray> roleNames() const {
        return roleNamesHash;
    }

private:
    QHash<int, QByteArray> roleNamesHash;
};
