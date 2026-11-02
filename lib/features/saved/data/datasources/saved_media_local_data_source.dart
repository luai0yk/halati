import 'package:drift/drift.dart';
import 'package:status_saver/core/database/app_database.dart';
import 'package:status_saver/features/saved/data/models/saved_media_model.dart';

abstract class SavedMediaLocalDataSource {
  Stream<List<SavedMediaModel>> watchSavedMedia();
  Future<List<SavedMediaModel>> getSavedMedia();
  Future<int> insertSavedMedia(SavedMediaTableCompanion companion);
  Future<int> deleteSavedMedia(int id);
}

class SavedMediaLocalDataSourceImpl implements SavedMediaLocalDataSource {
  final AppDatabase _database;

  SavedMediaLocalDataSourceImpl(this._database);

  @override
  Stream<List<SavedMediaModel>> watchSavedMedia() {
    final query = _database.select(_database.savedMediaTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.savedAt, mode: OrderingMode.desc),
      ]);

    return query.watch().map(
          (rows) => rows.map((r) => SavedMediaModel.fromData(r)).toList(),
        );
  }

  @override
  Future<List<SavedMediaModel>> getSavedMedia() async {
    final query = _database.select(_database.savedMediaTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.savedAt, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows.map((r) => SavedMediaModel.fromData(r)).toList();
  }

  @override
  Future<int> insertSavedMedia(SavedMediaTableCompanion companion) async {
    return await _database.into(_database.savedMediaTable).insert(companion);
  }

  @override
  Future<int> deleteSavedMedia(int id) async {
    return await (_database.delete(_database.savedMediaTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}
