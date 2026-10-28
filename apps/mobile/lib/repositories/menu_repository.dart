import 'dart:convert';

import '../core/network/app_http_client.dart';
import '../models/producto.dart';

/// Acceso al menú de la cafetería.
///
/// La pantalla depende de esta interfaz, no de la API: en pruebas se sustituye
/// por un doble (patrón Repository, `docs/06-convenciones.md`).
abstract class MenuRepository {
  Future<List<Producto>> listar();

  Future<Producto> crear({
    required String nombre,
    required int precioCentavos,
    bool disponible = true,
    String descripcion = '',
    String tipo = 'alimento',
  });

  Future<Producto> actualizar(
    String id, {
    String? nombre,
    int? precioCentavos,
    bool? disponible,
    String? descripcion,
    String? tipo,
  });

  /// Baja lógica del producto: queda `disponible: false` (M-04).
  Future<Producto> darDeBaja(String id);
}

/// Implementación contra la API Express (`apps/api/src/productos.js`).
class ApiMenuRepository implements MenuRepository {
  final AppHttpClient client;
  final String baseUrl;

  ApiMenuRepository({required this.client, required this.baseUrl});

  Uri _uri([String? id]) {
    final ruta = id == null ? '$baseUrl/productos' : '$baseUrl/productos/$id';
    return Uri.parse(ruta);
  }

  Map<String, dynamic> _decodeObjeto(String body) {
    return jsonDecode(body) as Map<String, dynamic>;
  }

  @override
  Future<List<Producto>> listar() async {
    final response = await client.get(_uri());
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return data
        .map((item) => Producto.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Producto> crear({
    required String nombre,
    required int precioCentavos,
    bool disponible = true,
    String descripcion = '',
    String tipo = 'alimento',
  }) async {
    final response = await client.post(
      _uri(),
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'tipo': tipo,
        'precio_centavos': precioCentavos,
        'disponible': disponible,
      }),
    );
    return Producto.fromJson(_decodeObjeto(utf8.decode(response.bodyBytes)));
  }

  @override
  Future<Producto> actualizar(
    String id, {
    String? nombre,
    int? precioCentavos,
    bool? disponible,
    String? descripcion,
    String? tipo,
  }) async {
    final response = await client.put(
      _uri(id),
      body: jsonEncode({
        'nombre': ?nombre,
        'descripcion': ?descripcion,
        'tipo': ?tipo,
        'precio_centavos': ?precioCentavos,
        'disponible': ?disponible,
      }),
    );
    return Producto.fromJson(_decodeObjeto(utf8.decode(response.bodyBytes)));
  }

  @override
  Future<Producto> darDeBaja(String id) async {
    final response = await client.delete(_uri(id));
    return Producto.fromJson(_decodeObjeto(utf8.decode(response.bodyBytes)));
  }
}
