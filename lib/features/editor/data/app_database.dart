import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('TemplateRow')
class NotebookTemplates extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get authorId => text().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  TextColumn get remoteId => text().nullable()();
  IntColumn get downloadCount => integer().withDefault(const Constant(0))();
  TextColumn get pageConfigJson => text()();
  TextColumn get layersJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DriftDatabase(tables: [NotebookTemplates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'labnote.db');
  }
}
