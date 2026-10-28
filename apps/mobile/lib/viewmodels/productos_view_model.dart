import 'package:flutter/foundation.dart';

import '../core/errors/http_failure.dart';
import '../models/producto.dart';
import '../models/tamano.dart';
import '../repositories/menu_repository.dart';

/// Estado de la pantalla de productos (patrón Observer, C-08).
class ProductosViewModel extends ChangeNotifier {
  ProductosViewModel(this._repository);

  final MenuRepository _repository;

  List<Producto> _productos = const [];
  bool _cargando = false;
  String? _error;

  List<Producto> get productos => _productos;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get vacio => !_cargando && _error == null && _productos.isEmpty;

  /// Carga el menú completo. Un fallo deja un mensaje que dice qué hacer.
  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _repository.listar();
    } on HttpFailure catch (e) {
      _productos = const [];
      _error = _mensaje(e, 'cargar el menú');
    } catch (_) {
      _productos = const [];
      _error =
          'Ocurrió un error inesperado al cargar el menú. Intenta de nuevo.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> crear({
    required String nombre,
    required int precioCentavos,
    bool disponible = true,
    List<PrecioPorTamano> tamanos = const [],
  }) {
    return _guardar(
      () => _repository.crear(
        nombre: nombre,
        precioCentavos: precioCentavos,
        disponible: disponible,
        tamanos: tamanos,
      ),
      'guardar el producto',
    );
  }

  Future<bool> actualizar(
    String id, {
    required String nombre,
    required int precioCentavos,
    required bool disponible,
    List<PrecioPorTamano>? tamanos,
  }) {
    return _guardar(
      () => _repository.actualizar(
        id,
        nombre: nombre,
        precioCentavos: precioCentavos,
        disponible: disponible,
        tamanos: tamanos,
      ),
      'guardar los cambios',
    );
  }

  /// Baja lógica: el producto queda `disponible: false` (M-04).
  Future<bool> darDeBaja(String id) {
    return _guardar(() => _repository.darDeBaja(id), 'dar de baja el producto');
  }

  Future<bool> reactivar(String id) {
    return _guardar(
      () => _repository.actualizar(id, disponible: true),
      'reactivar el producto',
    );
  }

  Future<bool> _guardar(
    Future<Producto> Function() accion,
    String queHacer,
  ) async {
    _error = null;
    try {
      await accion();
    } on HttpFailure catch (e) {
      _error = _mensaje(e, queHacer);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado al $queHacer. Intenta de nuevo.';
      notifyListeners();
      return false;
    }

    await cargar();
    return true;
  }

  String _mensaje(HttpFailure failure, String queHacer) {
    return switch (failure) {
      ConnectionFailure() =>
        'No pudimos $queHacer: revisa tu conexión e intenta de nuevo.',
      ClientFailure(:final statusCode) =>
        'El servidor rechazó los datos ($statusCode). Revisa los campos e intenta de nuevo.',
      ServerFailure(:final statusCode) =>
        'El servidor tuvo un problema ($statusCode). Intenta de nuevo más tarde.',
      UnknownFailure() =>
        'Ocurrió un error inesperado al $queHacer. Intenta de nuevo.',
    };
  }
}
