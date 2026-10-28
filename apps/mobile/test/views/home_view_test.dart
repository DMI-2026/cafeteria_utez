import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/models/tamano.dart';
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
    expect(find.text('Menú vacío · agrega el primer producto'), findsOneWidget);
  });

  testWidgets('el encabezado resume cuántos productos hay', (tester) async {
    await montar(tester, FakeMenuRepository(inicial: [cafe, pan]));

    expect(find.text('Cafetería UTEZ'), findsOneWidget);
    expect(find.text('2 productos · 1 disponible'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
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

  testWidgets('crear un producto con tamaños lo muestra desde el menor', (
    tester,
  ) async {
    final repo = FakeMenuRepository();
    await montar(tester, repo);

    await tester.tap(find.byTooltip('Agregar producto'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('campo-nombre')),
      'Café americano',
    );
    await tester.tap(find.byKey(const Key('chip-tamano-g')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chip-tamano-ch')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('campo-precio-tamano-ch')),
      '30',
    );
    await tester.enterText(
      find.byKey(const Key('campo-precio-tamano-g')),
      '42',
    );
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final creado = repo.productos.single;
    expect(creado.tamanos.map((precio) => precio.tamano), [
      Tamano.ch,
      Tamano.g,
    ]);
    expect(creado.precioDesde, 3000);
    expect(find.text('Desde '), findsOneWidget);
    expect(find.text('\$30.00'), findsOneWidget);
    expect(find.text('Chico · Grande'), findsOneWidget);
  });

  testWidgets('editar un producto con tamaños cambia sus precios', (
    tester,
  ) async {
    const americano = Producto(
      id: 'p-5',
      nombre: 'Café americano',
      precioCentavos: 3000,
      disponible: true,
      tamanos: [
        PrecioPorTamano(tamano: Tamano.ch, precioCentavos: 3000),
        PrecioPorTamano(tamano: Tamano.g, precioCentavos: 4200),
      ],
    );
    final repo = FakeMenuRepository(inicial: [americano]);
    await montar(tester, repo);

    await tester.tap(find.text('Café americano'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chip-tamano-g')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(repo.productos.single.tamanos, hasLength(1));
    expect(repo.productos.single.tamanos.single.tamano, Tamano.ch);
    expect(repo.productos.single.precioDesde, 3000);
  });
}
