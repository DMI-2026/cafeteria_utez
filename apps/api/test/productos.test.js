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

describe('descripcion en /productos', () => {
  let server;
  let baseUrl;

  beforeEach((t) => {
    server = app.listen(0);
    const { port } = server.address();
    baseUrl = `http://localhost:${port}`;
    t.after(() => server.close());
  });

  const enviar = (metodo, ruta, cuerpo) =>
    fetch(`${baseUrl}${ruta}`, {
      method: metodo,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(cuerpo),
    });

  const crear = async (extra = {}) => {
    const res = await enviar('POST', '/productos', { nombre: 'Concha', precio_centavos: 1500, ...extra });
    return res.json();
  };

  test('POST sin descripcion la guarda como ""', async () => {
    const res = await enviar('POST', '/productos', { nombre: 'Torta', precio_centavos: 4000 });
    assert.equal(res.status, 201);
    const creado = await res.json();
    assert.equal(creado.descripcion, '');
  });

  test('POST guarda la descripcion sin espacios sobrantes', async () => {
    const res = await enviar('POST', '/productos', {
      nombre: 'Café de olla',
      precio_centavos: 3000,
      descripcion: '  Café de grano de Morelos  ',
    });
    assert.equal(res.status, 201);
    const creado = await res.json();
    assert.equal(creado.descripcion, 'Café de grano de Morelos');
  });

  for (const invalida of [123, null, { texto: 'hola' }, ['hola']]) {
    test(`POST rechaza descripcion que no es texto (${JSON.stringify(invalida)})`, async () => {
      const res = await enviar('POST', '/productos', {
        nombre: 'Jugo',
        precio_centavos: 2500,
        descripcion: invalida,
      });
      assert.equal(res.status, 400);
      const body = await res.json();
      assert.match(body.error, /descripcion/);
    });
  }

  test('POST acepta descripcion de exactamente 200 caracteres', async () => {
    const res = await enviar('POST', '/productos', {
      nombre: 'Molletes',
      precio_centavos: 3500,
      descripcion: 'a'.repeat(200),
    });
    assert.equal(res.status, 201);
    const creado = await res.json();
    assert.equal(creado.descripcion.length, 200);
  });

  test('POST rechaza descripcion de más de 200 caracteres', async () => {
    const res = await enviar('POST', '/productos', {
      nombre: 'Chilaquiles',
      precio_centavos: 5000,
      descripcion: 'a'.repeat(201),
    });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.match(body.error, /200/);
  });

  test('POST cuenta los 200 caracteres sin los espacios sobrantes', async () => {
    const res = await enviar('POST', '/productos', {
      nombre: 'Enchiladas',
      precio_centavos: 5500,
      descripcion: `  ${'a'.repeat(200)}  `,
    });
    assert.equal(res.status, 201);
  });

  test('PUT actualiza la descripcion sin espacios sobrantes', async () => {
    const producto = await crear();
    const res = await enviar('PUT', `/productos/${producto.id}`, { descripcion: '  Pan dulce de vainilla ' });
    assert.equal(res.status, 200);
    const actualizado = await res.json();
    assert.equal(actualizado.descripcion, 'Pan dulce de vainilla');
  });

  test('PUT sin descripcion conserva la que ya tenía', async () => {
    const producto = await crear({ descripcion: 'Recién horneada' });
    const res = await enviar('PUT', `/productos/${producto.id}`, { precio_centavos: 1800 });
    assert.equal(res.status, 200);
    const actualizado = await res.json();
    assert.equal(actualizado.descripcion, 'Recién horneada');
  });

  test('PUT rechaza descripcion que no es texto y no cambia el producto', async () => {
    const producto = await crear({ descripcion: 'Original' });
    const res = await enviar('PUT', `/productos/${producto.id}`, { nombre: 'Otro nombre', descripcion: 42 });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.match(body.error, /descripcion/);

    const actual = await (await fetch(`${baseUrl}/productos/${producto.id}`)).json();
    assert.equal(actual.nombre, producto.nombre);
    assert.equal(actual.descripcion, 'Original');
  });

  test('PUT rechaza descripcion de más de 200 caracteres', async () => {
    const producto = await crear();
    const res = await enviar('PUT', `/productos/${producto.id}`, { descripcion: 'a'.repeat(201) });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.match(body.error, /200/);
  });
});
