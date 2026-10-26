const { test, describe, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/app');

describe('CRUD /usuarios', () => {
  let server;
  let baseUrl;

  beforeEach((t) => {
    server = app.listen(0);
    const { port } = server.address();
    baseUrl = `http://localhost:${port}`;
    t.after(() => server.close());
  });

  test('GET /usuarios responde 200 con lista de usuarios', async () => {
    const res = await fetch(`${baseUrl}/usuarios`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.ok(Array.isArray(body));
  });

  test('POST /usuarios crea un usuario nuevo y responde 201', async () => {
    const nuevoUsuario = {
      nombre: 'Juan Pérez',
      correo: 'juan.perez@utez.edu.mx',
    };

    const res = await fetch(`${baseUrl}/usuarios`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(nuevoUsuario),
    });

    assert.equal(res.status, 201);
    const creado = await res.json();
    assert.ok(creado.id);
    assert.equal(creado.nombre, 'Juan Pérez');
    assert.equal(creado.correo, 'juan.perez@utez.edu.mx');
  });

  test('POST /usuarios rechaza solicitud sin nombre o correo', async () => {
    const sinNombre = { correo: 'test@utez.edu.mx' };
    const res1 = await fetch(`${baseUrl}/usuarios`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(sinNombre),
    });
    assert.equal(res1.status, 400);

    const sinCorreo = { nombre: 'María' };
    const res2 = await fetch(`${baseUrl}/usuarios`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(sinCorreo),
    });
    assert.equal(res2.status, 400);
  });

  test('GET /usuarios/:id responde 200 con usuario existente o 404', async () => {
    const postRes = await fetch(`${baseUrl}/usuarios`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Ana Gómez', correo: 'ana@utez.edu.mx' }),
    });
    const usuario = await postRes.json();

    const getRes = await fetch(`${baseUrl}/usuarios/${usuario.id}`);
    assert.equal(getRes.status, 200);
    const obtenido = await getRes.json();
    assert.equal(obtenido.id, usuario.id);
    assert.equal(obtenido.nombre, 'Ana Gómez');

    const notFoundRes = await fetch(`${baseUrl}/usuarios/id-inexistente`);
    assert.equal(notFoundRes.status, 404);
  });

  test('PUT /usuarios/:id actualiza los datos del usuario', async () => {
    const postRes = await fetch(`${baseUrl}/usuarios`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Carlos Ruiz', correo: 'carlos@utez.edu.mx' }),
    });
    const usuario = await postRes.json();

    const putRes = await fetch(`${baseUrl}/usuarios/${usuario.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Carlos A. Ruiz', correo: 'carlos.ruiz@utez.edu.mx' }),
    });

    assert.equal(putRes.status, 200);
    const actualizado = await putRes.json();
    assert.equal(actualizado.nombre, 'Carlos A. Ruiz');
    assert.equal(actualizado.correo, 'carlos.ruiz@utez.edu.mx');
  });

  test('DELETE /usuarios/:id elimina al usuario', async () => {
    const postRes = await fetch(`${baseUrl}/usuarios`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Temporal', correo: 'temp@utez.edu.mx' }),
    });
    const usuario = await postRes.json();

    const deleteRes = await fetch(`${baseUrl}/usuarios/${usuario.id}`, {
      method: 'DELETE',
    });

    assert.equal(deleteRes.status, 200);

    const getRes = await fetch(`${baseUrl}/usuarios/${usuario.id}`);
    assert.equal(getRes.status, 404);
  });
});
