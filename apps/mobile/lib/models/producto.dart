/// Un producto del menú de la cafetería.
///
/// El precio viaja y se guarda en centavos enteros (M-01).
class Producto {
  final String id;
  final String nombre;
  final int precioCentavos;
  final bool disponible;
  final String descripcion;
  final String tipo;

  const Producto({
    required this.id,
    required this.nombre,
    required this.precioCentavos,
    required this.disponible,
    this.descripcion = '',
    this.tipo = 'alimento',
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      precioCentavos: (json['precio_centavos'] as num).toInt(),
      disponible: json['disponible'] as bool? ?? true,
      descripcion: json['descripcion'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'alimento',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'precio_centavos': precioCentavos,
      'disponible': disponible,
    };
  }

  Producto copyWith({
    String? nombre,
    int? precioCentavos,
    bool? disponible,
    String? descripcion,
    String? tipo,
  }) {
    return Producto(
      id: id,
      nombre: nombre ?? this.nombre,
      precioCentavos: precioCentavos ?? this.precioCentavos,
      disponible: disponible ?? this.disponible,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
    );
  }
}
