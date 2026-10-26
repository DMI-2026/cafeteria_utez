/// Formato y captura de dinero en pesos mexicanos con centavos enteros (M-01).
library;

/// Convierte centavos enteros a texto con pesos y dos decimales.
///
/// Usa aritmética entera: nunca convierte a `double` (M-01).
String formatPrecio(int centavos) {
  final signo = centavos < 0 ? '-' : '';
  final absoluto = centavos.abs();
  final pesos = absoluto ~/ 100;
  final resto = (absoluto % 100).toString().padLeft(2, '0');
  return '$signo\$$pesos.$resto';
}

/// Convierte lo que escribe la persona (pesos) a centavos enteros.
///
/// Acepta `12`, `12.5`, `12.50` y `$12.50`. Regresa `null` si el texto no es
/// un precio válido: vacío, negativo, letras o más de dos decimales.
int? parsePrecioACentavos(String texto) {
  final limpio = texto.replaceAll('\$', '').trim();
  if (limpio.isEmpty) return null;
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(limpio)) return null;

  final partes = limpio.split('.');
  final pesos = int.tryParse(partes[0]);
  if (pesos == null) return null;

  final decimales = partes.length == 2 ? partes[1].padRight(2, '0') : '00';
  final centavos = int.tryParse(decimales);
  if (centavos == null) return null;

  return pesos * 100 + centavos;
}
