import 'package:cafeteria_utez/core/format/nombre.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizarNombre', () {
    test('recorta, colapsa espacios y pasa a minúsculas', () {
      expect(normalizarNombre('  Café  con   Leche '), 'cafe con leche');
    });

    test('quita acentos de las vocales', () {
      expect(normalizarNombre('TÉ'), 'te');
      expect(normalizarNombre('CAFÉ CON LECHE'), 'cafe con leche');
      expect(normalizarNombre('Cafe con leche'), 'cafe con leche');
    });

    test('conserva la eñe como letra propia del español', () {
      expect(normalizarNombre('ñ'), 'ñ');
      expect(normalizarNombre('Ñ'), 'ñ');
      expect(normalizarNombre('Piña'), 'piña');
    });
  });
}
