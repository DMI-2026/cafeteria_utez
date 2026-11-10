import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/errors/http_failure.dart';
import '../models/producto.dart';
import '../models/tipo_producto.dart';
import 'menu_repository.dart';

/// Traduce el código de error de Firestore a los fallos que
/// [ProductosViewModel] ya sabe mostrar. No hay HTTP aquí: es una
/// equivalencia aproximada que evita tocar el ViewModel.
HttpFailure httpFailureDesde(String codigo) => switch (codigo) {
  'permission-denied' => const ClientFailure(403),
  'unavailable' || 'deadline-exceeded' => const ConnectionFailure(),
  _ => UnknownFailure('Firestore: $codigo'),
};

/// Menú en Cloud Firestore (colección `productos`).
class FirestoreMenuRepository implements MenuRepository {
  FirestoreMenuRepository({FirebaseFirestore? firestore})
    : _productos = (firestore ?? FirebaseFirestore.instance).collection(
        'productos',
      );

  final CollectionReference<Map<String, dynamic>> _productos;

  /// El id vive en el documento, no en sus campos: se agrega al leer.
  Producto _aProducto(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Producto.fromJson({...?doc.data(), 'id': doc.id});

  Future<T> _intentar<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on FirebaseException catch (e) {
      throw httpFailureDesde(e.code);
    }
  }

  @override
  Future<List<Producto>> listar() => _intentar(() async {
    final consulta = await _productos.orderBy('nombre').get();
    return consulta.docs.map(_aProducto).toList(growable: false);
  });

  @override
  Future<Producto> crear({
    required String nombre,
    required int precioCentavos,
    bool disponible = true,
    String descripcion = '',
    TipoProducto tipo = TipoProducto.alimento,
  }) => _intentar(() async {
    final nuevo = Producto(
      id: '',
      nombre: nombre,
      precioCentavos: precioCentavos,
      disponible: disponible,
      descripcion: descripcion,
      tipo: tipo,
    );
    final ref = await _productos.add(nuevo.toJson());
    return _aProducto(await ref.get());
  });

  @override
  Future<Producto> actualizar(
    String id, {
    String? nombre,
    int? precioCentavos,
    bool? disponible,
    String? descripcion,
    TipoProducto? tipo,
  }) => _intentar(() async {
    // Solo los campos que llegan: igual que el PUT de la API.
    await _productos.doc(id).update({
      'nombre': ?nombre,
      'precio_centavos': ?precioCentavos,
      'disponible': ?disponible,
      'descripcion': ?descripcion,
      'tipo': ?tipo?.json,
    });
    return _aProducto(await _productos.doc(id).get());
  });

  /// Baja lógica (M-04): nunca se borra el documento.
  @override
  Future<Producto> darDeBaja(String id) => actualizar(id, disponible: false);
}
