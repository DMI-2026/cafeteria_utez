import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cafeteria_utez/core/network/app_http_client.dart';
import 'package:cafeteria_utez/main.dart';

void main() {
  testWidgets('Muestra estado de conexion exitosa con el backend', (
    tester,
  ) async {
    final mockClient = MockClient((request) async {
      return http.Response('{"status":"ok"}', 200);
    });
    final client = AppHttpClient(client: mockClient);

    await tester.pumpWidget(CafeteriaApp(httpClient: client));
    await tester.pumpAndSettle();

    expect(find.text('Cafetería UTEZ'), findsOneWidget);
    expect(find.text('Conexión Exitosa'), findsOneWidget);
    expect(find.textContaining('Conectado al backend'), findsOneWidget);
  });

  testWidgets(
    'Muestra mensaje de error cuando falla la conexion con el backend',
    (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });
      final client = AppHttpClient(client: mockClient);

      await tester.pumpWidget(CafeteriaApp(httpClient: client));
      await tester.pumpAndSettle();

      expect(find.text('Sin Conexión con Backend'), findsOneWidget);
      expect(
        find.textContaining('Error en servidor HTTP (500)'),
        findsOneWidget,
      );
    },
  );
}
