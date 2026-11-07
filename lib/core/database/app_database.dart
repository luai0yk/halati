import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:halati/core/database/saved_media_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SavedMediaTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'halati'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(savedMediaTable, savedMediaTable.whatsAppType);
      }
    },
  );
}
