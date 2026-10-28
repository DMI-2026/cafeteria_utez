import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/models/tamano.dart';
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

    test('fromJson sin tamanos deja una lista vacía', () {
      final producto = Producto.fromJson({
        'id': 'p-5',
        'nombre': 'Pan dulce',
        'precio_centavos': 1250,
      });

      expect(producto.tamanos, isEmpty);
    });

    test('fromJson lee los tamanos con su precio', () {
      final producto = Producto.fromJson({
        'id': 'p-6',
        'nombre': 'Café americano',
        'precio_centavos': 3000,
        'tamanos': [
          {'tamano': 'ch', 'precio_centavos': 3000},
          {'tamano': 'g', 'precio_centavos': 4200},
        ],
      });

      expect(producto.tamanos, hasLength(2));
      expect(producto.tamanos.first.tamano, Tamano.ch);
      expect(producto.tamanos.first.precioCentavos, 3000);
      expect(producto.tamanos.last.tamano, Tamano.g);
      expect(producto.tamanos.last.precioCentavos, 4200);
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
        'tamanos': <Map<String, dynamic>>[],
      });
    });

    test('toJson escribe los tamanos del contrato', () {
      const producto = Producto(
        id: 'p-7',
        nombre: 'Café americano',
        precioCentavos: 3000,
        disponible: true,
        tamanos: [
          PrecioPorTamano(tamano: Tamano.ch, precioCentavos: 3000),
          PrecioPorTamano(tamano: Tamano.md, precioCentavos: 3600),
        ],
      );

      expect(producto.toJson()['tamanos'], [
        {'tamano': 'ch', 'precio_centavos': 3000},
        {'tamano': 'md', 'precio_centavos': 3600},
      ]);
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
      expect(agotado.tamanos, isEmpty);
    });

    test('copyWith cambia los tamanos', () {
      const producto = Producto(
        id: 'p-8',
        nombre: 'Té',
        precioCentavos: 1000,
        disponible: true,
      );

      final conTamanos = producto.copyWith(
        tamanos: const [
          PrecioPorTamano(tamano: Tamano.xl, precioCentavos: 1500),
        ],
      );

      expect(conTamanos.tamanos, hasLength(1));
      expect(conTamanos.tamanos.single.tamano, Tamano.xl);
      expect(producto.tamanos, isEmpty);
    });

    test('precioDesde es el menor de los tamanos', () {
      const producto = Producto(
        id: 'p-9',
        nombre: 'Café americano',
        precioCentavos: 4200,
        disponible: true,
        tamanos: [
          PrecioPorTamano(tamano: Tamano.g, precioCentavos: 4200),
          PrecioPorTamano(tamano: Tamano.ch, precioCentavos: 3000),
          PrecioPorTamano(tamano: Tamano.md, precioCentavos: 3600),
        ],
      );

      expect(producto.precioDesde, 3000);
    });

    test('precioDesde usa precioCentavos cuando no hay tamanos', () {
      const producto = Producto(
        id: 'p-10',
        nombre: 'Pan dulce',
        precioCentavos: 1250,
        disponible: true,
      );

      expect(producto.precioDesde, 1250);
    });
  });
}
