import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_menu_repository.dart';

void main() {
  const mensajeDuplicado = 'Ya existe un producto con ese nombre';

  Future<void> abrirYLlenar(
    WidgetTester tester,
    FakeMenuRepository repo, {
    String nombre = 'Café americano',
  }) async {
    await tester.pumpWidget(MaterialApp(home: HomeView(repository: repo)));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campo-nombre')), nombre);
    await tester.enterText(find.byKey(const Key('campo-precio')), '18.00');
  }

  testWidgets(
    'el repositorio falla con 409 → se ve el mensaje y el formulario no se cierra',
    (tester) async {
      final repo = FakeMenuRepository()
        ..fallaAlGuardar = const ClientFailure(409, message: mensajeDuplicado);
      await abrirYLlenar(tester, repo);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text(mensajeDuplicado), findsOneWidget);
      expect(find.byKey(const Key('boton-guardar')), findsOneWidget);
      expect(find.byKey(const Key('campo-nombre')), findsOneWidget);
      expect(
        tester.widget<TextFormField>(find.byKey(const Key('campo-nombre')))
            .controller!
            .text,
        'Café americano',
      );
      expect(find.textContaining('El servidor rechazó'), findsNothing);
    },
  );

  testWidgets('al editar el nombre, el mensaje de duplicado desaparece', (
    tester,
  ) async {
    final repo = FakeMenuRepository()
      ..fallaAlGuardar = const ClientFailure(409, message: mensajeDuplicado);
    await abrirYLlenar(tester, repo);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text(mensajeDuplicado), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campo-nombre')), 'Té chai');
    await tester.pump();

    expect(find.text(mensajeDuplicado), findsNothing);
    expect(find.byKey(const Key('boton-guardar')), findsOneWidget);
  });
}
