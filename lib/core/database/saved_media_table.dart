import 'package:drift/drift.dart';

class SavedMediaTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get originalDocumentUri => text()();
  TextColumn get mediaStoreUri => text()();
  TextColumn get relativePath => text()();
  TextColumn get fileName => text()();
  TextColumn get mediaType => text()(); // 'image', 'video', 'audio'
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get savedAt => dateTime()();
  DateTimeColumn get sourceCreatedAt => dateTime()();
}
