const { Router } = require('express');
const { randomUUID } = require('node:crypto');

const router = Router();

// Almacén en memoria de usuarios
const usuarios = [];

// GET /usuarios
router.get('/', (req, res) => {
  res.json(usuarios);
});

// GET /usuarios/:id
router.get('/:id', (req, res) => {
  const usuario = usuarios.find((u) => u.id === req.params.id);
  if (!usuario) {
    return res.status(404).json({ error: 'Usuario no encontrado' });
  }
  res.json(usuario);
});

// POST /usuarios
router.post('/', (req, res) => {
  const { nombre, correo } = req.body;

  if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
    return res.status(400).json({ error: 'El campo "nombre" es obligatorio y debe ser una cadena válida' });
  }

  if (!correo || typeof correo !== 'string' || correo.trim() === '' || !correo.includes('@')) {
    return res.status(400).json({ error: 'El campo "correo" es obligatorio y debe ser un correo válido' });
  }

  const nuevoUsuario = {
    id: randomUUID(),
    nombre: nombre.trim(),
    correo: correo.trim().toLowerCase(),
  };

  usuarios.push(nuevoUsuario);
  res.status(201).json(nuevoUsuario);
});

// PUT /usuarios/:id
router.put('/:id', (req, res) => {
  const index = usuarios.findIndex((u) => u.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Usuario no encontrado' });
  }

  const { nombre, correo } = req.body;

  if (nombre !== undefined) {
    if (typeof nombre !== 'string' || nombre.trim() === '') {
      return res.status(400).json({ error: 'El campo "nombre" debe ser una cadena no vacía' });
    }
    usuarios[index].nombre = nombre.trim();
  }

  if (correo !== undefined) {
    if (typeof correo !== 'string' || correo.trim() === '' || !correo.includes('@')) {
      return res.status(400).json({ error: 'El campo "correo" debe ser un correo válido' });
    }
    usuarios[index].correo = correo.trim().toLowerCase();
  }

  res.json(usuarios[index]);
});

// DELETE /usuarios/:id
router.delete('/:id', (req, res) => {
  const index = usuarios.findIndex((u) => u.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Usuario no encontrado' });
  }

  const [eliminado] = usuarios.splice(index, 1);
  res.json(eliminado);
});

module.exports = router;
