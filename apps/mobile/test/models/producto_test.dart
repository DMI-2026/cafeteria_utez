import 'package:cafeteria_utez/models/producto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Producto', () {
    test('fromJson lee el contrato de la API', () {
      final producto = Producto.fromJson({
        'id': 'p-1',
        'nombre': 'Café americano',
        'descripcion': 'Café de grano de Morelos',
        'tipo': 'bebida_caliente',
        'precio_centavos': 1800,
        'disponible': true,
      });

      expect(producto.id, 'p-1');
      expect(producto.descripcion, 'Café de grano de Morelos');
      expect(producto.tipo, 'bebida_caliente');
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

    test(
      'fromJson usa los valores por defecto si faltan descripcion y tipo',
      () {
        final producto = Producto.fromJson({
          'id': 'p-5',
          'nombre': 'Concha',
          'precio_centavos': 1500,
        });

        expect(producto.descripcion, '');
        expect(producto.tipo, 'alimento');
      },
    );

    test('toJson regresa centavos enteros (M-01)', () {
      const producto = Producto(
        id: 'p-3',
        nombre: 'Chilaquiles',
        precioCentavos: 4500,
        disponible: false,
        descripcion: 'Con pollo y crema',
        tipo: 'alimento',
      );

      expect(producto.toJson(), {
        'nombre': 'Chilaquiles',
        'descripcion': 'Con pollo y crema',
        'tipo': 'alimento',
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

    test('copyWith conserva y cambia descripcion y tipo', () {
      const producto = Producto(
        id: 'p-6',
        nombre: 'Moka',
        precioCentavos: 3000,
        disponible: true,
        descripcion: 'Con chocolate',
        tipo: 'bebida_caliente',
      );

      expect(
        producto.copyWith(precioCentavos: 3200).descripcion,
        'Con chocolate',
      );
      expect(producto.copyWith(precioCentavos: 3200).tipo, 'bebida_caliente');

      final fria = producto.copyWith(
        tipo: 'bebida_fria',
        descripcion: 'Frappé',
      );
      expect(fria.tipo, 'bebida_fria');
      expect(fria.descripcion, 'Frappé');
    });
  });
}
