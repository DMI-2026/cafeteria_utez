import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/core/network/app_http_client.dart';
import 'package:cafeteria_utez/repositories/menu_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://localhost:3000';

  ApiMenuRepository repositoryWith(MockClient client) {
    return ApiMenuRepository(
      client: AppHttpClient(client: client),
      baseUrl: baseUrl,
    );
  }

  group('ApiMenuRepository', () {
    test('listar pega GET /productos y decodifica el JSON', () async {
      final repository = repositoryWith(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), '$baseUrl/productos');
          return http.Response(
            '[{"id":"p-1","nombre":"Café de olla","precio_centavos":1800,"disponible":true}]',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final productos = await repository.listar();

      expect(productos, hasLength(1));
      expect(productos.first.nombre, 'Café de olla');
      expect(productos.first.precioCentavos, 1800);
    });

    test('listar regresa lista vacía cuando no hay productos', () async {
      final repository = repositoryWith(
        MockClient((request) async => http.Response('[]', 200)),
      );

      expect(await repository.listar(), isEmpty);
    });

    test('crear manda precio_centavos entero (M-01)', () async {
      final repository = repositoryWith(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.toString(), '$baseUrl/productos');
          expect(request.headers['Content-Type'], contains('application/json'));
          expect(request.body, contains('"precio_centavos":1250'));
          expect(request.body, isNot(contains('12.5')));
          return http.Response(
            '{"id":"p-9","nombre":"Pan dulce","precio_centavos":1250,"disponible":true}',
            201,
          );
        }),
      );

      final producto = await repository.crear(
        nombre: 'Pan dulce',
        precioCentavos: 1250,
      );

      expect(producto.id, 'p-9');
      expect(producto.precioCentavos, 1250);
    });

    test('actualizar pega PUT /productos/:id', () async {
      final repository = repositoryWith(
        MockClient((request) async {
          expect(request.method, 'PUT');
          expect(request.url.toString(), '$baseUrl/productos/p-1');
          return http.Response(
            '{"id":"p-1","nombre":"Té chai","precio_centavos":2000,"disponible":true}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final producto = await repository.actualizar(
        'p-1',
        nombre: 'Té chai',
        precioCentavos: 2000,
      );

      expect(producto.nombre, 'Té chai');
    });

    test('darDeBaja pega DELETE /productos/:id (M-04)', () async {
      final repository = repositoryWith(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(request.url.toString(), '$baseUrl/productos/p-1');
          return http.Response(
            '{"id":"p-1","nombre":"Té chai","precio_centavos":2000,"disponible":false}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final producto = await repository.darDeBaja('p-1');

      expect(producto.disponible, isFalse);
    });

    test('propaga HttpFailure cuando la API falla', () async {
      final repository = repositoryWith(
        MockClient((request) async => http.Response('boom', 500)),
      );

      expect(repository.listar(), throwsA(isA<ServerFailure>()));
    });
  });
}
