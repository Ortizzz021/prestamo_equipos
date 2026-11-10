// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SolicitudesTable extends Solicitudes
    with TableInfo<$SolicitudesTable, SolicitudRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SolicitudesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoIdMeta = const VerificationMeta(
    'equipoId',
  );
  @override
  late final GeneratedColumn<String> equipoId = GeneratedColumn<String>(
    'equipo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoNombreMeta = const VerificationMeta(
    'equipoNombre',
  );
  @override
  late final GeneratedColumn<String> equipoNombre = GeneratedColumn<String>(
    'equipo_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ultimoErrorMeta = const VerificationMeta(
    'ultimoError',
  );
  @override
  late final GeneratedColumn<String> ultimoError = GeneratedColumn<String>(
    'ultimo_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionEntregaMeta =
      const VerificationMeta('observacionEntrega');
  @override
  late final GeneratedColumn<String> observacionEntrega =
      GeneratedColumn<String>(
        'observacion_entrega',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _observacionDevolucionMeta =
      const VerificationMeta('observacionDevolucion');
  @override
  late final GeneratedColumn<String> observacionDevolucion =
      GeneratedColumn<String>(
        'observacion_devolucion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _motivoRechazoMeta = const VerificationMeta(
    'motivoRechazo',
  );
  @override
  late final GeneratedColumn<String> motivoRechazo = GeneratedColumn<String>(
    'motivo_rechazo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadaEnMeta = const VerificationMeta(
    'creadaEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadaEn = GeneratedColumn<DateTime>(
    'creada_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadaEnMeta = const VerificationMeta(
    'actualizadaEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadaEn =
      GeneratedColumn<DateTime>(
        'actualizada_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    equipoId,
    equipoNombre,
    fecha,
    slot,
    estado,
    version,
    estadoSync,
    ultimoError,
    observacionEntrega,
    observacionDevolucion,
    motivoRechazo,
    creadaEn,
    actualizadaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'solicitudes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SolicitudRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerUidMeta);
    }
    if (data.containsKey('equipo_id')) {
      context.handle(
        _equipoIdMeta,
        equipoId.isAcceptableOrUnknown(data['equipo_id']!, _equipoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoIdMeta);
    }
    if (data.containsKey('equipo_nombre')) {
      context.handle(
        _equipoNombreMeta,
        equipoNombre.isAcceptableOrUnknown(
          data['equipo_nombre']!,
          _equipoNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipoNombreMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoSyncMeta);
    }
    if (data.containsKey('ultimo_error')) {
      context.handle(
        _ultimoErrorMeta,
        ultimoError.isAcceptableOrUnknown(
          data['ultimo_error']!,
          _ultimoErrorMeta,
        ),
      );
    }
    if (data.containsKey('observacion_entrega')) {
      context.handle(
        _observacionEntregaMeta,
        observacionEntrega.isAcceptableOrUnknown(
          data['observacion_entrega']!,
          _observacionEntregaMeta,
        ),
      );
    }
    if (data.containsKey('observacion_devolucion')) {
      context.handle(
        _observacionDevolucionMeta,
        observacionDevolucion.isAcceptableOrUnknown(
          data['observacion_devolucion']!,
          _observacionDevolucionMeta,
        ),
      );
    }
    if (data.containsKey('motivo_rechazo')) {
      context.handle(
        _motivoRechazoMeta,
        motivoRechazo.isAcceptableOrUnknown(
          data['motivo_rechazo']!,
          _motivoRechazoMeta,
        ),
      );
    }
    if (data.containsKey('creada_en')) {
      context.handle(
        _creadaEnMeta,
        creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaEnMeta);
    }
    if (data.containsKey('actualizada_en')) {
      context.handle(
        _actualizadaEnMeta,
        actualizadaEn.isAcceptableOrUnknown(
          data['actualizada_en']!,
          _actualizadaEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SolicitudRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SolicitudRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      )!,
      equipoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_id'],
      )!,
      equipoNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_nombre'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      ultimoError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultimo_error'],
      ),
      observacionEntrega: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion_entrega'],
      ),
      observacionDevolucion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion_devolucion'],
      ),
      motivoRechazo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_rechazo'],
      ),
      creadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creada_en'],
      )!,
      actualizadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizada_en'],
      )!,
    );
  }

  @override
  $SolicitudesTable createAlias(String alias) {
    return $SolicitudesTable(attachedDatabase, alias);
  }
}

class SolicitudRow extends DataClass implements Insertable<SolicitudRow> {
  final String id;
  final String ownerUid;
  final String equipoId;
  final String equipoNombre;
  final DateTime fecha;
  final String slot;
  final String estado;
  final int version;
  final String estadoSync;
  final String? ultimoError;
  final String? observacionEntrega;
  final String? observacionDevolucion;
  final String? motivoRechazo;
  final DateTime creadaEn;
  final DateTime actualizadaEn;
  const SolicitudRow({
    required this.id,
    required this.ownerUid,
    required this.equipoId,
    required this.equipoNombre,
    required this.fecha,
    required this.slot,
    required this.estado,
    required this.version,
    required this.estadoSync,
    this.ultimoError,
    this.observacionEntrega,
    this.observacionDevolucion,
    this.motivoRechazo,
    required this.creadaEn,
    required this.actualizadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_uid'] = Variable<String>(ownerUid);
    map['equipo_id'] = Variable<String>(equipoId);
    map['equipo_nombre'] = Variable<String>(equipoNombre);
    map['fecha'] = Variable<DateTime>(fecha);
    map['slot'] = Variable<String>(slot);
    map['estado'] = Variable<String>(estado);
    map['version'] = Variable<int>(version);
    map['estado_sync'] = Variable<String>(estadoSync);
    if (!nullToAbsent || ultimoError != null) {
      map['ultimo_error'] = Variable<String>(ultimoError);
    }
    if (!nullToAbsent || observacionEntrega != null) {
      map['observacion_entrega'] = Variable<String>(observacionEntrega);
    }
    if (!nullToAbsent || observacionDevolucion != null) {
      map['observacion_devolucion'] = Variable<String>(observacionDevolucion);
    }
    if (!nullToAbsent || motivoRechazo != null) {
      map['motivo_rechazo'] = Variable<String>(motivoRechazo);
    }
    map['creada_en'] = Variable<DateTime>(creadaEn);
    map['actualizada_en'] = Variable<DateTime>(actualizadaEn);
    return map;
  }

  SolicitudesCompanion toCompanion(bool nullToAbsent) {
    return SolicitudesCompanion(
      id: Value(id),
      ownerUid: Value(ownerUid),
      equipoId: Value(equipoId),
      equipoNombre: Value(equipoNombre),
      fecha: Value(fecha),
      slot: Value(slot),
      estado: Value(estado),
      version: Value(version),
      estadoSync: Value(estadoSync),
      ultimoError: ultimoError == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoError),
      observacionEntrega: observacionEntrega == null && nullToAbsent
          ? const Value.absent()
          : Value(observacionEntrega),
      observacionDevolucion: observacionDevolucion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacionDevolucion),
      motivoRechazo: motivoRechazo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoRechazo),
      creadaEn: Value(creadaEn),
      actualizadaEn: Value(actualizadaEn),
    );
  }

  factory SolicitudRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SolicitudRow(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String>(json['ownerUid']),
      equipoId: serializer.fromJson<String>(json['equipoId']),
      equipoNombre: serializer.fromJson<String>(json['equipoNombre']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      slot: serializer.fromJson<String>(json['slot']),
      estado: serializer.fromJson<String>(json['estado']),
      version: serializer.fromJson<int>(json['version']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      ultimoError: serializer.fromJson<String?>(json['ultimoError']),
      observacionEntrega: serializer.fromJson<String?>(
        json['observacionEntrega'],
      ),
      observacionDevolucion: serializer.fromJson<String?>(
        json['observacionDevolucion'],
      ),
      motivoRechazo: serializer.fromJson<String?>(json['motivoRechazo']),
      creadaEn: serializer.fromJson<DateTime>(json['creadaEn']),
      actualizadaEn: serializer.fromJson<DateTime>(json['actualizadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String>(ownerUid),
      'equipoId': serializer.toJson<String>(equipoId),
      'equipoNombre': serializer.toJson<String>(equipoNombre),
      'fecha': serializer.toJson<DateTime>(fecha),
      'slot': serializer.toJson<String>(slot),
      'estado': serializer.toJson<String>(estado),
      'version': serializer.toJson<int>(version),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'ultimoError': serializer.toJson<String?>(ultimoError),
      'observacionEntrega': serializer.toJson<String?>(observacionEntrega),
      'observacionDevolucion': serializer.toJson<String?>(
        observacionDevolucion,
      ),
      'motivoRechazo': serializer.toJson<String?>(motivoRechazo),
      'creadaEn': serializer.toJson<DateTime>(creadaEn),
      'actualizadaEn': serializer.toJson<DateTime>(actualizadaEn),
    };
  }

  SolicitudRow copyWith({
    String? id,
    String? ownerUid,
    String? equipoId,
    String? equipoNombre,
    DateTime? fecha,
    String? slot,
    String? estado,
    int? version,
    String? estadoSync,
    Value<String?> ultimoError = const Value.absent(),
    Value<String?> observacionEntrega = const Value.absent(),
    Value<String?> observacionDevolucion = const Value.absent(),
    Value<String?> motivoRechazo = const Value.absent(),
    DateTime? creadaEn,
    DateTime? actualizadaEn,
  }) => SolicitudRow(
    id: id ?? this.id,
    ownerUid: ownerUid ?? this.ownerUid,
    equipoId: equipoId ?? this.equipoId,
    equipoNombre: equipoNombre ?? this.equipoNombre,
    fecha: fecha ?? this.fecha,
    slot: slot ?? this.slot,
    estado: estado ?? this.estado,
    version: version ?? this.version,
    estadoSync: estadoSync ?? this.estadoSync,
    ultimoError: ultimoError.present ? ultimoError.value : this.ultimoError,
    observacionEntrega: observacionEntrega.present
        ? observacionEntrega.value
        : this.observacionEntrega,
    observacionDevolucion: observacionDevolucion.present
        ? observacionDevolucion.value
        : this.observacionDevolucion,
    motivoRechazo: motivoRechazo.present
        ? motivoRechazo.value
        : this.motivoRechazo,
    creadaEn: creadaEn ?? this.creadaEn,
    actualizadaEn: actualizadaEn ?? this.actualizadaEn,
  );
  SolicitudRow copyWithCompanion(SolicitudesCompanion data) {
    return SolicitudRow(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      equipoId: data.equipoId.present ? data.equipoId.value : this.equipoId,
      equipoNombre: data.equipoNombre.present
          ? data.equipoNombre.value
          : this.equipoNombre,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      slot: data.slot.present ? data.slot.value : this.slot,
      estado: data.estado.present ? data.estado.value : this.estado,
      version: data.version.present ? data.version.value : this.version,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      ultimoError: data.ultimoError.present
          ? data.ultimoError.value
          : this.ultimoError,
      observacionEntrega: data.observacionEntrega.present
          ? data.observacionEntrega.value
          : this.observacionEntrega,
      observacionDevolucion: data.observacionDevolucion.present
          ? data.observacionDevolucion.value
          : this.observacionDevolucion,
      motivoRechazo: data.motivoRechazo.present
          ? data.motivoRechazo.value
          : this.motivoRechazo,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
      actualizadaEn: data.actualizadaEn.present
          ? data.actualizadaEn.value
          : this.actualizadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SolicitudRow(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('equipoId: $equipoId, ')
          ..write('equipoNombre: $equipoNombre, ')
          ..write('fecha: $fecha, ')
          ..write('slot: $slot, ')
          ..write('estado: $estado, ')
          ..write('version: $version, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('observacionEntrega: $observacionEntrega, ')
          ..write('observacionDevolucion: $observacionDevolucion, ')
          ..write('motivoRechazo: $motivoRechazo, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('actualizadaEn: $actualizadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    equipoId,
    equipoNombre,
    fecha,
    slot,
    estado,
    version,
    estadoSync,
    ultimoError,
    observacionEntrega,
    observacionDevolucion,
    motivoRechazo,
    creadaEn,
    actualizadaEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolicitudRow &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.equipoId == this.equipoId &&
          other.equipoNombre == this.equipoNombre &&
          other.fecha == this.fecha &&
          other.slot == this.slot &&
          other.estado == this.estado &&
          other.version == this.version &&
          other.estadoSync == this.estadoSync &&
          other.ultimoError == this.ultimoError &&
          other.observacionEntrega == this.observacionEntrega &&
          other.observacionDevolucion == this.observacionDevolucion &&
          other.motivoRechazo == this.motivoRechazo &&
          other.creadaEn == this.creadaEn &&
          other.actualizadaEn == this.actualizadaEn);
}

class SolicitudesCompanion extends UpdateCompanion<SolicitudRow> {
  final Value<String> id;
  final Value<String> ownerUid;
  final Value<String> equipoId;
  final Value<String> equipoNombre;
  final Value<DateTime> fecha;
  final Value<String> slot;
  final Value<String> estado;
  final Value<int> version;
  final Value<String> estadoSync;
  final Value<String?> ultimoError;
  final Value<String?> observacionEntrega;
  final Value<String?> observacionDevolucion;
  final Value<String?> motivoRechazo;
  final Value<DateTime> creadaEn;
  final Value<DateTime> actualizadaEn;
  final Value<int> rowid;
  const SolicitudesCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.equipoId = const Value.absent(),
    this.equipoNombre = const Value.absent(),
    this.fecha = const Value.absent(),
    this.slot = const Value.absent(),
    this.estado = const Value.absent(),
    this.version = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.observacionEntrega = const Value.absent(),
    this.observacionDevolucion = const Value.absent(),
    this.motivoRechazo = const Value.absent(),
    this.creadaEn = const Value.absent(),
    this.actualizadaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SolicitudesCompanion.insert({
    required String id,
    required String ownerUid,
    required String equipoId,
    required String equipoNombre,
    required DateTime fecha,
    required String slot,
    required String estado,
    this.version = const Value.absent(),
    required String estadoSync,
    this.ultimoError = const Value.absent(),
    this.observacionEntrega = const Value.absent(),
    this.observacionDevolucion = const Value.absent(),
    this.motivoRechazo = const Value.absent(),
    required DateTime creadaEn,
    required DateTime actualizadaEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUid = Value(ownerUid),
       equipoId = Value(equipoId),
       equipoNombre = Value(equipoNombre),
       fecha = Value(fecha),
       slot = Value(slot),
       estado = Value(estado),
       estadoSync = Value(estadoSync),
       creadaEn = Value(creadaEn),
       actualizadaEn = Value(actualizadaEn);
  static Insertable<SolicitudRow> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? equipoId,
    Expression<String>? equipoNombre,
    Expression<DateTime>? fecha,
    Expression<String>? slot,
    Expression<String>? estado,
    Expression<int>? version,
    Expression<String>? estadoSync,
    Expression<String>? ultimoError,
    Expression<String>? observacionEntrega,
    Expression<String>? observacionDevolucion,
    Expression<String>? motivoRechazo,
    Expression<DateTime>? creadaEn,
    Expression<DateTime>? actualizadaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (equipoId != null) 'equipo_id': equipoId,
      if (equipoNombre != null) 'equipo_nombre': equipoNombre,
      if (fecha != null) 'fecha': fecha,
      if (slot != null) 'slot': slot,
      if (estado != null) 'estado': estado,
      if (version != null) 'version': version,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (observacionEntrega != null) 'observacion_entrega': observacionEntrega,
      if (observacionDevolucion != null)
        'observacion_devolucion': observacionDevolucion,
      if (motivoRechazo != null) 'motivo_rechazo': motivoRechazo,
      if (creadaEn != null) 'creada_en': creadaEn,
      if (actualizadaEn != null) 'actualizada_en': actualizadaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SolicitudesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUid,
    Value<String>? equipoId,
    Value<String>? equipoNombre,
    Value<DateTime>? fecha,
    Value<String>? slot,
    Value<String>? estado,
    Value<int>? version,
    Value<String>? estadoSync,
    Value<String?>? ultimoError,
    Value<String?>? observacionEntrega,
    Value<String?>? observacionDevolucion,
    Value<String?>? motivoRechazo,
    Value<DateTime>? creadaEn,
    Value<DateTime>? actualizadaEn,
    Value<int>? rowid,
  }) {
    return SolicitudesCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      equipoId: equipoId ?? this.equipoId,
      equipoNombre: equipoNombre ?? this.equipoNombre,
      fecha: fecha ?? this.fecha,
      slot: slot ?? this.slot,
      estado: estado ?? this.estado,
      version: version ?? this.version,
      estadoSync: estadoSync ?? this.estadoSync,
      ultimoError: ultimoError ?? this.ultimoError,
      observacionEntrega: observacionEntrega ?? this.observacionEntrega,
      observacionDevolucion:
          observacionDevolucion ?? this.observacionDevolucion,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      creadaEn: creadaEn ?? this.creadaEn,
      actualizadaEn: actualizadaEn ?? this.actualizadaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (equipoId.present) {
      map['equipo_id'] = Variable<String>(equipoId.value);
    }
    if (equipoNombre.present) {
      map['equipo_nombre'] = Variable<String>(equipoNombre.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (ultimoError.present) {
      map['ultimo_error'] = Variable<String>(ultimoError.value);
    }
    if (observacionEntrega.present) {
      map['observacion_entrega'] = Variable<String>(observacionEntrega.value);
    }
    if (observacionDevolucion.present) {
      map['observacion_devolucion'] = Variable<String>(
        observacionDevolucion.value,
      );
    }
    if (motivoRechazo.present) {
      map['motivo_rechazo'] = Variable<String>(motivoRechazo.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<DateTime>(creadaEn.value);
    }
    if (actualizadaEn.present) {
      map['actualizada_en'] = Variable<DateTime>(actualizadaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SolicitudesCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('equipoId: $equipoId, ')
          ..write('equipoNombre: $equipoNombre, ')
          ..write('fecha: $fecha, ')
          ..write('slot: $slot, ')
          ..write('estado: $estado, ')
          ..write('version: $version, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('observacionEntrega: $observacionEntrega, ')
          ..write('observacionDevolucion: $observacionDevolucion, ')
          ..write('motivoRechazo: $motivoRechazo, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('actualizadaEn: $actualizadaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SolicitudesTable solicitudes = $SolicitudesTable(this);
  late final Index idxSolicitudesOwner = Index(
    'idx_solicitudes_owner',
    'CREATE INDEX idx_solicitudes_owner ON solicitudes (owner_uid)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    solicitudes,
    idxSolicitudesOwner,
  ];
}

typedef $$SolicitudesTableCreateCompanionBuilder =
    SolicitudesCompanion Function({
      required String id,
      required String ownerUid,
      required String equipoId,
      required String equipoNombre,
      required DateTime fecha,
      required String slot,
      required String estado,
      Value<int> version,
      required String estadoSync,
      Value<String?> ultimoError,
      Value<String?> observacionEntrega,
      Value<String?> observacionDevolucion,
      Value<String?> motivoRechazo,
      required DateTime creadaEn,
      required DateTime actualizadaEn,
      Value<int> rowid,
    });
typedef $$SolicitudesTableUpdateCompanionBuilder =
    SolicitudesCompanion Function({
      Value<String> id,
      Value<String> ownerUid,
      Value<String> equipoId,
      Value<String> equipoNombre,
      Value<DateTime> fecha,
      Value<String> slot,
      Value<String> estado,
      Value<int> version,
      Value<String> estadoSync,
      Value<String?> ultimoError,
      Value<String?> observacionEntrega,
      Value<String?> observacionDevolucion,
      Value<String?> motivoRechazo,
      Value<DateTime> creadaEn,
      Value<DateTime> actualizadaEn,
      Value<int> rowid,
    });

class $$SolicitudesTableFilterComposer
    extends Composer<_$AppDatabase, $SolicitudesTable> {
  $$SolicitudesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoId => $composableBuilder(
    column: $table.equipoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoNombre => $composableBuilder(
    column: $table.equipoNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacionEntrega => $composableBuilder(
    column: $table.observacionEntrega,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacionDevolucion => $composableBuilder(
    column: $table.observacionDevolucion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoRechazo => $composableBuilder(
    column: $table.motivoRechazo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadaEn => $composableBuilder(
    column: $table.actualizadaEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SolicitudesTableOrderingComposer
    extends Composer<_$AppDatabase, $SolicitudesTable> {
  $$SolicitudesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoId => $composableBuilder(
    column: $table.equipoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoNombre => $composableBuilder(
    column: $table.equipoNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacionEntrega => $composableBuilder(
    column: $table.observacionEntrega,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacionDevolucion => $composableBuilder(
    column: $table.observacionDevolucion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoRechazo => $composableBuilder(
    column: $table.motivoRechazo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadaEn => $composableBuilder(
    column: $table.actualizadaEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SolicitudesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SolicitudesTable> {
  $$SolicitudesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get equipoId =>
      $composableBuilder(column: $table.equipoId, builder: (column) => column);

  GeneratedColumn<String> get equipoNombre => $composableBuilder(
    column: $table.equipoNombre,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observacionEntrega => $composableBuilder(
    column: $table.observacionEntrega,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observacionDevolucion => $composableBuilder(
    column: $table.observacionDevolucion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivoRechazo => $composableBuilder(
    column: $table.motivoRechazo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadaEn => $composableBuilder(
    column: $table.actualizadaEn,
    builder: (column) => column,
  );
}

class $$SolicitudesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SolicitudesTable,
          SolicitudRow,
          $$SolicitudesTableFilterComposer,
          $$SolicitudesTableOrderingComposer,
          $$SolicitudesTableAnnotationComposer,
          $$SolicitudesTableCreateCompanionBuilder,
          $$SolicitudesTableUpdateCompanionBuilder,
          (
            SolicitudRow,
            BaseReferences<_$AppDatabase, $SolicitudesTable, SolicitudRow>,
          ),
          SolicitudRow,
          PrefetchHooks Function()
        > {
  $$SolicitudesTableTableManager(_$AppDatabase db, $SolicitudesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SolicitudesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SolicitudesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SolicitudesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUid = const Value.absent(),
                Value<String> equipoId = const Value.absent(),
                Value<String> equipoNombre = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> slot = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<String?> observacionEntrega = const Value.absent(),
                Value<String?> observacionDevolucion = const Value.absent(),
                Value<String?> motivoRechazo = const Value.absent(),
                Value<DateTime> creadaEn = const Value.absent(),
                Value<DateTime> actualizadaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SolicitudesCompanion(
                id: id,
                ownerUid: ownerUid,
                equipoId: equipoId,
                equipoNombre: equipoNombre,
                fecha: fecha,
                slot: slot,
                estado: estado,
                version: version,
                estadoSync: estadoSync,
                ultimoError: ultimoError,
                observacionEntrega: observacionEntrega,
                observacionDevolucion: observacionDevolucion,
                motivoRechazo: motivoRechazo,
                creadaEn: creadaEn,
                actualizadaEn: actualizadaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUid,
                required String equipoId,
                required String equipoNombre,
                required DateTime fecha,
                required String slot,
                required String estado,
                Value<int> version = const Value.absent(),
                required String estadoSync,
                Value<String?> ultimoError = const Value.absent(),
                Value<String?> observacionEntrega = const Value.absent(),
                Value<String?> observacionDevolucion = const Value.absent(),
                Value<String?> motivoRechazo = const Value.absent(),
                required DateTime creadaEn,
                required DateTime actualizadaEn,
                Value<int> rowid = const Value.absent(),
              }) => SolicitudesCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                equipoId: equipoId,
                equipoNombre: equipoNombre,
                fecha: fecha,
                slot: slot,
                estado: estado,
                version: version,
                estadoSync: estadoSync,
                ultimoError: ultimoError,
                observacionEntrega: observacionEntrega,
                observacionDevolucion: observacionDevolucion,
                motivoRechazo: motivoRechazo,
                creadaEn: creadaEn,
                actualizadaEn: actualizadaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SolicitudesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SolicitudesTable,
      SolicitudRow,
      $$SolicitudesTableFilterComposer,
      $$SolicitudesTableOrderingComposer,
      $$SolicitudesTableAnnotationComposer,
      $$SolicitudesTableCreateCompanionBuilder,
      $$SolicitudesTableUpdateCompanionBuilder,
      (
        SolicitudRow,
        BaseReferences<_$AppDatabase, $SolicitudesTable, SolicitudRow>,
      ),
      SolicitudRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SolicitudesTableTableManager get solicitudes =>
      $$SolicitudesTableTableManager(_db, _db.solicitudes);
}
