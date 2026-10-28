/// Normalización de nombres de producto para comparar duplicados.
library;

/// Marca temporal que protege la eñe mientras se quitan los demás acentos.
const _marcadorEne = '\u0000';

/// Vocales y consonantes latinas con diacrítico que sí se reducen a su letra base.
///
/// La eñe no aparece aquí a propósito: en español es una letra propia, no una
/// n con acento, así que se conserva al comparar nombres.
const _diacriticos = <String, String>{
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'ã': 'a',
  'å': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ç': 'c',
};

/// Deja el nombre listo para comparar duplicados: recorta, colapsa espacios
/// internos, pasa a minúsculas y quita acentos, conservando la eñe.
///
/// Replica el contrato de team-1 (#7) sin agregar paquetes: `'  Café  con
/// Leche '` y `'CAFÉ CON LECHE'` producen `'cafe con leche'`, mientras que
/// `'Piña'` sigue siendo `'piña'`.
String normalizarNombre(String nombre) {
  final colapsado = nombre.trim().replaceAll(RegExp(r'\s+'), ' ');
  final protegido = colapsado.toLowerCase().replaceAll('ñ', _marcadorEne);
  final sinMarcas = protegido
      .split('')
      .map((caracter) => _diacriticos[caracter] ?? caracter)
      .join();
  return sinMarcas.replaceAll(_marcadorEne, 'ñ');
}
