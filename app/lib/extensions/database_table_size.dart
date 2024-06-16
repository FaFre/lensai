import 'package:drift/drift.dart';

extension TableSIze on DatabaseConnectionUser {
  SingleSelectable<double> tableSize(TableInfo table) {
    return customSelect(
      'SELECT SUM(pgsize) /(1024.0 * 1024.0)AS pgsize_mb FROM dbstat WHERE name = ?1',
      variables: [Variable<String>(table.actualTableName)],
      readsFrom: {table},
    ).map((QueryRow row) => row.read<double>('pgsize_mb'));
  }
}
