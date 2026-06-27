// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $CedulasTable extends Cedulas with TableInfo<$CedulasTable, Cedula> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CedulasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _informanteNombreMeta = const VerificationMeta(
    'informanteNombre',
  );
  @override
  late final GeneratedColumn<String> informanteNombre = GeneratedColumn<String>(
    'informante_nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familiaDataMeta = const VerificationMeta(
    'familiaData',
  );
  @override
  late final GeneratedColumn<String> familiaData = GeneratedColumn<String>(
    'familia_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    createdAt,
    informanteNombre,
    familiaData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cedulas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cedula> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('informante_nombre')) {
      context.handle(
        _informanteNombreMeta,
        informanteNombre.isAcceptableOrUnknown(
          data['informante_nombre']!,
          _informanteNombreMeta,
        ),
      );
    }
    if (data.containsKey('familia_data')) {
      context.handle(
        _familiaDataMeta,
        familiaData.isAcceptableOrUnknown(
          data['familia_data']!,
          _familiaDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_familiaDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cedula map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cedula(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      informanteNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}informante_nombre'],
      ),
      familiaData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}familia_data'],
      )!,
    );
  }

  @override
  $CedulasTable createAlias(String alias) {
    return $CedulasTable(attachedDatabase, alias);
  }
}

class Cedula extends DataClass implements Insertable<Cedula> {
  final int id;
  final int syncStatus;
  final DateTime createdAt;
  final String? informanteNombre;
  final String familiaData;
  const Cedula({
    required this.id,
    required this.syncStatus,
    required this.createdAt,
    this.informanteNombre,
    required this.familiaData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_status'] = Variable<int>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || informanteNombre != null) {
      map['informante_nombre'] = Variable<String>(informanteNombre);
    }
    map['familia_data'] = Variable<String>(familiaData);
    return map;
  }

  CedulasCompanion toCompanion(bool nullToAbsent) {
    return CedulasCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      informanteNombre: informanteNombre == null && nullToAbsent
          ? const Value.absent()
          : Value(informanteNombre),
      familiaData: Value(familiaData),
    );
  }

  factory Cedula.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cedula(
      id: serializer.fromJson<int>(json['id']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      informanteNombre: serializer.fromJson<String?>(json['informanteNombre']),
      familiaData: serializer.fromJson<String>(json['familiaData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'informanteNombre': serializer.toJson<String?>(informanteNombre),
      'familiaData': serializer.toJson<String>(familiaData),
    };
  }

  Cedula copyWith({
    int? id,
    int? syncStatus,
    DateTime? createdAt,
    Value<String?> informanteNombre = const Value.absent(),
    String? familiaData,
  }) => Cedula(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    informanteNombre: informanteNombre.present
        ? informanteNombre.value
        : this.informanteNombre,
    familiaData: familiaData ?? this.familiaData,
  );
  Cedula copyWithCompanion(CedulasCompanion data) {
    return Cedula(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      informanteNombre: data.informanteNombre.present
          ? data.informanteNombre.value
          : this.informanteNombre,
      familiaData: data.familiaData.present
          ? data.familiaData.value
          : this.familiaData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cedula(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('informanteNombre: $informanteNombre, ')
          ..write('familiaData: $familiaData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, syncStatus, createdAt, informanteNombre, familiaData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cedula &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.informanteNombre == this.informanteNombre &&
          other.familiaData == this.familiaData);
}

class CedulasCompanion extends UpdateCompanion<Cedula> {
  final Value<int> id;
  final Value<int> syncStatus;
  final Value<DateTime> createdAt;
  final Value<String?> informanteNombre;
  final Value<String> familiaData;
  const CedulasCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.informanteNombre = const Value.absent(),
    this.familiaData = const Value.absent(),
  });
  CedulasCompanion.insert({
    this.id = const Value.absent(),
    required int syncStatus,
    required DateTime createdAt,
    this.informanteNombre = const Value.absent(),
    required String familiaData,
  }) : syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       familiaData = Value(familiaData);
  static Insertable<Cedula> custom({
    Expression<int>? id,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<String>? informanteNombre,
    Expression<String>? familiaData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (informanteNombre != null) 'informante_nombre': informanteNombre,
      if (familiaData != null) 'familia_data': familiaData,
    });
  }

  CedulasCompanion copyWith({
    Value<int>? id,
    Value<int>? syncStatus,
    Value<DateTime>? createdAt,
    Value<String?>? informanteNombre,
    Value<String>? familiaData,
  }) {
    return CedulasCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      informanteNombre: informanteNombre ?? this.informanteNombre,
      familiaData: familiaData ?? this.familiaData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (informanteNombre.present) {
      map['informante_nombre'] = Variable<String>(informanteNombre.value);
    }
    if (familiaData.present) {
      map['familia_data'] = Variable<String>(familiaData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CedulasCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('informanteNombre: $informanteNombre, ')
          ..write('familiaData: $familiaData')
          ..write(')'))
        .toString();
  }
}

class $ViviendasTable extends Viviendas
    with TableInfo<$ViviendasTable, Vivienda> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViviendasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cedulaIdMeta = const VerificationMeta(
    'cedulaId',
  );
  @override
  late final GeneratedColumn<int> cedulaId = GeneratedColumn<int>(
    'cedula_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cedulas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _viviendaDataMeta = const VerificationMeta(
    'viviendaData',
  );
  @override
  late final GeneratedColumn<String> viviendaData = GeneratedColumn<String>(
    'vivienda_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cedulaId, viviendaData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'viviendas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vivienda> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cedula_id')) {
      context.handle(
        _cedulaIdMeta,
        cedulaId.isAcceptableOrUnknown(data['cedula_id']!, _cedulaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cedulaIdMeta);
    }
    if (data.containsKey('vivienda_data')) {
      context.handle(
        _viviendaDataMeta,
        viviendaData.isAcceptableOrUnknown(
          data['vivienda_data']!,
          _viviendaDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_viviendaDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vivienda map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vivienda(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cedulaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cedula_id'],
      )!,
      viviendaData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vivienda_data'],
      )!,
    );
  }

  @override
  $ViviendasTable createAlias(String alias) {
    return $ViviendasTable(attachedDatabase, alias);
  }
}

class Vivienda extends DataClass implements Insertable<Vivienda> {
  final int id;
  final int cedulaId;
  final String viviendaData;
  const Vivienda({
    required this.id,
    required this.cedulaId,
    required this.viviendaData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cedula_id'] = Variable<int>(cedulaId);
    map['vivienda_data'] = Variable<String>(viviendaData);
    return map;
  }

  ViviendasCompanion toCompanion(bool nullToAbsent) {
    return ViviendasCompanion(
      id: Value(id),
      cedulaId: Value(cedulaId),
      viviendaData: Value(viviendaData),
    );
  }

  factory Vivienda.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vivienda(
      id: serializer.fromJson<int>(json['id']),
      cedulaId: serializer.fromJson<int>(json['cedulaId']),
      viviendaData: serializer.fromJson<String>(json['viviendaData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cedulaId': serializer.toJson<int>(cedulaId),
      'viviendaData': serializer.toJson<String>(viviendaData),
    };
  }

  Vivienda copyWith({int? id, int? cedulaId, String? viviendaData}) => Vivienda(
    id: id ?? this.id,
    cedulaId: cedulaId ?? this.cedulaId,
    viviendaData: viviendaData ?? this.viviendaData,
  );
  Vivienda copyWithCompanion(ViviendasCompanion data) {
    return Vivienda(
      id: data.id.present ? data.id.value : this.id,
      cedulaId: data.cedulaId.present ? data.cedulaId.value : this.cedulaId,
      viviendaData: data.viviendaData.present
          ? data.viviendaData.value
          : this.viviendaData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vivienda(')
          ..write('id: $id, ')
          ..write('cedulaId: $cedulaId, ')
          ..write('viviendaData: $viviendaData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cedulaId, viviendaData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vivienda &&
          other.id == this.id &&
          other.cedulaId == this.cedulaId &&
          other.viviendaData == this.viviendaData);
}

class ViviendasCompanion extends UpdateCompanion<Vivienda> {
  final Value<int> id;
  final Value<int> cedulaId;
  final Value<String> viviendaData;
  const ViviendasCompanion({
    this.id = const Value.absent(),
    this.cedulaId = const Value.absent(),
    this.viviendaData = const Value.absent(),
  });
  ViviendasCompanion.insert({
    this.id = const Value.absent(),
    required int cedulaId,
    required String viviendaData,
  }) : cedulaId = Value(cedulaId),
       viviendaData = Value(viviendaData);
  static Insertable<Vivienda> custom({
    Expression<int>? id,
    Expression<int>? cedulaId,
    Expression<String>? viviendaData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cedulaId != null) 'cedula_id': cedulaId,
      if (viviendaData != null) 'vivienda_data': viviendaData,
    });
  }

  ViviendasCompanion copyWith({
    Value<int>? id,
    Value<int>? cedulaId,
    Value<String>? viviendaData,
  }) {
    return ViviendasCompanion(
      id: id ?? this.id,
      cedulaId: cedulaId ?? this.cedulaId,
      viviendaData: viviendaData ?? this.viviendaData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cedulaId.present) {
      map['cedula_id'] = Variable<int>(cedulaId.value);
    }
    if (viviendaData.present) {
      map['vivienda_data'] = Variable<String>(viviendaData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViviendasCompanion(')
          ..write('id: $id, ')
          ..write('cedulaId: $cedulaId, ')
          ..write('viviendaData: $viviendaData')
          ..write(')'))
        .toString();
  }
}

class $VacunasTable extends Vacunas with TableInfo<$VacunasTable, Vacuna> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VacunasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cedulaIdMeta = const VerificationMeta(
    'cedulaId',
  );
  @override
  late final GeneratedColumn<int> cedulaId = GeneratedColumn<int>(
    'cedula_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cedulas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _vacunaDataMeta = const VerificationMeta(
    'vacunaData',
  );
  @override
  late final GeneratedColumn<String> vacunaData = GeneratedColumn<String>(
    'vacuna_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cedulaId, vacunaData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vacunas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vacuna> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cedula_id')) {
      context.handle(
        _cedulaIdMeta,
        cedulaId.isAcceptableOrUnknown(data['cedula_id']!, _cedulaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cedulaIdMeta);
    }
    if (data.containsKey('vacuna_data')) {
      context.handle(
        _vacunaDataMeta,
        vacunaData.isAcceptableOrUnknown(data['vacuna_data']!, _vacunaDataMeta),
      );
    } else if (isInserting) {
      context.missing(_vacunaDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vacuna map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vacuna(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cedulaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cedula_id'],
      )!,
      vacunaData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vacuna_data'],
      )!,
    );
  }

  @override
  $VacunasTable createAlias(String alias) {
    return $VacunasTable(attachedDatabase, alias);
  }
}

class Vacuna extends DataClass implements Insertable<Vacuna> {
  final int id;
  final int cedulaId;
  final String vacunaData;
  const Vacuna({
    required this.id,
    required this.cedulaId,
    required this.vacunaData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cedula_id'] = Variable<int>(cedulaId);
    map['vacuna_data'] = Variable<String>(vacunaData);
    return map;
  }

  VacunasCompanion toCompanion(bool nullToAbsent) {
    return VacunasCompanion(
      id: Value(id),
      cedulaId: Value(cedulaId),
      vacunaData: Value(vacunaData),
    );
  }

  factory Vacuna.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vacuna(
      id: serializer.fromJson<int>(json['id']),
      cedulaId: serializer.fromJson<int>(json['cedulaId']),
      vacunaData: serializer.fromJson<String>(json['vacunaData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cedulaId': serializer.toJson<int>(cedulaId),
      'vacunaData': serializer.toJson<String>(vacunaData),
    };
  }

  Vacuna copyWith({int? id, int? cedulaId, String? vacunaData}) => Vacuna(
    id: id ?? this.id,
    cedulaId: cedulaId ?? this.cedulaId,
    vacunaData: vacunaData ?? this.vacunaData,
  );
  Vacuna copyWithCompanion(VacunasCompanion data) {
    return Vacuna(
      id: data.id.present ? data.id.value : this.id,
      cedulaId: data.cedulaId.present ? data.cedulaId.value : this.cedulaId,
      vacunaData: data.vacunaData.present
          ? data.vacunaData.value
          : this.vacunaData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vacuna(')
          ..write('id: $id, ')
          ..write('cedulaId: $cedulaId, ')
          ..write('vacunaData: $vacunaData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cedulaId, vacunaData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vacuna &&
          other.id == this.id &&
          other.cedulaId == this.cedulaId &&
          other.vacunaData == this.vacunaData);
}

class VacunasCompanion extends UpdateCompanion<Vacuna> {
  final Value<int> id;
  final Value<int> cedulaId;
  final Value<String> vacunaData;
  const VacunasCompanion({
    this.id = const Value.absent(),
    this.cedulaId = const Value.absent(),
    this.vacunaData = const Value.absent(),
  });
  VacunasCompanion.insert({
    this.id = const Value.absent(),
    required int cedulaId,
    required String vacunaData,
  }) : cedulaId = Value(cedulaId),
       vacunaData = Value(vacunaData);
  static Insertable<Vacuna> custom({
    Expression<int>? id,
    Expression<int>? cedulaId,
    Expression<String>? vacunaData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cedulaId != null) 'cedula_id': cedulaId,
      if (vacunaData != null) 'vacuna_data': vacunaData,
    });
  }

  VacunasCompanion copyWith({
    Value<int>? id,
    Value<int>? cedulaId,
    Value<String>? vacunaData,
  }) {
    return VacunasCompanion(
      id: id ?? this.id,
      cedulaId: cedulaId ?? this.cedulaId,
      vacunaData: vacunaData ?? this.vacunaData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cedulaId.present) {
      map['cedula_id'] = Variable<int>(cedulaId.value);
    }
    if (vacunaData.present) {
      map['vacuna_data'] = Variable<String>(vacunaData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VacunasCompanion(')
          ..write('id: $id, ')
          ..write('cedulaId: $cedulaId, ')
          ..write('vacunaData: $vacunaData')
          ..write(')'))
        .toString();
  }
}

class $IntegrantesTable extends Integrantes
    with TableInfo<$IntegrantesTable, Integrante> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntegrantesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cedulaIdMeta = const VerificationMeta(
    'cedulaId',
  );
  @override
  late final GeneratedColumn<int> cedulaId = GeneratedColumn<int>(
    'cedula_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cedulas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _integranteDataMeta = const VerificationMeta(
    'integranteData',
  );
  @override
  late final GeneratedColumn<String> integranteData = GeneratedColumn<String>(
    'integrante_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cedulaId, integranteData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'integrantes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Integrante> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cedula_id')) {
      context.handle(
        _cedulaIdMeta,
        cedulaId.isAcceptableOrUnknown(data['cedula_id']!, _cedulaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cedulaIdMeta);
    }
    if (data.containsKey('integrante_data')) {
      context.handle(
        _integranteDataMeta,
        integranteData.isAcceptableOrUnknown(
          data['integrante_data']!,
          _integranteDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_integranteDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Integrante map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Integrante(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cedulaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cedula_id'],
      )!,
      integranteData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}integrante_data'],
      )!,
    );
  }

  @override
  $IntegrantesTable createAlias(String alias) {
    return $IntegrantesTable(attachedDatabase, alias);
  }
}

class Integrante extends DataClass implements Insertable<Integrante> {
  final int id;
  final int cedulaId;
  final String integranteData;
  const Integrante({
    required this.id,
    required this.cedulaId,
    required this.integranteData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cedula_id'] = Variable<int>(cedulaId);
    map['integrante_data'] = Variable<String>(integranteData);
    return map;
  }

  IntegrantesCompanion toCompanion(bool nullToAbsent) {
    return IntegrantesCompanion(
      id: Value(id),
      cedulaId: Value(cedulaId),
      integranteData: Value(integranteData),
    );
  }

  factory Integrante.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Integrante(
      id: serializer.fromJson<int>(json['id']),
      cedulaId: serializer.fromJson<int>(json['cedulaId']),
      integranteData: serializer.fromJson<String>(json['integranteData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cedulaId': serializer.toJson<int>(cedulaId),
      'integranteData': serializer.toJson<String>(integranteData),
    };
  }

  Integrante copyWith({int? id, int? cedulaId, String? integranteData}) =>
      Integrante(
        id: id ?? this.id,
        cedulaId: cedulaId ?? this.cedulaId,
        integranteData: integranteData ?? this.integranteData,
      );
  Integrante copyWithCompanion(IntegrantesCompanion data) {
    return Integrante(
      id: data.id.present ? data.id.value : this.id,
      cedulaId: data.cedulaId.present ? data.cedulaId.value : this.cedulaId,
      integranteData: data.integranteData.present
          ? data.integranteData.value
          : this.integranteData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Integrante(')
          ..write('id: $id, ')
          ..write('cedulaId: $cedulaId, ')
          ..write('integranteData: $integranteData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cedulaId, integranteData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Integrante &&
          other.id == this.id &&
          other.cedulaId == this.cedulaId &&
          other.integranteData == this.integranteData);
}

class IntegrantesCompanion extends UpdateCompanion<Integrante> {
  final Value<int> id;
  final Value<int> cedulaId;
  final Value<String> integranteData;
  const IntegrantesCompanion({
    this.id = const Value.absent(),
    this.cedulaId = const Value.absent(),
    this.integranteData = const Value.absent(),
  });
  IntegrantesCompanion.insert({
    this.id = const Value.absent(),
    required int cedulaId,
    required String integranteData,
  }) : cedulaId = Value(cedulaId),
       integranteData = Value(integranteData);
  static Insertable<Integrante> custom({
    Expression<int>? id,
    Expression<int>? cedulaId,
    Expression<String>? integranteData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cedulaId != null) 'cedula_id': cedulaId,
      if (integranteData != null) 'integrante_data': integranteData,
    });
  }

  IntegrantesCompanion copyWith({
    Value<int>? id,
    Value<int>? cedulaId,
    Value<String>? integranteData,
  }) {
    return IntegrantesCompanion(
      id: id ?? this.id,
      cedulaId: cedulaId ?? this.cedulaId,
      integranteData: integranteData ?? this.integranteData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cedulaId.present) {
      map['cedula_id'] = Variable<int>(cedulaId.value);
    }
    if (integranteData.present) {
      map['integrante_data'] = Variable<String>(integranteData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntegrantesCompanion(')
          ..write('id: $id, ')
          ..write('cedulaId: $cedulaId, ')
          ..write('integranteData: $integranteData')
          ..write(')'))
        .toString();
  }
}

class $CatalogosLocalTable extends CatalogosLocal
    with TableInfo<$CatalogosLocalTable, CatalogosLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogosLocalTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonListMeta = const VerificationMeta(
    'jsonList',
  );
  @override
  late final GeneratedColumn<String> jsonList = GeneratedColumn<String>(
    'json_list',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [id, tipo, jsonList, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalogos_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogosLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('json_list')) {
      context.handle(
        _jsonListMeta,
        jsonList.isAcceptableOrUnknown(data['json_list']!, _jsonListMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonListMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogosLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogosLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      jsonList: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_list'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CatalogosLocalTable createAlias(String alias) {
    return $CatalogosLocalTable(attachedDatabase, alias);
  }
}

class CatalogosLocalData extends DataClass
    implements Insertable<CatalogosLocalData> {
  final int id;
  final String tipo;
  final String jsonList;
  final DateTime updatedAt;
  const CatalogosLocalData({
    required this.id,
    required this.tipo,
    required this.jsonList,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo'] = Variable<String>(tipo);
    map['json_list'] = Variable<String>(jsonList);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CatalogosLocalCompanion toCompanion(bool nullToAbsent) {
    return CatalogosLocalCompanion(
      id: Value(id),
      tipo: Value(tipo),
      jsonList: Value(jsonList),
      updatedAt: Value(updatedAt),
    );
  }

  factory CatalogosLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogosLocalData(
      id: serializer.fromJson<int>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      jsonList: serializer.fromJson<String>(json['jsonList']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipo': serializer.toJson<String>(tipo),
      'jsonList': serializer.toJson<String>(jsonList),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CatalogosLocalData copyWith({
    int? id,
    String? tipo,
    String? jsonList,
    DateTime? updatedAt,
  }) => CatalogosLocalData(
    id: id ?? this.id,
    tipo: tipo ?? this.tipo,
    jsonList: jsonList ?? this.jsonList,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CatalogosLocalData copyWithCompanion(CatalogosLocalCompanion data) {
    return CatalogosLocalData(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      jsonList: data.jsonList.present ? data.jsonList.value : this.jsonList,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogosLocalData(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('jsonList: $jsonList, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tipo, jsonList, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogosLocalData &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.jsonList == this.jsonList &&
          other.updatedAt == this.updatedAt);
}

class CatalogosLocalCompanion extends UpdateCompanion<CatalogosLocalData> {
  final Value<int> id;
  final Value<String> tipo;
  final Value<String> jsonList;
  final Value<DateTime> updatedAt;
  const CatalogosLocalCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.jsonList = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CatalogosLocalCompanion.insert({
    this.id = const Value.absent(),
    required String tipo,
    required String jsonList,
    required DateTime updatedAt,
  }) : tipo = Value(tipo),
       jsonList = Value(jsonList),
       updatedAt = Value(updatedAt);
  static Insertable<CatalogosLocalData> custom({
    Expression<int>? id,
    Expression<String>? tipo,
    Expression<String>? jsonList,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (jsonList != null) 'json_list': jsonList,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CatalogosLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? tipo,
    Value<String>? jsonList,
    Value<DateTime>? updatedAt,
  }) {
    return CatalogosLocalCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      jsonList: jsonList ?? this.jsonList,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (jsonList.present) {
      map['json_list'] = Variable<String>(jsonList.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogosLocalCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('jsonList: $jsonList, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CedulasTable cedulas = $CedulasTable(this);
  late final $ViviendasTable viviendas = $ViviendasTable(this);
  late final $VacunasTable vacunas = $VacunasTable(this);
  late final $IntegrantesTable integrantes = $IntegrantesTable(this);
  late final $CatalogosLocalTable catalogosLocal = $CatalogosLocalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cedulas,
    viviendas,
    vacunas,
    integrantes,
    catalogosLocal,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cedulas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('viviendas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cedulas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vacunas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cedulas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('integrantes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CedulasTableCreateCompanionBuilder =
    CedulasCompanion Function({
      Value<int> id,
      required int syncStatus,
      required DateTime createdAt,
      Value<String?> informanteNombre,
      required String familiaData,
    });
typedef $$CedulasTableUpdateCompanionBuilder =
    CedulasCompanion Function({
      Value<int> id,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
      Value<String?> informanteNombre,
      Value<String> familiaData,
    });

final class $$CedulasTableReferences
    extends BaseReferences<_$AppDatabase, $CedulasTable, Cedula> {
  $$CedulasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ViviendasTable, List<Vivienda>>
  _viviendasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.viviendas,
    aliasName: 'cedulas__id__viviendas__cedula_id',
  );

  $$ViviendasTableProcessedTableManager get viviendasRefs {
    final manager = $$ViviendasTableTableManager(
      $_db,
      $_db.viviendas,
    ).filter((f) => f.cedulaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_viviendasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VacunasTable, List<Vacuna>> _vacunasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vacunas,
    aliasName: 'cedulas__id__vacunas__cedula_id',
  );

  $$VacunasTableProcessedTableManager get vacunasRefs {
    final manager = $$VacunasTableTableManager(
      $_db,
      $_db.vacunas,
    ).filter((f) => f.cedulaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vacunasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntegrantesTable, List<Integrante>>
  _integrantesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.integrantes,
    aliasName: 'cedulas__id__integrantes__cedula_id',
  );

  $$IntegrantesTableProcessedTableManager get integrantesRefs {
    final manager = $$IntegrantesTableTableManager(
      $_db,
      $_db.integrantes,
    ).filter((f) => f.cedulaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_integrantesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CedulasTableFilterComposer
    extends Composer<_$AppDatabase, $CedulasTable> {
  $$CedulasTableFilterComposer({
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

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get informanteNombre => $composableBuilder(
    column: $table.informanteNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familiaData => $composableBuilder(
    column: $table.familiaData,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> viviendasRefs(
    Expression<bool> Function($$ViviendasTableFilterComposer f) f,
  ) {
    final $$ViviendasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.viviendas,
      getReferencedColumn: (t) => t.cedulaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViviendasTableFilterComposer(
            $db: $db,
            $table: $db.viviendas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vacunasRefs(
    Expression<bool> Function($$VacunasTableFilterComposer f) f,
  ) {
    final $$VacunasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vacunas,
      getReferencedColumn: (t) => t.cedulaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VacunasTableFilterComposer(
            $db: $db,
            $table: $db.vacunas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> integrantesRefs(
    Expression<bool> Function($$IntegrantesTableFilterComposer f) f,
  ) {
    final $$IntegrantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.integrantes,
      getReferencedColumn: (t) => t.cedulaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntegrantesTableFilterComposer(
            $db: $db,
            $table: $db.integrantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CedulasTableOrderingComposer
    extends Composer<_$AppDatabase, $CedulasTable> {
  $$CedulasTableOrderingComposer({
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

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get informanteNombre => $composableBuilder(
    column: $table.informanteNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familiaData => $composableBuilder(
    column: $table.familiaData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CedulasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CedulasTable> {
  $$CedulasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get informanteNombre => $composableBuilder(
    column: $table.informanteNombre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familiaData => $composableBuilder(
    column: $table.familiaData,
    builder: (column) => column,
  );

  Expression<T> viviendasRefs<T extends Object>(
    Expression<T> Function($$ViviendasTableAnnotationComposer a) f,
  ) {
    final $$ViviendasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.viviendas,
      getReferencedColumn: (t) => t.cedulaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViviendasTableAnnotationComposer(
            $db: $db,
            $table: $db.viviendas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vacunasRefs<T extends Object>(
    Expression<T> Function($$VacunasTableAnnotationComposer a) f,
  ) {
    final $$VacunasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vacunas,
      getReferencedColumn: (t) => t.cedulaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VacunasTableAnnotationComposer(
            $db: $db,
            $table: $db.vacunas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> integrantesRefs<T extends Object>(
    Expression<T> Function($$IntegrantesTableAnnotationComposer a) f,
  ) {
    final $$IntegrantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.integrantes,
      getReferencedColumn: (t) => t.cedulaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntegrantesTableAnnotationComposer(
            $db: $db,
            $table: $db.integrantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CedulasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CedulasTable,
          Cedula,
          $$CedulasTableFilterComposer,
          $$CedulasTableOrderingComposer,
          $$CedulasTableAnnotationComposer,
          $$CedulasTableCreateCompanionBuilder,
          $$CedulasTableUpdateCompanionBuilder,
          (Cedula, $$CedulasTableReferences),
          Cedula,
          PrefetchHooks Function({
            bool viviendasRefs,
            bool vacunasRefs,
            bool integrantesRefs,
          })
        > {
  $$CedulasTableTableManager(_$AppDatabase db, $CedulasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CedulasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CedulasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CedulasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> informanteNombre = const Value.absent(),
                Value<String> familiaData = const Value.absent(),
              }) => CedulasCompanion(
                id: id,
                syncStatus: syncStatus,
                createdAt: createdAt,
                informanteNombre: informanteNombre,
                familiaData: familiaData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int syncStatus,
                required DateTime createdAt,
                Value<String?> informanteNombre = const Value.absent(),
                required String familiaData,
              }) => CedulasCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                createdAt: createdAt,
                informanteNombre: informanteNombre,
                familiaData: familiaData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CedulasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                viviendasRefs = false,
                vacunasRefs = false,
                integrantesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (viviendasRefs) db.viviendas,
                    if (vacunasRefs) db.vacunas,
                    if (integrantesRefs) db.integrantes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (viviendasRefs)
                        await $_getPrefetchedData<
                          Cedula,
                          $CedulasTable,
                          Vivienda
                        >(
                          currentTable: table,
                          referencedTable: $$CedulasTableReferences
                              ._viviendasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CedulasTableReferences(
                                db,
                                table,
                                p0,
                              ).viviendasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cedulaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vacunasRefs)
                        await $_getPrefetchedData<
                          Cedula,
                          $CedulasTable,
                          Vacuna
                        >(
                          currentTable: table,
                          referencedTable: $$CedulasTableReferences
                              ._vacunasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CedulasTableReferences(
                                db,
                                table,
                                p0,
                              ).vacunasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cedulaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (integrantesRefs)
                        await $_getPrefetchedData<
                          Cedula,
                          $CedulasTable,
                          Integrante
                        >(
                          currentTable: table,
                          referencedTable: $$CedulasTableReferences
                              ._integrantesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CedulasTableReferences(
                                db,
                                table,
                                p0,
                              ).integrantesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cedulaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CedulasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CedulasTable,
      Cedula,
      $$CedulasTableFilterComposer,
      $$CedulasTableOrderingComposer,
      $$CedulasTableAnnotationComposer,
      $$CedulasTableCreateCompanionBuilder,
      $$CedulasTableUpdateCompanionBuilder,
      (Cedula, $$CedulasTableReferences),
      Cedula,
      PrefetchHooks Function({
        bool viviendasRefs,
        bool vacunasRefs,
        bool integrantesRefs,
      })
    >;
typedef $$ViviendasTableCreateCompanionBuilder =
    ViviendasCompanion Function({
      Value<int> id,
      required int cedulaId,
      required String viviendaData,
    });
typedef $$ViviendasTableUpdateCompanionBuilder =
    ViviendasCompanion Function({
      Value<int> id,
      Value<int> cedulaId,
      Value<String> viviendaData,
    });

final class $$ViviendasTableReferences
    extends BaseReferences<_$AppDatabase, $ViviendasTable, Vivienda> {
  $$ViviendasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CedulasTable _cedulaIdTable(_$AppDatabase db) =>
      db.cedulas.createAlias('viviendas__cedula_id__cedulas__id');

  $$CedulasTableProcessedTableManager get cedulaId {
    final $_column = $_itemColumn<int>('cedula_id')!;

    final manager = $$CedulasTableTableManager(
      $_db,
      $_db.cedulas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cedulaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ViviendasTableFilterComposer
    extends Composer<_$AppDatabase, $ViviendasTable> {
  $$ViviendasTableFilterComposer({
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

  ColumnFilters<String> get viviendaData => $composableBuilder(
    column: $table.viviendaData,
    builder: (column) => ColumnFilters(column),
  );

  $$CedulasTableFilterComposer get cedulaId {
    final $$CedulasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableFilterComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ViviendasTableOrderingComposer
    extends Composer<_$AppDatabase, $ViviendasTable> {
  $$ViviendasTableOrderingComposer({
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

  ColumnOrderings<String> get viviendaData => $composableBuilder(
    column: $table.viviendaData,
    builder: (column) => ColumnOrderings(column),
  );

  $$CedulasTableOrderingComposer get cedulaId {
    final $$CedulasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableOrderingComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ViviendasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ViviendasTable> {
  $$ViviendasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get viviendaData => $composableBuilder(
    column: $table.viviendaData,
    builder: (column) => column,
  );

  $$CedulasTableAnnotationComposer get cedulaId {
    final $$CedulasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableAnnotationComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ViviendasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ViviendasTable,
          Vivienda,
          $$ViviendasTableFilterComposer,
          $$ViviendasTableOrderingComposer,
          $$ViviendasTableAnnotationComposer,
          $$ViviendasTableCreateCompanionBuilder,
          $$ViviendasTableUpdateCompanionBuilder,
          (Vivienda, $$ViviendasTableReferences),
          Vivienda,
          PrefetchHooks Function({bool cedulaId})
        > {
  $$ViviendasTableTableManager(_$AppDatabase db, $ViviendasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ViviendasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ViviendasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ViviendasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cedulaId = const Value.absent(),
                Value<String> viviendaData = const Value.absent(),
              }) => ViviendasCompanion(
                id: id,
                cedulaId: cedulaId,
                viviendaData: viviendaData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cedulaId,
                required String viviendaData,
              }) => ViviendasCompanion.insert(
                id: id,
                cedulaId: cedulaId,
                viviendaData: viviendaData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ViviendasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cedulaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cedulaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cedulaId,
                                referencedTable: $$ViviendasTableReferences
                                    ._cedulaIdTable(db),
                                referencedColumn: $$ViviendasTableReferences
                                    ._cedulaIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ViviendasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ViviendasTable,
      Vivienda,
      $$ViviendasTableFilterComposer,
      $$ViviendasTableOrderingComposer,
      $$ViviendasTableAnnotationComposer,
      $$ViviendasTableCreateCompanionBuilder,
      $$ViviendasTableUpdateCompanionBuilder,
      (Vivienda, $$ViviendasTableReferences),
      Vivienda,
      PrefetchHooks Function({bool cedulaId})
    >;
typedef $$VacunasTableCreateCompanionBuilder =
    VacunasCompanion Function({
      Value<int> id,
      required int cedulaId,
      required String vacunaData,
    });
typedef $$VacunasTableUpdateCompanionBuilder =
    VacunasCompanion Function({
      Value<int> id,
      Value<int> cedulaId,
      Value<String> vacunaData,
    });

final class $$VacunasTableReferences
    extends BaseReferences<_$AppDatabase, $VacunasTable, Vacuna> {
  $$VacunasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CedulasTable _cedulaIdTable(_$AppDatabase db) =>
      db.cedulas.createAlias('vacunas__cedula_id__cedulas__id');

  $$CedulasTableProcessedTableManager get cedulaId {
    final $_column = $_itemColumn<int>('cedula_id')!;

    final manager = $$CedulasTableTableManager(
      $_db,
      $_db.cedulas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cedulaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VacunasTableFilterComposer
    extends Composer<_$AppDatabase, $VacunasTable> {
  $$VacunasTableFilterComposer({
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

  ColumnFilters<String> get vacunaData => $composableBuilder(
    column: $table.vacunaData,
    builder: (column) => ColumnFilters(column),
  );

  $$CedulasTableFilterComposer get cedulaId {
    final $$CedulasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableFilterComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VacunasTableOrderingComposer
    extends Composer<_$AppDatabase, $VacunasTable> {
  $$VacunasTableOrderingComposer({
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

  ColumnOrderings<String> get vacunaData => $composableBuilder(
    column: $table.vacunaData,
    builder: (column) => ColumnOrderings(column),
  );

  $$CedulasTableOrderingComposer get cedulaId {
    final $$CedulasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableOrderingComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VacunasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VacunasTable> {
  $$VacunasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vacunaData => $composableBuilder(
    column: $table.vacunaData,
    builder: (column) => column,
  );

  $$CedulasTableAnnotationComposer get cedulaId {
    final $$CedulasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableAnnotationComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VacunasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VacunasTable,
          Vacuna,
          $$VacunasTableFilterComposer,
          $$VacunasTableOrderingComposer,
          $$VacunasTableAnnotationComposer,
          $$VacunasTableCreateCompanionBuilder,
          $$VacunasTableUpdateCompanionBuilder,
          (Vacuna, $$VacunasTableReferences),
          Vacuna,
          PrefetchHooks Function({bool cedulaId})
        > {
  $$VacunasTableTableManager(_$AppDatabase db, $VacunasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VacunasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VacunasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VacunasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cedulaId = const Value.absent(),
                Value<String> vacunaData = const Value.absent(),
              }) => VacunasCompanion(
                id: id,
                cedulaId: cedulaId,
                vacunaData: vacunaData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cedulaId,
                required String vacunaData,
              }) => VacunasCompanion.insert(
                id: id,
                cedulaId: cedulaId,
                vacunaData: vacunaData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VacunasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cedulaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cedulaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cedulaId,
                                referencedTable: $$VacunasTableReferences
                                    ._cedulaIdTable(db),
                                referencedColumn: $$VacunasTableReferences
                                    ._cedulaIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VacunasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VacunasTable,
      Vacuna,
      $$VacunasTableFilterComposer,
      $$VacunasTableOrderingComposer,
      $$VacunasTableAnnotationComposer,
      $$VacunasTableCreateCompanionBuilder,
      $$VacunasTableUpdateCompanionBuilder,
      (Vacuna, $$VacunasTableReferences),
      Vacuna,
      PrefetchHooks Function({bool cedulaId})
    >;
typedef $$IntegrantesTableCreateCompanionBuilder =
    IntegrantesCompanion Function({
      Value<int> id,
      required int cedulaId,
      required String integranteData,
    });
typedef $$IntegrantesTableUpdateCompanionBuilder =
    IntegrantesCompanion Function({
      Value<int> id,
      Value<int> cedulaId,
      Value<String> integranteData,
    });

final class $$IntegrantesTableReferences
    extends BaseReferences<_$AppDatabase, $IntegrantesTable, Integrante> {
  $$IntegrantesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CedulasTable _cedulaIdTable(_$AppDatabase db) =>
      db.cedulas.createAlias('integrantes__cedula_id__cedulas__id');

  $$CedulasTableProcessedTableManager get cedulaId {
    final $_column = $_itemColumn<int>('cedula_id')!;

    final manager = $$CedulasTableTableManager(
      $_db,
      $_db.cedulas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cedulaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntegrantesTableFilterComposer
    extends Composer<_$AppDatabase, $IntegrantesTable> {
  $$IntegrantesTableFilterComposer({
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

  ColumnFilters<String> get integranteData => $composableBuilder(
    column: $table.integranteData,
    builder: (column) => ColumnFilters(column),
  );

  $$CedulasTableFilterComposer get cedulaId {
    final $$CedulasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableFilterComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntegrantesTableOrderingComposer
    extends Composer<_$AppDatabase, $IntegrantesTable> {
  $$IntegrantesTableOrderingComposer({
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

  ColumnOrderings<String> get integranteData => $composableBuilder(
    column: $table.integranteData,
    builder: (column) => ColumnOrderings(column),
  );

  $$CedulasTableOrderingComposer get cedulaId {
    final $$CedulasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableOrderingComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntegrantesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntegrantesTable> {
  $$IntegrantesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get integranteData => $composableBuilder(
    column: $table.integranteData,
    builder: (column) => column,
  );

  $$CedulasTableAnnotationComposer get cedulaId {
    final $$CedulasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cedulaId,
      referencedTable: $db.cedulas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CedulasTableAnnotationComposer(
            $db: $db,
            $table: $db.cedulas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntegrantesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntegrantesTable,
          Integrante,
          $$IntegrantesTableFilterComposer,
          $$IntegrantesTableOrderingComposer,
          $$IntegrantesTableAnnotationComposer,
          $$IntegrantesTableCreateCompanionBuilder,
          $$IntegrantesTableUpdateCompanionBuilder,
          (Integrante, $$IntegrantesTableReferences),
          Integrante,
          PrefetchHooks Function({bool cedulaId})
        > {
  $$IntegrantesTableTableManager(_$AppDatabase db, $IntegrantesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntegrantesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntegrantesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntegrantesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cedulaId = const Value.absent(),
                Value<String> integranteData = const Value.absent(),
              }) => IntegrantesCompanion(
                id: id,
                cedulaId: cedulaId,
                integranteData: integranteData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cedulaId,
                required String integranteData,
              }) => IntegrantesCompanion.insert(
                id: id,
                cedulaId: cedulaId,
                integranteData: integranteData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntegrantesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cedulaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cedulaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cedulaId,
                                referencedTable: $$IntegrantesTableReferences
                                    ._cedulaIdTable(db),
                                referencedColumn: $$IntegrantesTableReferences
                                    ._cedulaIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IntegrantesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntegrantesTable,
      Integrante,
      $$IntegrantesTableFilterComposer,
      $$IntegrantesTableOrderingComposer,
      $$IntegrantesTableAnnotationComposer,
      $$IntegrantesTableCreateCompanionBuilder,
      $$IntegrantesTableUpdateCompanionBuilder,
      (Integrante, $$IntegrantesTableReferences),
      Integrante,
      PrefetchHooks Function({bool cedulaId})
    >;
typedef $$CatalogosLocalTableCreateCompanionBuilder =
    CatalogosLocalCompanion Function({
      Value<int> id,
      required String tipo,
      required String jsonList,
      required DateTime updatedAt,
    });
typedef $$CatalogosLocalTableUpdateCompanionBuilder =
    CatalogosLocalCompanion Function({
      Value<int> id,
      Value<String> tipo,
      Value<String> jsonList,
      Value<DateTime> updatedAt,
    });

class $$CatalogosLocalTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogosLocalTable> {
  $$CatalogosLocalTableFilterComposer({
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

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonList => $composableBuilder(
    column: $table.jsonList,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogosLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogosLocalTable> {
  $$CatalogosLocalTableOrderingComposer({
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

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonList => $composableBuilder(
    column: $table.jsonList,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogosLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogosLocalTable> {
  $$CatalogosLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get jsonList =>
      $composableBuilder(column: $table.jsonList, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CatalogosLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogosLocalTable,
          CatalogosLocalData,
          $$CatalogosLocalTableFilterComposer,
          $$CatalogosLocalTableOrderingComposer,
          $$CatalogosLocalTableAnnotationComposer,
          $$CatalogosLocalTableCreateCompanionBuilder,
          $$CatalogosLocalTableUpdateCompanionBuilder,
          (
            CatalogosLocalData,
            BaseReferences<
              _$AppDatabase,
              $CatalogosLocalTable,
              CatalogosLocalData
            >,
          ),
          CatalogosLocalData,
          PrefetchHooks Function()
        > {
  $$CatalogosLocalTableTableManager(
    _$AppDatabase db,
    $CatalogosLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogosLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogosLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogosLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> jsonList = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CatalogosLocalCompanion(
                id: id,
                tipo: tipo,
                jsonList: jsonList,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipo,
                required String jsonList,
                required DateTime updatedAt,
              }) => CatalogosLocalCompanion.insert(
                id: id,
                tipo: tipo,
                jsonList: jsonList,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogosLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogosLocalTable,
      CatalogosLocalData,
      $$CatalogosLocalTableFilterComposer,
      $$CatalogosLocalTableOrderingComposer,
      $$CatalogosLocalTableAnnotationComposer,
      $$CatalogosLocalTableCreateCompanionBuilder,
      $$CatalogosLocalTableUpdateCompanionBuilder,
      (
        CatalogosLocalData,
        BaseReferences<_$AppDatabase, $CatalogosLocalTable, CatalogosLocalData>,
      ),
      CatalogosLocalData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CedulasTableTableManager get cedulas =>
      $$CedulasTableTableManager(_db, _db.cedulas);
  $$ViviendasTableTableManager get viviendas =>
      $$ViviendasTableTableManager(_db, _db.viviendas);
  $$VacunasTableTableManager get vacunas =>
      $$VacunasTableTableManager(_db, _db.vacunas);
  $$IntegrantesTableTableManager get integrantes =>
      $$IntegrantesTableTableManager(_db, _db.integrantes);
  $$CatalogosLocalTableTableManager get catalogosLocal =>
      $$CatalogosLocalTableTableManager(_db, _db.catalogosLocal);
}
