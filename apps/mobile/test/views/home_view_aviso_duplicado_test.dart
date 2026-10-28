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

  Future<void> montar(WidgetTester tester, FakeMenuRepository repo) async {
    await tester.pumpWidget(MaterialApp(home: HomeView(repository: repo)));
    await tester.pumpAndSettle();
  }

  Future<void> capturarProducto(
    WidgetTester tester, {
    required String nombre,
  }) async {
    await tester.tap(find.byTooltip('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campo-nombre')), nombre);
    await tester.enterText(find.byKey(const Key('campo-precio')), '20.00');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
  }

  testWidgets('un nombre duplicado en la lista muestra el aviso local', (
    tester,
  ) async {
    await montar(tester, FakeMenuRepository(inicial: [cafe]));

    await capturarProducto(tester, nombre: '  cafe   AMERICANO ');

    expect(find.byKey(const Key('aviso-duplicado')), findsOneWidget);
    expect(find.textContaining('Ya hay un producto con ese nombre'), findsOneWidget);
  });

  testWidgets('cancelar el aviso no envía la petición', (tester) async {
    final repo = FakeMenuRepository(inicial: [cafe]);
    await montar(tester, repo);

    await capturarProducto(tester, nombre: 'Café americano');
    await tester.tap(find.byKey(const Key('aviso-duplicado-cancelar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('aviso-duplicado')), findsNothing);
    expect(repo.productos, hasLength(1));
  });

  testWidgets('enviar desde el aviso crea el producto', (tester) async {
    final repo = FakeMenuRepository(inicial: [cafe]);
    await montar(tester, repo);

    await capturarProducto(tester, nombre: 'Café americano');
    await tester.tap(find.byKey(const Key('aviso-duplicado-enviar')));
    await tester.pumpAndSettle();

    expect(repo.productos, hasLength(2));
  });

  testWidgets('al editar, el propio producto no dispara el aviso', (
    tester,
  ) async {
    final repo = FakeMenuRepository(inicial: [cafe]);
    await montar(tester, repo);

    await tester.tap(find.text('Café americano'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('campo-nombre')),
      'CAFÉ AMERICANO',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('aviso-duplicado')), findsNothing);
    expect(repo.productos.single.nombre, 'CAFÉ AMERICANO');
  });
}
