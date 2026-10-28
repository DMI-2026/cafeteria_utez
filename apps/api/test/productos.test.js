const { test, describe, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/app');

describe('CRUD /productos', () => {
  let server;
  let baseUrl;

  beforeEach((t) => {
    server = app.listen(0);
    const { port } = server.address();
    baseUrl = `http://localhost:${port}`;
    t.after(() => server.close());
  });

  test('GET /productos responde 200 con lista de productos', async () => {
    const res = await fetch(`${baseUrl}/productos`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.ok(Array.isArray(body));
  });

  test('POST /productos crea un producto nuevo y responde 201', async () => {
    const nuevoProducto = {
      nombre: 'Café Americano',
      precio_centavos: 3500,
      disponible: true,
    };

    const res = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(nuevoProducto),
    });

    assert.equal(res.status, 201);
    const creado = await res.json();
    assert.ok(creado.id);
    assert.equal(creado.nombre, 'Café Americano');
    assert.equal(creado.precio_centavos, 3500);
    assert.equal(creado.disponible, true);
  });

  test('POST /productos valida que precio_centavos sea un entero positivo (M-01)', async () => {
    const conDecimal = {
      nombre: 'Galleta',
      precio_centavos: 15.5,
    };

    const res = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(conDecimal),
    });

    assert.equal(res.status, 400);
    const body = await res.json();
    assert.ok(body.error);
  });

  test('POST /productos rechaza producto sin nombre', async () => {
    const res = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ precio_centavos: 2000 }),
    });

    assert.equal(res.status, 400);
  });

  test('GET /productos/:id responde 200 si existe o 404 si no', async () => {
    const postRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Té Chai', precio_centavos: 4000 }),
    });
    const producto = await postRes.json();

    const getRes = await fetch(`${baseUrl}/productos/${producto.id}`);
    assert.equal(getRes.status, 200);
    const obtenido = await getRes.json();
    assert.equal(obtenido.id, producto.id);

    const notFoundRes = await fetch(`${baseUrl}/productos/id-inexistente`);
    assert.equal(notFoundRes.status, 404);
  });

  test('PUT /productos/:id actualiza los datos del producto', async () => {
    const postRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Mollete', precio_centavos: 2500 }),
    });
    const producto = await postRes.json();

    const putRes = await fetch(`${baseUrl}/productos/${producto.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Mollete con Jamón', precio_centavos: 3000, disponible: true }),
    });

    assert.equal(putRes.status, 200);
    const actualizado = await putRes.json();
    assert.equal(actualizado.nombre, 'Mollete con Jamón');
    assert.equal(actualizado.precio_centavos, 3000);
  });

  test('PUT /productos/:id permite renombrar a su propio nombre aunque cambien mayúsculas', async () => {
    const postRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Agua de jamaica', precio_centavos: 2000 }),
    });
    const producto = await postRes.json();

    const putRes = await fetch(`${baseUrl}/productos/${producto.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'AGUA DE JAMAICA' }),
    });

    assert.equal(putRes.status, 200);
    const actualizado = await putRes.json();
    assert.equal(actualizado.id, producto.id);
    assert.equal(actualizado.nombre, 'AGUA DE JAMAICA');
  });

  test('PUT /productos/:id responde 409 con el id del otro producto al renombrar a un nombre ocupado', async () => {
    const otroRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Chilaquiles verdes', precio_centavos: 5500 }),
    });
    const otro = await otroRes.json();

    const postRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Enchiladas suizas', precio_centavos: 6000 }),
    });
    const producto = await postRes.json();

    const putRes = await fetch(`${baseUrl}/productos/${producto.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Chilaquiles Verdes' }),
    });

    assert.equal(putRes.status, 409);
    assert.deepEqual(await putRes.json(), {
      error: 'Ya existe un producto con ese nombre',
      id: otro.id,
    });

    // El producto conserva su nombre original
    const getRes = await fetch(`${baseUrl}/productos/${producto.id}`);
    const sinCambios = await getRes.json();
    assert.equal(sinCambios.nombre, 'Enchiladas suizas');
  });

  test('DELETE /productos/:id aplica borrado lógico marcando disponible: false (M-04)', async () => {
    const postRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Capuchino', precio_centavos: 4500, disponible: true }),
    });
    const producto = await postRes.json();

    const deleteRes = await fetch(`${baseUrl}/productos/${producto.id}`, {
      method: 'DELETE',
    });

    assert.equal(deleteRes.status, 200);
    const desactivado = await deleteRes.json();
    assert.equal(desactivado.disponible, false);

    // Al consultar de nuevo, sigue existiendo pero disponible es false
    const getRes = await fetch(`${baseUrl}/productos/${producto.id}`);
    assert.equal(getRes.status, 200);
    const obtenido = await getRes.json();
    assert.equal(obtenido.disponible, false);
  });
});
