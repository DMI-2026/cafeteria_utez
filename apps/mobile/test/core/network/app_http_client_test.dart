import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/core/network/app_http_client.dart';

void main() {
  group('AppHttpClient', () {
    test('realiza peticion GET exitosa con 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"status":"ok"}', 200);
      });

      final client = AppHttpClient(client: mockClient);
      final response = await client.get(
        Uri.parse('http://localhost:3000/health'),
      );

      expect(response.statusCode, 200);
      expect(response.body, '{"status":"ok"}');
    });

    test(
      'agrega header Authorization con Bearer token cuando se provee',
      () async {
        late http.Request capturedRequest;
        final mockClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response('{"ok":true}', 200);
        });

        final client = AppHttpClient(
          client: mockClient,
          authToken: 'test-token-123',
        );
        await client.get(Uri.parse('https://api.cafeteria.utez.mx/perfil'));

        expect(
          capturedRequest.headers['Authorization'],
          'Bearer test-token-123',
        );
        expect(capturedRequest.url.scheme, 'https');
      },
    );

    test('acepta y ejecuta conexiones http para desarrollo local', () async {
      late Uri capturedUri;
      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response('{"ok":true}', 200);
      });

      final client = AppHttpClient(client: mockClient);
      await client.get(Uri.parse('http://localhost:3000/productos'));

      expect(capturedUri.scheme, 'http');
      expect(capturedUri.host, 'localhost');
      expect(capturedUri.port, 3000);
    });

    test('lanza ConnectionFailure ante error de conexion o timeout', () async {
      final mockClient = MockClient((request) async {
        throw const SocketException('Connection refused');
      });

      final client = AppHttpClient(client: mockClient);

      expect(
        () => client.get(Uri.parse('http://localhost:3000/health')),
        throwsA(isA<ConnectionFailure>()),
      );
    });

    test('lanza ClientFailure cuando la respuesta es 4xx', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":"No encontrado"}', 404);
      });

      final client = AppHttpClient(client: mockClient);

      try {
        await client.get(Uri.parse('http://localhost:3000/no-existe'));
        fail('Debería haber lanzado ClientFailure');
      } on ClientFailure catch (e) {
        expect(e.statusCode, 404);
        expect(e.body, contains('No encontrado'));
      }
    });

    test('lanza ServerFailure cuando la respuesta es 5xx', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final client = AppHttpClient(client: mockClient);

      try {
        await client.get(Uri.parse('http://localhost:3000/error'));
        fail('Debería haber lanzado ServerFailure');
      } on ServerFailure catch (e) {
        expect(e.statusCode, 500);
      }
    });

    test('lanza UnknownFailure ante una excepcion no contemplada', () async {
      final mockClient = MockClient((request) async {
        throw const FormatException('Formato invalido inesperado');
      });

      final client = AppHttpClient(client: mockClient);

      expect(
        () => client.get(Uri.parse('http://localhost:3000/health')),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });
}
