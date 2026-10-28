const TAMANOS_VALIDOS = ['ch', 'md', 'g', 'xl'];

function ordenarTamanos(tamanos) {
  if (!Array.isArray(tamanos)) {
    return [];
  }

  return [...tamanos].sort(
    (a, b) => TAMANOS_VALIDOS.indexOf(a.tamano) - TAMANOS_VALIDOS.indexOf(b.tamano),
  );
}

/**
 * Valida la estructura y forma de los elementos en el arreglo de tamaños.
 * Contrato fijado en issue #5 e issue #28 (team-4).
 *
 * @param {unknown} tamanos Lista de tamaños a validar
 * @returns {string|null} Mensaje con el primer error encontrado o null si todo es válido
 */
function validarTamanos(tamanos) {
  if (!Array.isArray(tamanos)) {
    return 'El campo "tamanos" debe ser un arreglo';
  }

  const vistos = new Set();

  for (const item of tamanos) {
    if (typeof item !== 'object' || item === null || Array.isArray(item)) {
      return 'Cada elemento de "tamanos" debe ser un objeto';
    }

    if (!item.tamano || typeof item.tamano !== 'string' || !TAMANOS_VALIDOS.includes(item.tamano)) {
      return 'El campo "tamano" es obligatorio y debe ser uno de: ch, md, g, xl';
    }

    if (
      item.precio_centavos === undefined ||
      typeof item.precio_centavos !== 'number' ||
      !Number.isInteger(item.precio_centavos) ||
      item.precio_centavos < 0
    ) {
      return 'El campo "precio_centavos" de cada tamaño es obligatorio y debe ser un número entero mayor o igual a 0 (M-01)';
    }

    if (vistos.has(item.tamano)) {
      return 'No se permiten tamaños repetidos';
    }
    vistos.add(item.tamano);
  }

  tamanos.sort((a, b) => TAMANOS_VALIDOS.indexOf(a.tamano) - TAMANOS_VALIDOS.indexOf(b.tamano));

  return null;
}

module.exports = {
  validarTamanos,
  ordenarTamanos,
  TAMANOS_VALIDOS,
};
