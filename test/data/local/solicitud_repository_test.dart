import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/regla_negocio_exception.dart';
import 'package:prestamo_equipos/data/local/app_database.dart';
import 'package:prestamo_equipos/data/repositories/solicitud_repository.dart';
import 'package:prestamo_equipos/domain/models/equipo.dart';
import 'package:prestamo_equipos/domain/models/estado_solicitud.dart';
import 'package:prestamo_equipos/domain/models/franja.dart';
import 'package:prestamo_equipos/domain/models/solicitud.dart';

import '../../helpers/base_en_memoria.dart';

void main() {
  final ahora = DateTime(2026, 11, 10, 9);
  const laptop = Equipo(
    id: 'eq-1',
    nombre: 'Portátil Lenovo',
    categoria: 'Portátiles',
    descripcion: '',
    imagenUrl: '',
  );
  final manana = Franja(fecha: DateTime(2026, 11, 11), slot: SlotHorario.manana1);

  late AppDatabase db;
  late SolicitudRepository repo;

  setUp(() {
    db = baseEnMemoria();
    repo = SolicitudRepository(db: db, reloj: () => ahora);
  });

  tearDown(() => db.close());

  test('crea la solicitud local como SOLICITADO y pendiente de sincronizar', () async {
    final creada = await repo.crearSolicitud(
      ownerUid: 'uid-ana',
      equipo: laptop,
      franja: manana,
    );

    final guardadas = await repo.observarMisSolicitudes('uid-ana').first;
    expect(guardadas, hasLength(1));
    final s = guardadas.single.solicitud;
    expect(s.id, creada.solicitud.id);
    expect(s.estado, EstadoSolicitud.solicitado);
    expect(s.estadoSync, EstadoSync.pendiente);
    expect(s.franja, manana);
    expect(guardadas.single.equipoNombre, 'Portátil Lenovo');
  });

  test('cada solicitud recibe un id estable y único', () async {
    final a = await repo.crearSolicitud(ownerUid: 'u', equipo: laptop, franja: manana);
    final b = await repo.crearSolicitud(
      ownerUid: 'u',
      equipo: laptop,
      franja: Franja(fecha: DateTime(2026, 11, 11), slot: SlotHorario.tarde1),
    );
    expect(a.solicitud.id, isNot(b.solicitud.id));
    expect(a.solicitud.id, hasLength(36));
  });

  test('solo se ven las solicitudes del usuario autenticado', () async {
    await repo.crearSolicitud(ownerUid: 'uid-ana', equipo: laptop, franja: manana);
    await repo.crearSolicitud(ownerUid: 'uid-luis', equipo: laptop, franja: manana);

    final deAna = await repo.observarMisSolicitudes('uid-ana').first;
    final deLuis = await repo.observarMisSolicitudes('uid-luis').first;
    final deOtro = await repo.observarMisSolicitudes('uid-otro').first;

    expect(deAna.map((m) => m.solicitud.solicitanteUid), ['uid-ana']);
    expect(deLuis.map((m) => m.solicitud.solicitanteUid), ['uid-luis']);
    expect(deOtro, isEmpty);
  });

  test('no permite duplicar una solicitud activa del mismo equipo y franja', () async {
    await repo.crearSolicitud(ownerUid: 'uid-ana', equipo: laptop, franja: manana);

    await expectLater(
      repo.crearSolicitud(ownerUid: 'uid-ana', equipo: laptop, franja: manana),
      throwsA(
        isA<ReglaNegocioException>()
            .having((e) => e.codigo, 'codigo', 'SOLICITUD_DUPLICADA'),
      ),
    );
    expect(await repo.observarMisSolicitudes('uid-ana').first, hasLength(1));
  });

  test('rechaza una franja pasada sin guardar nada', () async {
    await expectLater(
      repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: Franja(fecha: DateTime(2026, 11, 10), slot: SlotHorario.manana1),
      ),
      throwsA(isA<ReglaNegocioException>()),
    );
    expect(await repo.observarMisSolicitudes('uid-ana').first, isEmpty);
  });

  test('las solicitudes siguen guardadas al cerrar y abrir la base', () async {
    final dir = await Directory.systemTemp.createTemp('prestamo_db_');
    final archivo = File('${dir.path}/prueba.sqlite');
    try {
      final primera = AppDatabase(NativeDatabase(archivo));
      await SolicitudRepository(db: primera, reloj: () => ahora)
          .crearSolicitud(ownerUid: 'uid-ana', equipo: laptop, franja: manana);
      await primera.close();

      final segunda = AppDatabase(NativeDatabase(archivo));
      final lista = await SolicitudRepository(db: segunda)
          .observarMisSolicitudes('uid-ana')
          .first;
      await segunda.close();

      expect(lista, hasLength(1));
      expect(lista.single.solicitud.estadoSync, EstadoSync.pendiente);
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
