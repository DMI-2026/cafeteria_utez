/// Tamaños de bebida del contrato de datos (issue #5).
///
/// Los códigos viajan en el JSON; las etiquetas son lo que se muestra.
enum Tamano {
  ch('ch', 'Chico'),
  md('md', 'Mediano'),
  g('g', 'Grande'),
  xl('xl', 'Extra grande');

  const Tamano(this.codigo, this.etiqueta);

  /// Valor que usa la API: `ch`, `md`, `g`, `xl`.
  final String codigo;

  /// Nombre para la persona que lee la pantalla.
  final String etiqueta;

  /// Lee el código del contrato. Un valor desconocido es un error claro, no un
  /// crash silencioso (criterio del issue #35).
  static Tamano desdeCodigo(String codigo) {
    for (final tamano in Tamano.values) {
      if (tamano.codigo == codigo) return tamano;
    }
    throw FormatException(
      'Tamaño desconocido: "$codigo". '
      'Los válidos son: ${Tamano.values.map((t) => t.codigo).join(', ')}.',
    );
  }
}

/// Precio de un producto en un tamaño concreto (contrato del issue #5).
class PrecioPorTamano {
  final Tamano tamano;

  /// Precio en centavos enteros (M-01).
  final int precioCentavos;

  const PrecioPorTamano({required this.tamano, required this.precioCentavos});

  factory PrecioPorTamano.fromJson(Map<String, dynamic> json) {
    final codigo = json['tamano'];
    if (codigo is! String) {
      throw const FormatException(
        'El campo "tamano" es obligatorio y debe ser texto.',
      );
    }

    final precio = json['precio_centavos'];
    if (precio is! num) {
      throw const FormatException(
        'El campo "precio_centavos" es obligatorio y debe ser un número.',
      );
    }

    return PrecioPorTamano(
      tamano: Tamano.desdeCodigo(codigo),
      precioCentavos: precio.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tamano': tamano.codigo, 'precio_centavos': precioCentavos};
  }
}
