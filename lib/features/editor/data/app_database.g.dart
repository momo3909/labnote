// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotebookTemplatesTable extends NotebookTemplates
    with TableInfo<$NotebookTemplatesTable, TemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebookTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadCountMeta = const VerificationMeta(
    'downloadCount',
  );
  @override
  late final GeneratedColumn<int> downloadCount = GeneratedColumn<int>(
    'download_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pageConfigJsonMeta = const VerificationMeta(
    'pageConfigJson',
  );
  @override
  late final GeneratedColumn<String> pageConfigJson = GeneratedColumn<String>(
    'page_config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _layersJsonMeta = const VerificationMeta(
    'layersJson',
  );
  @override
  late final GeneratedColumn<String> layersJson = GeneratedColumn<String>(
    'layers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    name,
    createdAt,
    updatedAt,
    isPinned,
    tags,
    authorId,
    isPublic,
    remoteId,
    downloadCount,
    pageConfigJson,
    layersJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebook_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('download_count')) {
      context.handle(
        _downloadCountMeta,
        downloadCount.isAcceptableOrUnknown(
          data['download_count']!,
          _downloadCountMeta,
        ),
      );
    }
    if (data.containsKey('page_config_json')) {
      context.handle(
        _pageConfigJsonMeta,
        pageConfigJson.isAcceptableOrUnknown(
          data['page_config_json']!,
          _pageConfigJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pageConfigJsonMeta);
    }
    if (data.containsKey('layers_json')) {
      context.handle(
        _layersJsonMeta,
        layersJson.isAcceptableOrUnknown(data['layers_json']!, _layersJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  TemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      ),
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      downloadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}download_count'],
      )!,
      pageConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_config_json'],
      )!,
      layersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layers_json'],
      )!,
    );
  }

  @override
  $NotebookTemplatesTable createAlias(String alias) {
    return $NotebookTemplatesTable(attachedDatabase, alias);
  }
}

class TemplateRow extends DataClass implements Insertable<TemplateRow> {
  final String uuid;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final String tags;
  final String? authorId;
  final bool isPublic;
  final String? remoteId;
  final int downloadCount;
  final String pageConfigJson;
  final String layersJson;
  const TemplateRow({
    required this.uuid,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.tags,
    this.authorId,
    required this.isPublic,
    this.remoteId,
    required this.downloadCount,
    required this.pageConfigJson,
    required this.layersJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || authorId != null) {
      map['author_id'] = Variable<String>(authorId);
    }
    map['is_public'] = Variable<bool>(isPublic);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['download_count'] = Variable<int>(downloadCount);
    map['page_config_json'] = Variable<String>(pageConfigJson);
    map['layers_json'] = Variable<String>(layersJson);
    return map;
  }

  NotebookTemplatesCompanion toCompanion(bool nullToAbsent) {
    return NotebookTemplatesCompanion(
      uuid: Value(uuid),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isPinned: Value(isPinned),
      tags: Value(tags),
      authorId: authorId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorId),
      isPublic: Value(isPublic),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      downloadCount: Value(downloadCount),
      pageConfigJson: Value(pageConfigJson),
      layersJson: Value(layersJson),
    );
  }

  factory TemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      tags: serializer.fromJson<String>(json['tags']),
      authorId: serializer.fromJson<String?>(json['authorId']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      downloadCount: serializer.fromJson<int>(json['downloadCount']),
      pageConfigJson: serializer.fromJson<String>(json['pageConfigJson']),
      layersJson: serializer.fromJson<String>(json['layersJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isPinned': serializer.toJson<bool>(isPinned),
      'tags': serializer.toJson<String>(tags),
      'authorId': serializer.toJson<String?>(authorId),
      'isPublic': serializer.toJson<bool>(isPublic),
      'remoteId': serializer.toJson<String?>(remoteId),
      'downloadCount': serializer.toJson<int>(downloadCount),
      'pageConfigJson': serializer.toJson<String>(pageConfigJson),
      'layersJson': serializer.toJson<String>(layersJson),
    };
  }

  TemplateRow copyWith({
    String? uuid,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? tags,
    Value<String?> authorId = const Value.absent(),
    bool? isPublic,
    Value<String?> remoteId = const Value.absent(),
    int? downloadCount,
    String? pageConfigJson,
    String? layersJson,
  }) => TemplateRow(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isPinned: isPinned ?? this.isPinned,
    tags: tags ?? this.tags,
    authorId: authorId.present ? authorId.value : this.authorId,
    isPublic: isPublic ?? this.isPublic,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    downloadCount: downloadCount ?? this.downloadCount,
    pageConfigJson: pageConfigJson ?? this.pageConfigJson,
    layersJson: layersJson ?? this.layersJson,
  );
  TemplateRow copyWithCompanion(NotebookTemplatesCompanion data) {
    return TemplateRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      tags: data.tags.present ? data.tags.value : this.tags,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      downloadCount: data.downloadCount.present
          ? data.downloadCount.value
          : this.downloadCount,
      pageConfigJson: data.pageConfigJson.present
          ? data.pageConfigJson.value
          : this.pageConfigJson,
      layersJson: data.layersJson.present
          ? data.layersJson.value
          : this.layersJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateRow(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('tags: $tags, ')
          ..write('authorId: $authorId, ')
          ..write('isPublic: $isPublic, ')
          ..write('remoteId: $remoteId, ')
          ..write('downloadCount: $downloadCount, ')
          ..write('pageConfigJson: $pageConfigJson, ')
          ..write('layersJson: $layersJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    name,
    createdAt,
    updatedAt,
    isPinned,
    tags,
    authorId,
    isPublic,
    remoteId,
    downloadCount,
    pageConfigJson,
    layersJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateRow &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isPinned == this.isPinned &&
          other.tags == this.tags &&
          other.authorId == this.authorId &&
          other.isPublic == this.isPublic &&
          other.remoteId == this.remoteId &&
          other.downloadCount == this.downloadCount &&
          other.pageConfigJson == this.pageConfigJson &&
          other.layersJson == this.layersJson);
}

class NotebookTemplatesCompanion extends UpdateCompanion<TemplateRow> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isPinned;
  final Value<String> tags;
  final Value<String?> authorId;
  final Value<bool> isPublic;
  final Value<String?> remoteId;
  final Value<int> downloadCount;
  final Value<String> pageConfigJson;
  final Value<String> layersJson;
  final Value<int> rowid;
  const NotebookTemplatesCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.tags = const Value.absent(),
    this.authorId = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.downloadCount = const Value.absent(),
    this.pageConfigJson = const Value.absent(),
    this.layersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotebookTemplatesCompanion.insert({
    required String uuid,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isPinned = const Value.absent(),
    this.tags = const Value.absent(),
    this.authorId = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.downloadCount = const Value.absent(),
    required String pageConfigJson,
    this.layersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       pageConfigJson = Value(pageConfigJson);
  static Insertable<TemplateRow> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isPinned,
    Expression<String>? tags,
    Expression<String>? authorId,
    Expression<bool>? isPublic,
    Expression<String>? remoteId,
    Expression<int>? downloadCount,
    Expression<String>? pageConfigJson,
    Expression<String>? layersJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isPinned != null) 'is_pinned': isPinned,
      if (tags != null) 'tags': tags,
      if (authorId != null) 'author_id': authorId,
      if (isPublic != null) 'is_public': isPublic,
      if (remoteId != null) 'remote_id': remoteId,
      if (downloadCount != null) 'download_count': downloadCount,
      if (pageConfigJson != null) 'page_config_json': pageConfigJson,
      if (layersJson != null) 'layers_json': layersJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotebookTemplatesCompanion copyWith({
    Value<String>? uuid,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isPinned,
    Value<String>? tags,
    Value<String?>? authorId,
    Value<bool>? isPublic,
    Value<String?>? remoteId,
    Value<int>? downloadCount,
    Value<String>? pageConfigJson,
    Value<String>? layersJson,
    Value<int>? rowid,
  }) {
    return NotebookTemplatesCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      isPublic: isPublic ?? this.isPublic,
      remoteId: remoteId ?? this.remoteId,
      downloadCount: downloadCount ?? this.downloadCount,
      pageConfigJson: pageConfigJson ?? this.pageConfigJson,
      layersJson: layersJson ?? this.layersJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (downloadCount.present) {
      map['download_count'] = Variable<int>(downloadCount.value);
    }
    if (pageConfigJson.present) {
      map['page_config_json'] = Variable<String>(pageConfigJson.value);
    }
    if (layersJson.present) {
      map['layers_json'] = Variable<String>(layersJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebookTemplatesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('tags: $tags, ')
          ..write('authorId: $authorId, ')
          ..write('isPublic: $isPublic, ')
          ..write('remoteId: $remoteId, ')
          ..write('downloadCount: $downloadCount, ')
          ..write('pageConfigJson: $pageConfigJson, ')
          ..write('layersJson: $layersJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotebookTemplatesTable notebookTemplates =
      $NotebookTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [notebookTemplates];
}

typedef $$NotebookTemplatesTableCreateCompanionBuilder =
    NotebookTemplatesCompanion Function({
      required String uuid,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isPinned,
      Value<String> tags,
      Value<String?> authorId,
      Value<bool> isPublic,
      Value<String?> remoteId,
      Value<int> downloadCount,
      required String pageConfigJson,
      Value<String> layersJson,
      Value<int> rowid,
    });
typedef $$NotebookTemplatesTableUpdateCompanionBuilder =
    NotebookTemplatesCompanion Function({
      Value<String> uuid,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isPinned,
      Value<String> tags,
      Value<String?> authorId,
      Value<bool> isPublic,
      Value<String?> remoteId,
      Value<int> downloadCount,
      Value<String> pageConfigJson,
      Value<String> layersJson,
      Value<int> rowid,
    });

class $$NotebookTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $NotebookTemplatesTable> {
  $$NotebookTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadCount => $composableBuilder(
    column: $table.downloadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageConfigJson => $composableBuilder(
    column: $table.pageConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layersJson => $composableBuilder(
    column: $table.layersJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotebookTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotebookTemplatesTable> {
  $$NotebookTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadCount => $composableBuilder(
    column: $table.downloadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageConfigJson => $composableBuilder(
    column: $table.pageConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layersJson => $composableBuilder(
    column: $table.layersJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotebookTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotebookTemplatesTable> {
  $$NotebookTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get downloadCount => $composableBuilder(
    column: $table.downloadCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pageConfigJson => $composableBuilder(
    column: $table.pageConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get layersJson => $composableBuilder(
    column: $table.layersJson,
    builder: (column) => column,
  );
}

class $$NotebookTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotebookTemplatesTable,
          TemplateRow,
          $$NotebookTemplatesTableFilterComposer,
          $$NotebookTemplatesTableOrderingComposer,
          $$NotebookTemplatesTableAnnotationComposer,
          $$NotebookTemplatesTableCreateCompanionBuilder,
          $$NotebookTemplatesTableUpdateCompanionBuilder,
          (
            TemplateRow,
            BaseReferences<_$AppDatabase, $NotebookTemplatesTable, TemplateRow>,
          ),
          TemplateRow,
          PrefetchHooks Function()
        > {
  $$NotebookTemplatesTableTableManager(
    _$AppDatabase db,
    $NotebookTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebookTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebookTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebookTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String?> authorId = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> downloadCount = const Value.absent(),
                Value<String> pageConfigJson = const Value.absent(),
                Value<String> layersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebookTemplatesCompanion(
                uuid: uuid,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isPinned: isPinned,
                tags: tags,
                authorId: authorId,
                isPublic: isPublic,
                remoteId: remoteId,
                downloadCount: downloadCount,
                pageConfigJson: pageConfigJson,
                layersJson: layersJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isPinned = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String?> authorId = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> downloadCount = const Value.absent(),
                required String pageConfigJson,
                Value<String> layersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebookTemplatesCompanion.insert(
                uuid: uuid,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isPinned: isPinned,
                tags: tags,
                authorId: authorId,
                isPublic: isPublic,
                remoteId: remoteId,
                downloadCount: downloadCount,
                pageConfigJson: pageConfigJson,
                layersJson: layersJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotebookTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotebookTemplatesTable,
      TemplateRow,
      $$NotebookTemplatesTableFilterComposer,
      $$NotebookTemplatesTableOrderingComposer,
      $$NotebookTemplatesTableAnnotationComposer,
      $$NotebookTemplatesTableCreateCompanionBuilder,
      $$NotebookTemplatesTableUpdateCompanionBuilder,
      (
        TemplateRow,
        BaseReferences<_$AppDatabase, $NotebookTemplatesTable, TemplateRow>,
      ),
      TemplateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotebookTemplatesTableTableManager get notebookTemplates =>
      $$NotebookTemplatesTableTableManager(_db, _db.notebookTemplates);
}
