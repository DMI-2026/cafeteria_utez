import 'package:cafeteria_utez/models/usuario.dart';
import 'package:cafeteria_utez/repositories/fake_auth_repository.dart';
import 'package:cafeteria_utez/views/home_view.dart';
import 'package:cafeteria_utez/views/login_view.dart';
import 'package:cafeteria_utez/views/puerta_sesion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_menu_repository.dart';

Widget _app(FakeAuthRepository auth) => MaterialApp(
  home: PuertaSesionView(
    authRepository: auth,
    menuRepository: FakeMenuRepository(),
  ),
);

final _personal = Usuario(
  id: 'u-1',
  correo: 'personal@utez.edu.mx',
  nombre: 'Personal de la cafetería',
);

void main() {
  testWidgets('arranca con el indicador mientras se restaura la sesión', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
    expect(find.byType(HomeView), findsNothing);
  });

  testWidgets('sin sesión muestra el login', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);
  });

  testWidgets('con sesión restaurada muestra el menú', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository(sesionInicial: _personal)));
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
  });

  testWidgets('credenciales válidas llevan al menú', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Correo'),
      FakeAuthRepository.correoDemo,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Contraseña'),
      FakeAuthRepository.contrasenaDemo,
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
  });

  testWidgets(
    'credenciales inválidas muestran el mensaje y siguen en el login',
    (tester) async {
      await tester.pumpWidget(_app(FakeAuthRepository()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Correo'),
        FakeAuthRepository.correoDemo,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña'),
        'equivocada',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
    },
  );

  testWidgets('cerrar sesión regresa al login', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository(sesionInicial: _personal)));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);
  });
}
