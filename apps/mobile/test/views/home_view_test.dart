import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_menu_repository.dart';

void main() {
  const cafe = Producto(
    id: 'p-1',
    nombre: 'Café americano',
    precioCentavos: 1800,
    disponible: true,
  );
  const pan = Producto(
    id: 'p-2',
    nombre: 'Pan dulce',
    precioCentavos: 1250,
    disponible: false,
  );

  Future<void> montar(WidgetTester tester, FakeMenuRepository repo) async {
    await tester.pumpWidget(MaterialApp(home: HomeView(repository: repo)));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra los productos en una lista con su precio', (
    tester,
  ) async {
    await montar(tester, FakeMenuRepository(inicial: [cafe, pan]));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Café americano'), findsOneWidget);
    expect(find.text('\$18.00'), findsOneWidget);
    expect(find.text('Pan dulce'), findsOneWidget);
    expect(find.text('\$12.50'), findsOneWidget);
  });

  testWidgets('sin productos muestra un mensaje, no una lista vacía', (
    tester,
  ) async {
    await montar(tester, FakeMenuRepository());

    expect(find.byType(ListView), findsNothing);
    expect(find.textContaining('Todavía no hay productos'), findsOneWidget);
  });

  testWidgets('un producto agotado se muestra en gris con su badge', (
    tester,
  ) async {
    await montar(tester, FakeMenuRepository(inicial: [cafe, pan]));

    expect(find.text('Agotado'), findsOneWidget);
  });

  testWidgets('si falla la carga muestra el error y permite reintentar', (
    tester,
  ) async {
    final repo = FakeMenuRepository()
      ..fallaAlListar = const ConnectionFailure('sin red');
    await montar(tester, repo);

    expect(find.text('No pudimos cargar el menú'), findsOneWidget);
    expect(find.textContaining('revisa tu conexión'), findsOneWidget);

    repo.fallaAlListar = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Todavía no hay productos'), findsOneWidget);
  });

  testWidgets('el botón + abre el formulario y crea un producto', (
    tester,
  ) async {
    final repo = FakeMenuRepository();
    await montar(tester, repo);

    await tester.tap(find.byTooltip('Agregar producto'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('campo-nombre')),
      'Chilaquiles',
    );
    await tester.enterText(find.byKey(const Key('campo-precio')), '45.50');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Chilaquiles'), findsOneWidget);
    expect(find.text('\$45.50'), findsOneWidget);
    expect(repo.productos.single.precioCentavos, 4550);
  });

  testWidgets('no guarda si el precio no es válido', (tester) async {
    final repo = FakeMenuRepository();
    await montar(tester, repo);

    await tester.tap(find.byTooltip('Agregar producto'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('campo-nombre')), 'Té');
    await tester.enterText(find.byKey(const Key('campo-precio')), 'abc');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('precio'), findsWidgets);
    expect(repo.productos, isEmpty);
  });

  testWidgets('tocar un producto permite editarlo', (tester) async {
    final repo = FakeMenuRepository(inicial: [cafe]);
    await montar(tester, repo);

    await tester.tap(find.text('Café americano'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('campo-nombre')),
      'Café de olla',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Café de olla'), findsOneWidget);
    expect(find.text('Café americano'), findsNothing);
  });

  testWidgets('dar de baja pide confirmación y deja el producto agotado', (
    tester,
  ) async {
    final repo = FakeMenuRepository(inicial: [cafe]);
    await montar(tester, repo);

    await tester.tap(find.byTooltip('Acciones de Café americano'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dar de baja'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(repo.productos.single.disponible, isFalse);
    expect(find.text('Agotado'), findsOneWidget);
  });

  testWidgets('reactivar vuelve a poner el producto disponible', (
    tester,
  ) async {
    final repo = FakeMenuRepository(inicial: [pan]);
    await montar(tester, repo);

    await tester.tap(find.byTooltip('Acciones de Pan dulce'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reactivar'));
    await tester.pumpAndSettle();

    expect(repo.productos.single.disponible, isTrue);
    expect(find.text('Agotado'), findsNothing);
  });
}
