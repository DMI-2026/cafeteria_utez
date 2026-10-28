import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/models/tamano.dart';
import 'package:cafeteria_utez/repositories/menu_repository.dart';

/// Doble en memoria del [MenuRepository] para pruebas, sin red.
class FakeMenuRepository implements MenuRepository {
  FakeMenuRepository({List<Producto>? inicial})
    : _productos = List<Producto>.of(inicial ?? const []);

  final List<Producto> _productos;
  int _secuencia = 0;

  Object? fallaAlListar;
  Object? fallaAlGuardar;
  int llamadasListar = 0;

  List<Producto> get productos => List.unmodifiable(_productos);

  @override
  Future<List<Producto>> listar() async {
    llamadasListar++;
    if (fallaAlListar != null) throw fallaAlListar!;
    return List<Producto>.unmodifiable(_productos);
  }

  @override
  Future<Producto> crear({
    required String nombre,
    required int precioCentavos,
    bool disponible = true,
    List<PrecioPorTamano> tamanos = const [],
  }) async {
    if (fallaAlGuardar != null) throw fallaAlGuardar!;
    final producto = Producto(
      id: 'fake-${++_secuencia}',
      nombre: nombre,
      precioCentavos: precioCentavos,
      disponible: disponible,
      tamanos: tamanos,
    );
    _productos.add(producto);
    return producto;
  }

  @override
  Future<Producto> actualizar(
    String id, {
    String? nombre,
    int? precioCentavos,
    bool? disponible,
    List<PrecioPorTamano>? tamanos,
  }) async {
    if (fallaAlGuardar != null) throw fallaAlGuardar!;
    final index = _productos.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw StateError('Producto $id no existe en el doble de pruebas');
    }
    _productos[index] = _productos[index].copyWith(
      nombre: nombre,
      precioCentavos: precioCentavos,
      disponible: disponible,
      tamanos: tamanos,
    );
    return _productos[index];
  }

  @override
  Future<Producto> darDeBaja(String id) => actualizar(id, disponible: false);
}
