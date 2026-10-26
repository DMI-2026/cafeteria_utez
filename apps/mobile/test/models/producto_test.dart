import 'package:cafeteria_utez/models/producto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Producto', () {
    test('fromJson lee el contrato de la API', () {
      final producto = Producto.fromJson({
        'id': 'p-1',
        'nombre': 'Café americano',
        'precio_centavos': 1800,
        'disponible': true,
      });

      expect(producto.id, 'p-1');
      expect(producto.nombre, 'Café americano');
      expect(producto.precioCentavos, 1800);
      expect(producto.disponible, isTrue);
    });

    test('fromJson asume disponible cuando la API no lo manda', () {
      final producto = Producto.fromJson({
        'id': 'p-2',
        'nombre': 'Pan dulce',
        'precio_centavos': 1250,
      });

      expect(producto.disponible, isTrue);
    });

    test('toJson regresa centavos enteros (M-01)', () {
      const producto = Producto(
        id: 'p-3',
        nombre: 'Chilaquiles',
        precioCentavos: 4500,
        disponible: false,
      );

      expect(producto.toJson(), {
        'nombre': 'Chilaquiles',
        'precio_centavos': 4500,
        'disponible': false,
      });
    });

    test('copyWith cambia solo lo indicado', () {
      const producto = Producto(
        id: 'p-4',
        nombre: 'Té',
        precioCentavos: 1000,
        disponible: true,
      );

      final agotado = producto.copyWith(disponible: false);

      expect(agotado.nombre, 'Té');
      expect(agotado.precioCentavos, 1000);
      expect(agotado.disponible, isFalse);
    });
  });
}
