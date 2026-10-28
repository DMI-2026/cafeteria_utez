import 'tamano.dart';

/// Un producto del menú de la cafetería.
///
/// El precio viaja y se guarda en centavos enteros (M-01).
class Producto {
  final String id;
  final String nombre;
  final int precioCentavos;
  final bool disponible;

  /// Precio por tamaño; vacío cuando el producto no se vende por tamaños.
  final List<PrecioPorTamano> tamanos;

  const Producto({
    required this.id,
    required this.nombre,
    required this.precioCentavos,
    required this.disponible,
    this.tamanos = const [],
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      precioCentavos: (json['precio_centavos'] as num).toInt(),
      disponible: json['disponible'] as bool? ?? true,
      tamanos: (json['tamanos'] as List<dynamic>? ?? const [])
          .map((item) => PrecioPorTamano.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'precio_centavos': precioCentavos,
      'disponible': disponible,
      'tamanos': tamanos.map((precio) => precio.toJson()).toList(),
    };
  }

  /// El precio más bajo de los tamaños, o [precioCentavos] si no hay tamaños.
  int get precioDesde {
    if (tamanos.isEmpty) return precioCentavos;
    return tamanos
        .map((precio) => precio.precioCentavos)
        .reduce((menor, precio) => precio < menor ? precio : menor);
  }

  Producto copyWith({
    String? nombre,
    int? precioCentavos,
    bool? disponible,
    List<PrecioPorTamano>? tamanos,
  }) {
    return Producto(
      id: id,
      nombre: nombre ?? this.nombre,
      precioCentavos: precioCentavos ?? this.precioCentavos,
      disponible: disponible ?? this.disponible,
      tamanos: tamanos ?? this.tamanos,
    );
  }
}
