import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/data/remote/disponibilidad_remote_data_source.dart';
import 'package:prestamo_equipos/data/repositories/disponibilidad_repository.dart';
import 'package:prestamo_equipos/domain/models/equipo.dart';
import 'package:prestamo_equipos/features/catalogo/detalle_equipo_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('detalle muestra el bloqueo y deshabilita la solicitud', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('equipos_estado').doc('eq-bloqueado').set({
      'bloqueado': true,
      'motivo': 'Revisión técnica',
    });
    final repository = DisponibilidadRepository(
      remote: DisponibilidadRemoteDataSource(firestore: firestore),
    );
    const equipo = Equipo(
      id: 'eq-bloqueado',
      nombre: 'Portátil de prueba',
      categoria: 'Portátiles',
      descripcion: 'Equipo de prueba',
      imagenUrl: '',
    );

    await tester.pumpWidget(
      Provider<DisponibilidadRepository>.value(
        value: repository,
        child: const MaterialApp(home: DetalleEquipoScreen(equipo: equipo)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bloqueado'), findsOneWidget);
    expect(find.text('Revisión técnica'), findsOneWidget);
    final boton = tester.widget<FilledButton>(
      find.byKey(const Key('detalle_solicitar')),
    );
    expect(boton.onPressed, isNull);
    expect(find.text('Equipo bloqueado'), findsOneWidget);
  });
}
