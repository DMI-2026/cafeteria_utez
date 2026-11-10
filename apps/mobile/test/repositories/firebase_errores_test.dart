import 'package:cafeteria_utez/core/errors/auth_failure.dart';
import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/repositories/firebase_auth_repository.dart';
import 'package:cafeteria_utez/repositories/firestore_menu_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authFailureDesde traduce los códigos de Firebase Auth', () {
    final casos = <String, Type>{
      'invalid-credential': CredencialesInvalidas,
      'wrong-password': CredencialesInvalidas,
      'user-not-found': CredencialesInvalidas,
      'invalid-email': CredencialesInvalidas,
      'email-already-in-use': CorreoYaRegistrado,
      'weak-password': ContrasenaDebil,
      'too-many-requests': DemasiadosIntentos,
      'network-request-failed': SinConexion,
      'algo-nuevo': AuthDesconocida,
    };

    casos.forEach((codigo, tipo) {
      test('$codigo -> $tipo', () {
        expect(authFailureDesde(codigo).runtimeType, tipo);
      });
    });
  });

  group('httpFailureDesde traduce los códigos de Firestore', () {
    test('permission-denied es un rechazo 403', () {
      final falla = httpFailureDesde('permission-denied');
      expect(falla, isA<ClientFailure>());
      expect((falla as ClientFailure).statusCode, 403);
    });

    test('unavailable es falta de conexión', () {
      expect(httpFailureDesde('unavailable'), isA<ConnectionFailure>());
    });

    test('cualquier otro código es desconocido', () {
      expect(httpFailureDesde('internal'), isA<UnknownFailure>());
    });
  });
}
