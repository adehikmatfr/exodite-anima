// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_database.dart';

// ignore_for_file: type=lint
class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    day,
    body,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final int id;

  /// A random identifier that never changes and is never reused. It travels in
  /// exports so an import can tell which entries are already present (ADR-003).
  final String uid;
  final String day;
  final String body;
  final int createdAtMs;
  final int updatedAtMs;
  const Entry({
    required this.id,
    required this.uid,
    required this.day,
    required this.body,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['day'] = Variable<String>(day);
    map['body'] = Variable<String>(body);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      uid: Value(uid),
      day: Value(day),
      body: Value(body),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      day: serializer.fromJson<String>(json['day']),
      body: serializer.fromJson<String>(json['body']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'day': serializer.toJson<String>(day),
      'body': serializer.toJson<String>(body),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  Entry copyWith({
    int? id,
    String? uid,
    String? day,
    String? body,
    int? createdAtMs,
    int? updatedAtMs,
  }) => Entry(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    day: day ?? this.day,
    body: body ?? this.body,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      day: data.day.present ? data.day.value : this.day,
      body: data.body.present ? data.body.value : this.body,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('day: $day, ')
          ..write('body: $body, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uid, day, body, createdAtMs, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.day == this.day &&
          other.body == this.body &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> day;
  final Value<String> body;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.day = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String day,
    required String body,
    required int createdAtMs,
    required int updatedAtMs,
  }) : uid = Value(uid),
       day = Value(day),
       body = Value(body),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<Entry> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? day,
    Expression<String>? body,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (day != null) 'day': day,
      if (body != null) 'body': body,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String>? day,
    Value<String>? body,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      day: day ?? this.day,
      body: body ?? this.body,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('day: $day, ')
          ..write('body: $body, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, Draft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, entryId, day, body, updatedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Draft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Draft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Draft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      ),
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class Draft extends DataClass implements Insertable<Draft> {
  final int id;
  final int? entryId;
  final String day;
  final String body;
  final int updatedAtMs;
  const Draft({
    required this.id,
    this.entryId,
    required this.day,
    required this.body,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || entryId != null) {
      map['entry_id'] = Variable<int>(entryId);
    }
    map['day'] = Variable<String>(day);
    map['body'] = Variable<String>(body);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      entryId: entryId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryId),
      day: Value(day),
      body: Value(body),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory Draft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Draft(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int?>(json['entryId']),
      day: serializer.fromJson<String>(json['day']),
      body: serializer.fromJson<String>(json['body']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int?>(entryId),
      'day': serializer.toJson<String>(day),
      'body': serializer.toJson<String>(body),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  Draft copyWith({
    int? id,
    Value<int?> entryId = const Value.absent(),
    String? day,
    String? body,
    int? updatedAtMs,
  }) => Draft(
    id: id ?? this.id,
    entryId: entryId.present ? entryId.value : this.entryId,
    day: day ?? this.day,
    body: body ?? this.body,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  Draft copyWithCompanion(DraftsCompanion data) {
    return Draft(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      day: data.day.present ? data.day.value : this.day,
      body: data.body.present ? data.body.value : this.body,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Draft(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('day: $day, ')
          ..write('body: $body, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entryId, day, body, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Draft &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.day == this.day &&
          other.body == this.body &&
          other.updatedAtMs == this.updatedAtMs);
}

class DraftsCompanion extends UpdateCompanion<Draft> {
  final Value<int> id;
  final Value<int?> entryId;
  final Value<String> day;
  final Value<String> body;
  final Value<int> updatedAtMs;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.day = const Value.absent(),
    this.body = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  DraftsCompanion.insert({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    required String day,
    required String body,
    required int updatedAtMs,
  }) : day = Value(day),
       body = Value(body),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<Draft> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? day,
    Expression<String>? body,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (day != null) 'day': day,
      if (body != null) 'body': body,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  DraftsCompanion copyWith({
    Value<int>? id,
    Value<int?>? entryId,
    Value<String>? day,
    Value<String>? body,
    Value<int>? updatedAtMs,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      day: day ?? this.day,
      body: body ?? this.body,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('day: $day, ')
          ..write('body: $body, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $AppValuesTable extends AppValues
    with TableInfo<$AppValuesTable, AppValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AppValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppValue(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppValuesTable createAlias(String alias) {
    return $AppValuesTable(attachedDatabase, alias);
  }
}

class AppValue extends DataClass implements Insertable<AppValue> {
  final String name;
  final String value;
  const AppValue({required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppValuesCompanion toCompanion(bool nullToAbsent) {
    return AppValuesCompanion(name: Value(name), value: Value(value));
  }

  factory AppValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppValue(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  AppValue copyWith({String? name, String? value}) =>
      AppValue(name: name ?? this.name, value: value ?? this.value);
  AppValue copyWithCompanion(AppValuesCompanion data) {
    return AppValue(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppValue(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppValue &&
          other.name == this.name &&
          other.value == this.value);
}

class AppValuesCompanion extends UpdateCompanion<AppValue> {
  final Value<String> name;
  final Value<String> value;
  final Value<int> rowid;
  const AppValuesCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppValuesCompanion.insert({
    required String name,
    required String value,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       value = Value(value);
  static Insertable<AppValue> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppValuesCompanion copyWith({
    Value<String>? name,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppValuesCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppValuesCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$JournalDatabase extends GeneratedDatabase {
  _$JournalDatabase(QueryExecutor e) : super(e);
  $JournalDatabaseManager get managers => $JournalDatabaseManager(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $AppValuesTable appValues = $AppValuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    entries,
    drafts,
    appValues,
  ];
}

typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      required String uid,
      required String day,
      required String body,
      required int createdAtMs,
      required int updatedAtMs,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String> day,
      Value<String> body,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
    });

class $$EntriesTableFilterComposer
    extends Composer<_$JournalDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
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

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer
    extends Composer<_$JournalDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
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

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$JournalDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$JournalDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, BaseReferences<_$JournalDatabase, $EntriesTable, Entry>),
          Entry,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$JournalDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                uid: uid,
                day: day,
                body: body,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uid,
                required String day,
                required String body,
                required int createdAtMs,
                required int updatedAtMs,
              }) => EntriesCompanion.insert(
                id: id,
                uid: uid,
                day: day,
                body: body,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, Entry>(table),
                  BaseReferences<_$JournalDatabase, $EntriesTable, Entry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$JournalDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, BaseReferences<_$JournalDatabase, $EntriesTable, Entry>),
      Entry,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableCreateCompanionBuilder =
    DraftsCompanion Function({
      Value<int> id,
      Value<int?> entryId,
      required String day,
      required String body,
      required int updatedAtMs,
    });
typedef $$DraftsTableUpdateCompanionBuilder =
    DraftsCompanion Function({
      Value<int> id,
      Value<int?> entryId,
      Value<String> day,
      Value<String> body,
      Value<int> updatedAtMs,
    });

class $$DraftsTableFilterComposer
    extends Composer<_$JournalDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
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

  ColumnFilters<int> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftsTableOrderingComposer
    extends Composer<_$JournalDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
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

  ColumnOrderings<int> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$JournalDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$JournalDatabase,
          $DraftsTable,
          Draft,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (Draft, BaseReferences<_$JournalDatabase, $DraftsTable, Draft>),
          Draft,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableManager(_$JournalDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> entryId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                entryId: entryId,
                day: day,
                body: body,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> entryId = const Value.absent(),
                required String day,
                required String body,
                required int updatedAtMs,
              }) => DraftsCompanion.insert(
                id: id,
                entryId: entryId,
                day: day,
                body: body,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DraftsTable, Draft>(table),
                  BaseReferences<_$JournalDatabase, $DraftsTable, Draft>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$JournalDatabase,
      $DraftsTable,
      Draft,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (Draft, BaseReferences<_$JournalDatabase, $DraftsTable, Draft>),
      Draft,
      PrefetchHooks Function()
    >;
typedef $$AppValuesTableCreateCompanionBuilder =
    AppValuesCompanion Function({
      required String name,
      required String value,
      Value<int> rowid,
    });
typedef $$AppValuesTableUpdateCompanionBuilder =
    AppValuesCompanion Function({
      Value<String> name,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppValuesTableFilterComposer
    extends Composer<_$JournalDatabase, $AppValuesTable> {
  $$AppValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppValuesTableOrderingComposer
    extends Composer<_$JournalDatabase, $AppValuesTable> {
  $$AppValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppValuesTableAnnotationComposer
    extends Composer<_$JournalDatabase, $AppValuesTable> {
  $$AppValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppValuesTableTableManager
    extends
        RootTableManager<
          _$JournalDatabase,
          $AppValuesTable,
          AppValue,
          $$AppValuesTableFilterComposer,
          $$AppValuesTableOrderingComposer,
          $$AppValuesTableAnnotationComposer,
          $$AppValuesTableCreateCompanionBuilder,
          $$AppValuesTableUpdateCompanionBuilder,
          (
            AppValue,
            BaseReferences<_$JournalDatabase, $AppValuesTable, AppValue>,
          ),
          AppValue,
          PrefetchHooks Function()
        > {
  $$AppValuesTableTableManager(_$JournalDatabase db, $AppValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppValuesCompanion(name: name, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppValuesCompanion.insert(
                name: name,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppValuesTable, AppValue>(table),
                  BaseReferences<_$JournalDatabase, $AppValuesTable, AppValue>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$JournalDatabase,
      $AppValuesTable,
      AppValue,
      $$AppValuesTableFilterComposer,
      $$AppValuesTableOrderingComposer,
      $$AppValuesTableAnnotationComposer,
      $$AppValuesTableCreateCompanionBuilder,
      $$AppValuesTableUpdateCompanionBuilder,
      (AppValue, BaseReferences<_$JournalDatabase, $AppValuesTable, AppValue>),
      AppValue,
      PrefetchHooks Function()
    >;

class $JournalDatabaseManager {
  final _$JournalDatabase _db;
  $JournalDatabaseManager(this._db);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
  $$AppValuesTableTableManager get appValues =>
      $$AppValuesTableTableManager(_db, _db.appValues);
}
