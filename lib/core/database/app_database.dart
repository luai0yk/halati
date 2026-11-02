import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:status_saver/core/database/saved_media_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SavedMediaTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'status_saver'));

  @override
  int get schemaVersion => 1;
}
