// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SavedMediaTableTable extends SavedMediaTable
    with TableInfo<$SavedMediaTableTable, SavedMediaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedMediaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _originalDocumentUriMeta =
      const VerificationMeta('originalDocumentUri');
  @override
  late final GeneratedColumn<String> originalDocumentUri =
      GeneratedColumn<String>(
        'original_document_uri',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _mediaStoreUriMeta = const VerificationMeta(
    'mediaStoreUri',
  );
  @override
  late final GeneratedColumn<String> mediaStoreUri = GeneratedColumn<String>(
    'media_store_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceCreatedAtMeta = const VerificationMeta(
    'sourceCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sourceCreatedAt =
      GeneratedColumn<DateTime>(
        'source_created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _whatsAppTypeMeta = const VerificationMeta(
    'whatsAppType',
  );
  @override
  late final GeneratedColumn<String> whatsAppType = GeneratedColumn<String>(
    'whats_app_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('whatsapp'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalDocumentUri,
    mediaStoreUri,
    relativePath,
    fileName,
    mediaType,
    mimeType,
    fileSize,
    durationMs,
    savedAt,
    sourceCreatedAt,
    whatsAppType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_media_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedMediaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_document_uri')) {
      context.handle(
        _originalDocumentUriMeta,
        originalDocumentUri.isAcceptableOrUnknown(
          data['original_document_uri']!,
          _originalDocumentUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalDocumentUriMeta);
    }
    if (data.containsKey('media_store_uri')) {
      context.handle(
        _mediaStoreUriMeta,
        mediaStoreUri.isAcceptableOrUnknown(
          data['media_store_uri']!,
          _mediaStoreUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaStoreUriMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('source_created_at')) {
      context.handle(
        _sourceCreatedAtMeta,
        sourceCreatedAt.isAcceptableOrUnknown(
          data['source_created_at']!,
          _sourceCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceCreatedAtMeta);
    }
    if (data.containsKey('whats_app_type')) {
      context.handle(
        _whatsAppTypeMeta,
        whatsAppType.isAcceptableOrUnknown(
          data['whats_app_type']!,
          _whatsAppTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedMediaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedMediaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      originalDocumentUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_document_uri'],
      )!,
      mediaStoreUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_store_uri'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      sourceCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}source_created_at'],
      )!,
      whatsAppType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}whats_app_type'],
      )!,
    );
  }

  @override
  $SavedMediaTableTable createAlias(String alias) {
    return $SavedMediaTableTable(attachedDatabase, alias);
  }
}

class SavedMediaTableData extends DataClass
    implements Insertable<SavedMediaTableData> {
  final int id;
  final String originalDocumentUri;
  final String mediaStoreUri;
  final String relativePath;
  final String fileName;
  final String mediaType;
  final String mimeType;
  final int fileSize;
  final int? durationMs;
  final DateTime savedAt;
  final DateTime sourceCreatedAt;
  final String whatsAppType;
  const SavedMediaTableData({
    required this.id,
    required this.originalDocumentUri,
    required this.mediaStoreUri,
    required this.relativePath,
    required this.fileName,
    required this.mediaType,
    required this.mimeType,
    required this.fileSize,
    this.durationMs,
    required this.savedAt,
    required this.sourceCreatedAt,
    required this.whatsAppType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['original_document_uri'] = Variable<String>(originalDocumentUri);
    map['media_store_uri'] = Variable<String>(mediaStoreUri);
    map['relative_path'] = Variable<String>(relativePath);
    map['file_name'] = Variable<String>(fileName);
    map['media_type'] = Variable<String>(mediaType);
    map['mime_type'] = Variable<String>(mimeType);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['source_created_at'] = Variable<DateTime>(sourceCreatedAt);
    map['whats_app_type'] = Variable<String>(whatsAppType);
    return map;
  }

  SavedMediaTableCompanion toCompanion(bool nullToAbsent) {
    return SavedMediaTableCompanion(
      id: Value(id),
      originalDocumentUri: Value(originalDocumentUri),
      mediaStoreUri: Value(mediaStoreUri),
      relativePath: Value(relativePath),
      fileName: Value(fileName),
      mediaType: Value(mediaType),
      mimeType: Value(mimeType),
      fileSize: Value(fileSize),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      savedAt: Value(savedAt),
      sourceCreatedAt: Value(sourceCreatedAt),
      whatsAppType: Value(whatsAppType),
    );
  }

  factory SavedMediaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedMediaTableData(
      id: serializer.fromJson<int>(json['id']),
      originalDocumentUri: serializer.fromJson<String>(
        json['originalDocumentUri'],
      ),
      mediaStoreUri: serializer.fromJson<String>(json['mediaStoreUri']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      sourceCreatedAt: serializer.fromJson<DateTime>(json['sourceCreatedAt']),
      whatsAppType: serializer.fromJson<String>(json['whatsAppType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalDocumentUri': serializer.toJson<String>(originalDocumentUri),
      'mediaStoreUri': serializer.toJson<String>(mediaStoreUri),
      'relativePath': serializer.toJson<String>(relativePath),
      'fileName': serializer.toJson<String>(fileName),
      'mediaType': serializer.toJson<String>(mediaType),
      'mimeType': serializer.toJson<String>(mimeType),
      'fileSize': serializer.toJson<int>(fileSize),
      'durationMs': serializer.toJson<int?>(durationMs),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'sourceCreatedAt': serializer.toJson<DateTime>(sourceCreatedAt),
      'whatsAppType': serializer.toJson<String>(whatsAppType),
    };
  }

  SavedMediaTableData copyWith({
    int? id,
    String? originalDocumentUri,
    String? mediaStoreUri,
    String? relativePath,
    String? fileName,
    String? mediaType,
    String? mimeType,
    int? fileSize,
    Value<int?> durationMs = const Value.absent(),
    DateTime? savedAt,
    DateTime? sourceCreatedAt,
    String? whatsAppType,
  }) => SavedMediaTableData(
    id: id ?? this.id,
    originalDocumentUri: originalDocumentUri ?? this.originalDocumentUri,
    mediaStoreUri: mediaStoreUri ?? this.mediaStoreUri,
    relativePath: relativePath ?? this.relativePath,
    fileName: fileName ?? this.fileName,
    mediaType: mediaType ?? this.mediaType,
    mimeType: mimeType ?? this.mimeType,
    fileSize: fileSize ?? this.fileSize,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    savedAt: savedAt ?? this.savedAt,
    sourceCreatedAt: sourceCreatedAt ?? this.sourceCreatedAt,
    whatsAppType: whatsAppType ?? this.whatsAppType,
  );
  SavedMediaTableData copyWithCompanion(SavedMediaTableCompanion data) {
    return SavedMediaTableData(
      id: data.id.present ? data.id.value : this.id,
      originalDocumentUri: data.originalDocumentUri.present
          ? data.originalDocumentUri.value
          : this.originalDocumentUri,
      mediaStoreUri: data.mediaStoreUri.present
          ? data.mediaStoreUri.value
          : this.mediaStoreUri,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      sourceCreatedAt: data.sourceCreatedAt.present
          ? data.sourceCreatedAt.value
          : this.sourceCreatedAt,
      whatsAppType: data.whatsAppType.present
          ? data.whatsAppType.value
          : this.whatsAppType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedMediaTableData(')
          ..write('id: $id, ')
          ..write('originalDocumentUri: $originalDocumentUri, ')
          ..write('mediaStoreUri: $mediaStoreUri, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileName: $fileName, ')
          ..write('mediaType: $mediaType, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('durationMs: $durationMs, ')
          ..write('savedAt: $savedAt, ')
          ..write('sourceCreatedAt: $sourceCreatedAt, ')
          ..write('whatsAppType: $whatsAppType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    originalDocumentUri,
    mediaStoreUri,
    relativePath,
    fileName,
    mediaType,
    mimeType,
    fileSize,
    durationMs,
    savedAt,
    sourceCreatedAt,
    whatsAppType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMediaTableData &&
          other.id == this.id &&
          other.originalDocumentUri == this.originalDocumentUri &&
          other.mediaStoreUri == this.mediaStoreUri &&
          other.relativePath == this.relativePath &&
          other.fileName == this.fileName &&
          other.mediaType == this.mediaType &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.durationMs == this.durationMs &&
          other.savedAt == this.savedAt &&
          other.sourceCreatedAt == this.sourceCreatedAt &&
          other.whatsAppType == this.whatsAppType);
}

class SavedMediaTableCompanion extends UpdateCompanion<SavedMediaTableData> {
  final Value<int> id;
  final Value<String> originalDocumentUri;
  final Value<String> mediaStoreUri;
  final Value<String> relativePath;
  final Value<String> fileName;
  final Value<String> mediaType;
  final Value<String> mimeType;
  final Value<int> fileSize;
  final Value<int?> durationMs;
  final Value<DateTime> savedAt;
  final Value<DateTime> sourceCreatedAt;
  final Value<String> whatsAppType;
  const SavedMediaTableCompanion({
    this.id = const Value.absent(),
    this.originalDocumentUri = const Value.absent(),
    this.mediaStoreUri = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.sourceCreatedAt = const Value.absent(),
    this.whatsAppType = const Value.absent(),
  });
  SavedMediaTableCompanion.insert({
    this.id = const Value.absent(),
    required String originalDocumentUri,
    required String mediaStoreUri,
    required String relativePath,
    required String fileName,
    required String mediaType,
    required String mimeType,
    required int fileSize,
    this.durationMs = const Value.absent(),
    required DateTime savedAt,
    required DateTime sourceCreatedAt,
    this.whatsAppType = const Value.absent(),
  }) : originalDocumentUri = Value(originalDocumentUri),
       mediaStoreUri = Value(mediaStoreUri),
       relativePath = Value(relativePath),
       fileName = Value(fileName),
       mediaType = Value(mediaType),
       mimeType = Value(mimeType),
       fileSize = Value(fileSize),
       savedAt = Value(savedAt),
       sourceCreatedAt = Value(sourceCreatedAt);
  static Insertable<SavedMediaTableData> custom({
    Expression<int>? id,
    Expression<String>? originalDocumentUri,
    Expression<String>? mediaStoreUri,
    Expression<String>? relativePath,
    Expression<String>? fileName,
    Expression<String>? mediaType,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<int>? durationMs,
    Expression<DateTime>? savedAt,
    Expression<DateTime>? sourceCreatedAt,
    Expression<String>? whatsAppType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalDocumentUri != null)
        'original_document_uri': originalDocumentUri,
      if (mediaStoreUri != null) 'media_store_uri': mediaStoreUri,
      if (relativePath != null) 'relative_path': relativePath,
      if (fileName != null) 'file_name': fileName,
      if (mediaType != null) 'media_type': mediaType,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (durationMs != null) 'duration_ms': durationMs,
      if (savedAt != null) 'saved_at': savedAt,
      if (sourceCreatedAt != null) 'source_created_at': sourceCreatedAt,
      if (whatsAppType != null) 'whats_app_type': whatsAppType,
    });
  }

  SavedMediaTableCompanion copyWith({
    Value<int>? id,
    Value<String>? originalDocumentUri,
    Value<String>? mediaStoreUri,
    Value<String>? relativePath,
    Value<String>? fileName,
    Value<String>? mediaType,
    Value<String>? mimeType,
    Value<int>? fileSize,
    Value<int?>? durationMs,
    Value<DateTime>? savedAt,
    Value<DateTime>? sourceCreatedAt,
    Value<String>? whatsAppType,
  }) {
    return SavedMediaTableCompanion(
      id: id ?? this.id,
      originalDocumentUri: originalDocumentUri ?? this.originalDocumentUri,
      mediaStoreUri: mediaStoreUri ?? this.mediaStoreUri,
      relativePath: relativePath ?? this.relativePath,
      fileName: fileName ?? this.fileName,
      mediaType: mediaType ?? this.mediaType,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      durationMs: durationMs ?? this.durationMs,
      savedAt: savedAt ?? this.savedAt,
      sourceCreatedAt: sourceCreatedAt ?? this.sourceCreatedAt,
      whatsAppType: whatsAppType ?? this.whatsAppType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalDocumentUri.present) {
      map['original_document_uri'] = Variable<String>(
        originalDocumentUri.value,
      );
    }
    if (mediaStoreUri.present) {
      map['media_store_uri'] = Variable<String>(mediaStoreUri.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (sourceCreatedAt.present) {
      map['source_created_at'] = Variable<DateTime>(sourceCreatedAt.value);
    }
    if (whatsAppType.present) {
      map['whats_app_type'] = Variable<String>(whatsAppType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedMediaTableCompanion(')
          ..write('id: $id, ')
          ..write('originalDocumentUri: $originalDocumentUri, ')
          ..write('mediaStoreUri: $mediaStoreUri, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileName: $fileName, ')
          ..write('mediaType: $mediaType, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('durationMs: $durationMs, ')
          ..write('savedAt: $savedAt, ')
          ..write('sourceCreatedAt: $sourceCreatedAt, ')
          ..write('whatsAppType: $whatsAppType')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedMediaTableTable savedMediaTable = $SavedMediaTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedMediaTable];
}

typedef $$SavedMediaTableTableCreateCompanionBuilder =
    SavedMediaTableCompanion Function({
      Value<int> id,
      required String originalDocumentUri,
      required String mediaStoreUri,
      required String relativePath,
      required String fileName,
      required String mediaType,
      required String mimeType,
      required int fileSize,
      Value<int?> durationMs,
      required DateTime savedAt,
      required DateTime sourceCreatedAt,
      Value<String> whatsAppType,
    });
typedef $$SavedMediaTableTableUpdateCompanionBuilder =
    SavedMediaTableCompanion Function({
      Value<int> id,
      Value<String> originalDocumentUri,
      Value<String> mediaStoreUri,
      Value<String> relativePath,
      Value<String> fileName,
      Value<String> mediaType,
      Value<String> mimeType,
      Value<int> fileSize,
      Value<int?> durationMs,
      Value<DateTime> savedAt,
      Value<DateTime> sourceCreatedAt,
      Value<String> whatsAppType,
    });

class $$SavedMediaTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavedMediaTableTable> {
  $$SavedMediaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalDocumentUri => $composableBuilder(
    column: $table.originalDocumentUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaStoreUri => $composableBuilder(
    column: $table.mediaStoreUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sourceCreatedAt => $composableBuilder(
    column: $table.sourceCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatsAppType => $composableBuilder(
    column: $table.whatsAppType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedMediaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedMediaTableTable> {
  $$SavedMediaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalDocumentUri => $composableBuilder(
    column: $table.originalDocumentUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaStoreUri => $composableBuilder(
    column: $table.mediaStoreUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sourceCreatedAt => $composableBuilder(
    column: $table.sourceCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatsAppType => $composableBuilder(
    column: $table.whatsAppType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedMediaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedMediaTableTable> {
  $$SavedMediaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalDocumentUri => $composableBuilder(
    column: $table.originalDocumentUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaStoreUri => $composableBuilder(
    column: $table.mediaStoreUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sourceCreatedAt => $composableBuilder(
    column: $table.sourceCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatsAppType => $composableBuilder(
    column: $table.whatsAppType,
    builder: (column) => column,
  );
}

class $$SavedMediaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedMediaTableTable,
          SavedMediaTableData,
          $$SavedMediaTableTableFilterComposer,
          $$SavedMediaTableTableOrderingComposer,
          $$SavedMediaTableTableAnnotationComposer,
          $$SavedMediaTableTableCreateCompanionBuilder,
          $$SavedMediaTableTableUpdateCompanionBuilder,
          (
            SavedMediaTableData,
            BaseReferences<
              _$AppDatabase,
              $SavedMediaTableTable,
              SavedMediaTableData
            >,
          ),
          SavedMediaTableData,
          PrefetchHooks Function()
        > {
  $$SavedMediaTableTableTableManager(
    _$AppDatabase db,
    $SavedMediaTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedMediaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedMediaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedMediaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> originalDocumentUri = const Value.absent(),
                Value<String> mediaStoreUri = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<DateTime> sourceCreatedAt = const Value.absent(),
                Value<String> whatsAppType = const Value.absent(),
              }) => SavedMediaTableCompanion(
                id: id,
                originalDocumentUri: originalDocumentUri,
                mediaStoreUri: mediaStoreUri,
                relativePath: relativePath,
                fileName: fileName,
                mediaType: mediaType,
                mimeType: mimeType,
                fileSize: fileSize,
                durationMs: durationMs,
                savedAt: savedAt,
                sourceCreatedAt: sourceCreatedAt,
                whatsAppType: whatsAppType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String originalDocumentUri,
                required String mediaStoreUri,
                required String relativePath,
                required String fileName,
                required String mediaType,
                required String mimeType,
                required int fileSize,
                Value<int?> durationMs = const Value.absent(),
                required DateTime savedAt,
                required DateTime sourceCreatedAt,
                Value<String> whatsAppType = const Value.absent(),
              }) => SavedMediaTableCompanion.insert(
                id: id,
                originalDocumentUri: originalDocumentUri,
                mediaStoreUri: mediaStoreUri,
                relativePath: relativePath,
                fileName: fileName,
                mediaType: mediaType,
                mimeType: mimeType,
                fileSize: fileSize,
                durationMs: durationMs,
                savedAt: savedAt,
                sourceCreatedAt: sourceCreatedAt,
                whatsAppType: whatsAppType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedMediaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedMediaTableTable,
      SavedMediaTableData,
      $$SavedMediaTableTableFilterComposer,
      $$SavedMediaTableTableOrderingComposer,
      $$SavedMediaTableTableAnnotationComposer,
      $$SavedMediaTableTableCreateCompanionBuilder,
      $$SavedMediaTableTableUpdateCompanionBuilder,
      (
        SavedMediaTableData,
        BaseReferences<
          _$AppDatabase,
          $SavedMediaTableTable,
          SavedMediaTableData
        >,
      ),
      SavedMediaTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedMediaTableTableTableManager get savedMediaTable =>
      $$SavedMediaTableTableTableManager(_db, _db.savedMediaTable);
}
