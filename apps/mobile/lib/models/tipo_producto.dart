/// Tipo de producto del menú (M-06 · contrato de #5).
///
/// En el JSON viaja como texto: `alimento`, `bebida_caliente` o `bebida_fria`.
enum TipoProducto {
  alimento('alimento'),
  bebidaCaliente('bebida_caliente'),
  bebidaFria('bebida_fria');

  /// Texto con el que la API recibe y devuelve el tipo.
  final String json;

  const TipoProducto(this.json);

  /// Si el tipo no viene o no se reconoce, es `alimento` (compatibilidad).
  static TipoProducto fromJson(String? valor) {
    for (final tipo in values) {
      if (tipo.json == valor) return tipo;
    }
    return alimento;
  }
}
