import 'package:cafeteria_utez/main.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_menu_repository.dart';

void main() {
  testWidgets('la app arranca en el menú con los productos de la API', (
    tester,
  ) async {
    final repo = FakeMenuRepository(
      inicial: const [
        Producto(
          id: 'p-1',
          nombre: 'Café americano',
          precioCentavos: 1800,
          disponible: true,
        ),
      ],
    );

    await tester.pumpWidget(CafeteriaApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Cafetería UTEZ'), findsOneWidget);
    expect(find.text('Café americano'), findsOneWidget);
    expect(find.text('\$18.00'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
  });
}
