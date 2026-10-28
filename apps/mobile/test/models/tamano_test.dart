import 'package:cafeteria_utez/models/tamano.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tamano', () {
    test('usa los códigos del contrato en orden', () {
      expect(Tamano.values.map((tamano) => tamano.codigo), [
        'ch',
        'md',
        'g',
        'xl',
      ]);
    });

    test('tiene etiqueta legible', () {
      expect(Tamano.ch.etiqueta, 'Chico');
      expect(Tamano.md.etiqueta, 'Mediano');
      expect(Tamano.g.etiqueta, 'Grande');
      expect(Tamano.xl.etiqueta, 'Extra grande');
    });

    test('desdeCodigo regresa el tamaño del contrato', () {
      expect(Tamano.desdeCodigo('ch'), Tamano.ch);
      expect(Tamano.desdeCodigo('xl'), Tamano.xl);
    });

    test('desdeCodigo falla con un valor desconocido', () {
      expect(
        () => Tamano.desdeCodigo('xxl'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PrecioPorTamano', () {
    test('fromJson lee tamano y precio_centavos', () {
      final precio = PrecioPorTamano.fromJson({
        'tamano': 'g',
        'precio_centavos': 4200,
      });

      expect(precio.tamano, Tamano.g);
      expect(precio.precioCentavos, 4200);
    });

    test('toJson regresa el contrato del issue #5', () {
      const precio = PrecioPorTamano(
        tamano: Tamano.ch,
        precioCentavos: 3000,
      );

      expect(precio.toJson(), {'tamano': 'ch', 'precio_centavos': 3000});
    });

    test('fromJson falla si el tamaño no existe', () {
      expect(
        () => PrecioPorTamano.fromJson({
          'tamano': 'xxl',
          'precio_centavos': 1000,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson falla si falta el precio', () {
      expect(
        () => PrecioPorTamano.fromJson({'tamano': 'ch'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson falla si falta el tamaño', () {
      expect(
        () => PrecioPorTamano.fromJson({'precio_centavos': 1000}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
