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

  test('POST /productos rechaza nombres duplicados normalizados con 409 e id existente', async () => {
    const creadoRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Café con leche', precio_centavos: 2500 }),
    });
    const creado = await creadoRes.json();

    for (const nombre of ['CAFÉ CON LECHE', 'Cafe con leche', 'Café   con   leche']) {
      const duplicadoRes = await fetch(`${baseUrl}/productos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nombre, precio_centavos: 2500 }),
      });

      assert.equal(duplicadoRes.status, 409);
      assert.deepEqual(await duplicadoRes.json(), {
        error: 'Ya existe un producto con ese nombre',
        id: creado.id,
      });
    }
  });

  test('POST /productos considera duplicado un producto no disponible', async () => {
    const creadoRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Pan de queso', precio_centavos: 1800, disponible: false }),
    });
    const creado = await creadoRes.json();

    const duplicadoRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'PAN DE QUESO', precio_centavos: 1800 }),
    });

    assert.equal(duplicadoRes.status, 409);
    assert.deepEqual(await duplicadoRes.json(), {
      error: 'Ya existe un producto con ese nombre',
      id: creado.id,
    });
  });

  test('PUT /productos/:id rechaza renombrar a otro producto con 409', async () => {
    const existenteRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Torta de huevo', precio_centavos: 3200 }),
    });
    const existente = await existenteRes.json();
    const productoRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Mollete sencillo', precio_centavos: 2500 }),
    });
    const producto = await productoRes.json();

    const actualizacionRes = await fetch(`${baseUrl}/productos/${producto.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'TORTA   DE HUEVO' }),
    });

    assert.equal(actualizacionRes.status, 409);
    assert.deepEqual(await actualizacionRes.json(), {
      error: 'Ya existe un producto con ese nombre',
      id: existente.id,
    });
  });

  test('PUT /productos/:id permite conservar el nombre normalizado del mismo producto', async () => {
    const creadoRes = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Café americano', precio_centavos: 3000 }),
    });
    const creado = await creadoRes.json();

    const actualizacionRes = await fetch(`${baseUrl}/productos/${creado.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: ' cafe   americano ' }),
    });

    assert.equal(actualizacionRes.status, 200);
    const actualizado = await actualizacionRes.json();
    assert.equal(actualizado.id, creado.id);
    assert.equal(actualizado.nombre, 'cafe   americano');
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
