import '../models/producto.dart';
import '../models/tipo_producto.dart';

/// Acceso al menú de la cafetería.
///
/// La pantalla depende de esta interfaz, no de Firestore: en pruebas se
/// sustituye por un doble (patrón Repository, `docs/06-convenciones.md`).
abstract class MenuRepository {
  Future<List<Producto>> listar();

  Future<Producto> crear({
    required String nombre,
    required int precioCentavos,
    bool disponible = true,
    String descripcion = '',
    TipoProducto tipo = TipoProducto.alimento,
  });

  Future<Producto> actualizar(
    String id, {
    String? nombre,
    int? precioCentavos,
    bool? disponible,
    String? descripcion,
    TipoProducto? tipo,
  });

  /// Baja lógica del producto: queda `disponible: false` (M-04).
  Future<Producto> darDeBaja(String id);
}
