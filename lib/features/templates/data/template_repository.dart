import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../features/editor/data/app_database.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';

class TemplateRepository {
  TemplateRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<List<NotebookTemplate>> getAll() async {
    final rows = await _db.select(_db.notebookTemplates).get();
    return (rows.map(_fromRow).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  Future<NotebookTemplate?> getByUuid(String uuid) async {
    final row = await (_db.select(_db.notebookTemplates)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<NotebookTemplate> save(NotebookTemplate template) async {
    final now = DateTime.now();
    final row = NotebookTemplatesCompanion(
      uuid: Value(template.uuid),
      name: Value(template.name),
      createdAt: Value(template.createdAt),
      updatedAt: Value(now),
      isPinned: Value(template.isPinned),
      tags: Value(jsonEncode(template.tags)),
      authorId: Value(template.authorId),
      isPublic: Value(template.isPublic),
      pageConfigJson: Value(template.pageConfigJson),
      layersJson: Value(jsonEncode(template.layersJson)),
    );
    await _db.into(_db.notebookTemplates).insertOnConflictUpdate(row);
    template.updatedAt = now;
    return template;
  }

  Future<NotebookTemplate> create({
    required String name,
    required PageConfig pageConfig,
    required List<LayerEntity> layers,
    String? authorId,
  }) async {
    final now = DateTime.now();
    final template = NotebookTemplate()
      ..uuid = _uuid.v4()
      ..name = name
      ..createdAt = now
      ..updatedAt = now
      ..authorId = authorId
      ..pageConfig = pageConfig
      ..layers = layers;
    return save(template);
  }

  Future<void> delete(String uuid) async {
    await (_db.delete(_db.notebookTemplates)
          ..where((t) => t.uuid.equals(uuid)))
        .go();
  }

  NotebookTemplate _fromRow(TemplateRow row) {
    final t = NotebookTemplate()
      ..uuid = row.uuid
      ..name = row.name
      ..createdAt = row.createdAt
      ..updatedAt = row.updatedAt
      ..isPinned = row.isPinned
      ..tags = (jsonDecode(row.tags) as List).cast<String>()
      ..authorId = row.authorId
      ..isPublic = row.isPublic
      ..pageConfigJson = row.pageConfigJson
      ..layersJson = (jsonDecode(row.layersJson) as List).cast<String>();
    return t;
  }
}
