const { Router } = require('express');
const { randomUUID } = require('node:crypto');

const router = Router();

// Almacén en memoria de productos
const productos = [];

const DESCRIPCION_MAX = 200;

// Devuelve { valor } con la descripción limpia o { error } si no es válida (contrato de #5)
function validarDescripcion(descripcion) {
  if (typeof descripcion !== 'string') {
    return { error: 'El campo "descripcion" debe ser texto' };
  }
  const limpia = descripcion.trim();
  if (limpia.length > DESCRIPCION_MAX) {
    return { error: `El campo "descripcion" no puede pasar de ${DESCRIPCION_MAX} caracteres` };
  }
  return { valor: limpia };
}

// GET /productos
router.get('/', (req, res) => {
  const { disponible } = req.query;
  if (disponible !== undefined) {
    const isDisp = disponible === 'true';
    return res.json(productos.filter((p) => p.disponible === isDisp));
  }
  res.json(productos);
});

// GET /productos/:id
router.get('/:id', (req, res) => {
  const producto = productos.find((p) => p.id === req.params.id);
  if (!producto) {
    return res.status(404).json({ error: 'Producto no encontrado' });
  }
  res.json(producto);
});

// POST /productos
router.post('/', (req, res) => {
  const { nombre, precio_centavos, disponible, descripcion = '' } = req.body;

  if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
    return res.status(400).json({ error: 'El campo "nombre" es obligatorio y debe ser una cadena válida' });
  }

  if (
    precio_centavos === undefined ||
    typeof precio_centavos !== 'number' ||
    !Number.isInteger(precio_centavos) ||
    precio_centavos < 0
  ) {
    return res.status(400).json({
      error: 'El campo "precio_centavos" es obligatorio, debe ser un número entero mayor o igual a 0 (M-01)',
    });
  }

  const desc = validarDescripcion(descripcion);
  if (desc.error) {
    return res.status(400).json({ error: desc.error });
  }

  const nuevoProducto = {
    id: randomUUID(),
    nombre: nombre.trim(),
    descripcion: desc.valor,
    precio_centavos,
    disponible: disponible !== undefined ? Boolean(disponible) : true,
  };

  productos.push(nuevoProducto);
  res.status(201).json(nuevoProducto);
});

// PUT /productos/:id
router.put('/:id', (req, res) => {
  const index = productos.findIndex((p) => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Producto no encontrado' });
  }

  const { nombre, precio_centavos, disponible, descripcion } = req.body;

  // Se valida antes de modificar nada para no dejar cambios a medias
  let desc;
  if (descripcion !== undefined) {
    desc = validarDescripcion(descripcion);
    if (desc.error) {
      return res.status(400).json({ error: desc.error });
    }
  }

  if (nombre !== undefined) {
    if (typeof nombre !== 'string' || nombre.trim() === '') {
      return res.status(400).json({ error: 'El campo "nombre" debe ser una cadena no vacía' });
    }
    productos[index].nombre = nombre.trim();
  }

  if (precio_centavos !== undefined) {
    if (typeof precio_centavos !== 'number' || !Number.isInteger(precio_centavos) || precio_centavos < 0) {
      return res.status(400).json({
        error: 'El campo "precio_centavos" debe ser un número entero mayor o igual a 0 (M-01)',
      });
    }
    productos[index].precio_centavos = precio_centavos;
  }

  if (desc) {
    productos[index].descripcion = desc.valor;
  }

  if (disponible !== undefined) {
    productos[index].disponible = Boolean(disponible);
  }

  res.json(productos[index]);
});

// DELETE /productos/:id (Borrado lógico: marca disponible: false según M-04)
router.delete('/:id', (req, res) => {
  const producto = productos.find((p) => p.id === req.params.id);
  if (!producto) {
    return res.status(404).json({ error: 'Producto no encontrado' });
  }

  producto.disponible = false;
  res.json(producto);
});

module.exports = router;
