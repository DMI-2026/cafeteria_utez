import 'package:cafeteria_utez/core/format/dinero.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPrecio', () {
    test('formatea centavos como pesos con dos decimales', () {
      expect(formatPrecio(1250), '\$12.50');
      expect(formatPrecio(0), '\$0.00');
      expect(formatPrecio(5), '\$0.05');
      expect(formatPrecio(100000), '\$1000.00');
    });

    test('nunca usa decimales flotantes para el dinero (M-01)', () {
      expect(formatPrecio(1999), '\$19.99');
      expect(formatPrecio(1), '\$0.01');
    });
  });

  group('parsePrecioACentavos', () {
    test('convierte pesos escritos por la persona a centavos enteros', () {
      expect(parsePrecioACentavos('12.50'), 1250);
      expect(parsePrecioACentavos('12'), 1200);
      expect(parsePrecioACentavos('12.5'), 1250);
      expect(parsePrecioACentavos('0.05'), 5);
      expect(parsePrecioACentavos(' 7.25 '), 725);
      expect(parsePrecioACentavos('\$18.00'), 1800);
    });

    test('rechaza textos que no son un precio válido', () {
      expect(parsePrecioACentavos(''), isNull);
      expect(parsePrecioACentavos('   '), isNull);
      expect(parsePrecioACentavos('abc'), isNull);
      expect(parsePrecioACentavos('12.345'), isNull);
      expect(parsePrecioACentavos('-5'), isNull);
      expect(parsePrecioACentavos('12,50'), isNull);
    });
  });
}
