import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/models/tipo_producto.dart';
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
      expect(producto.tipo, TipoProducto.bebidaCaliente);
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
        expect(producto.tipo, TipoProducto.alimento);
      },
    );

    test('toJson regresa centavos enteros (M-01)', () {
      const producto = Producto(
        id: 'p-3',
        nombre: 'Chilaquiles',
        precioCentavos: 4500,
        disponible: false,
        descripcion: 'Con pollo y crema',
        tipo: TipoProducto.alimento,
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
        tipo: TipoProducto.bebidaCaliente,
      );

      expect(
        producto.copyWith(precioCentavos: 3200).descripcion,
        'Con chocolate',
      );
      expect(
        producto.copyWith(precioCentavos: 3200).tipo,
        TipoProducto.bebidaCaliente,
      );

      final fria = producto.copyWith(
        tipo: TipoProducto.bebidaFria,
        descripcion: 'Frappé',
      );
      expect(fria.tipo, TipoProducto.bebidaFria);
      expect(fria.descripcion, 'Frappé');
    });

    test('toJson manda el tipo con el texto del contrato', () {
      const producto = Producto(
        id: 'p-7',
        nombre: 'Frappé de moka',
        precioCentavos: 4500,
        disponible: true,
        tipo: TipoProducto.bebidaFria,
      );

      expect(producto.toJson()['tipo'], 'bebida_fria');
    });

    test('fromJson con un tipo desconocido usa alimento', () {
      final producto = Producto.fromJson({
        'id': 'p-8',
        'nombre': 'Combo',
        'precio_centavos': 6000,
        'tipo': 'postre',
      });

      expect(producto.tipo, TipoProducto.alimento);
    });
  });

  group('TipoProducto', () {
    test('fromJson y json van y vienen con los 3 valores del contrato', () {
      expect(TipoProducto.fromJson('alimento'), TipoProducto.alimento);
      expect(
        TipoProducto.fromJson('bebida_caliente'),
        TipoProducto.bebidaCaliente,
      );
      expect(TipoProducto.fromJson('bebida_fria'), TipoProducto.bebidaFria);
      expect(TipoProducto.values.map((t) => t.json), [
        'alimento',
        'bebida_caliente',
        'bebida_fria',
      ]);
    });

    test('fromJson sin valor usa alimento', () {
      expect(TipoProducto.fromJson(null), TipoProducto.alimento);
    });
  });
}
