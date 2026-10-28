const { Router } = require('express');
const { randomUUID } = require('node:crypto');

const router = Router();

// Almacén en memoria de productos
const productos = [];

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
  const { nombre, precio_centavos, disponible } = req.body;

  if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
    return res.status(400).json({ error: 'El campo "nombre" es obligatorio y debe ser una cadena válida' });
  }

  const nombreNormalizado = nombre.trim().toLowerCase();
  const existente = productos.find((p) => p.nombre.toLowerCase() === nombreNormalizado);

  if (existente) {
    return res.status(409).json({
      error: `Ya existe un producto con ese nombre. Reactiva el existente (ID: ${existente.id}) en lugar de crear otro`,
      id: existente.id,
    });
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

  const nuevoProducto = {
    id: randomUUID(),
    nombre: nombre.trim(),
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

  const { nombre, precio_centavos, disponible } = req.body;

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
