import 'dart:async';

import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_menu_repository.dart';

/// Fake que deja la creación pendiente hasta que la prueba la libera, para
/// poder tocar Guardar mientras la petición "viaja".
class _RepositorioLento extends FakeMenuRepository {
  final respuesta = Completer<void>();
  int creaciones = 0;

  @override
  Future<Producto> crear({
    required String nombre,
    required int precioCentavos,
    bool disponible = true,
  }) async {
    creaciones++;
    await respuesta.future;
    return super.crear(
      nombre: nombre,
      precioCentavos: precioCentavos,
      disponible: disponible,
    );
  }
}

void main() {
  Future<void> abrirYLlenar(
    WidgetTester tester,
    FakeMenuRepository repo,
  ) async {
    await tester.pumpWidget(MaterialApp(home: HomeView(repository: repo)));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campo-nombre')), 'Molletes');
    await tester.enterText(find.byKey(const Key('campo-precio')), '35');
  }

  FilledButton botonGuardar(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byKey(const Key('boton-guardar')));

  testWidgets('dos toques seguidos en Guardar crean un solo producto', (
    tester,
  ) async {
    final repo = _RepositorioLento();
    await abrirYLlenar(tester, repo);

    await tester.tap(find.text('Guardar'));
    await tester.tap(find.text('Guardar'), warnIfMissed: false);
    await tester.pump();

    repo.respuesta.complete();
    await tester.pumpAndSettle();

    expect(repo.creaciones, 1);
    expect(repo.productos, hasLength(1));
  });

  testWidgets('mientras guarda, el botón se deshabilita y muestra progreso', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    final repo = _RepositorioLento();
    await abrirYLlenar(tester, repo);

    expect(botonGuardar(tester).onPressed, isNotNull);

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(botonGuardar(tester).onPressed, isNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('boton-guardar')),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Guardando')), findsOneWidget);
    expect(find.byKey(const Key('campo-nombre')), findsOneWidget);

    repo.respuesta.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('boton-guardar')), findsNothing);
    expect(find.text('Molletes'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('si falla, el formulario sigue abierto y Guardar se reactiva', (
    tester,
  ) async {
    final repo = FakeMenuRepository()
      ..fallaAlGuardar = const ServerFailure(500);
    await abrirYLlenar(tester, repo);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('boton-guardar')), findsOneWidget);
    expect(botonGuardar(tester).onPressed, isNotNull);
    expect(find.text('Molletes'), findsOneWidget);
    expect(repo.productos, isEmpty);
  });
}
