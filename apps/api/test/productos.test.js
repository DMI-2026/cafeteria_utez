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

  // ── Issue #30: POST con tamaños ─────────────────────────────────────────────

  test('POST /productos bebida con tamaños: precio_centavos es el menor y no es obligatorio enviarlo', async () => {
    // No se envía precio_centavos; debe calcularse como el menor de los tamaños
    const res = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        nombre: 'Frappé',
        tipo: 'bebida_fria',
        tamanos: [
          { tamano: 'ch', precio_centavos: 3000 },
          { tamano: 'md', precio_centavos: 4000 },
          { tamano: 'g',  precio_centavos: 5000 },
          { tamano: 'xl', precio_centavos: 6000 },
        ],
      }),
    });

    assert.equal(res.status, 201);
    const body = await res.json();
    assert.equal(body.nombre, 'Frappé');
    // precio_centavos debe ser el menor: 3000
    assert.equal(body.precio_centavos, 3000);
    assert.ok(Array.isArray(body.tamanos));
    assert.equal(body.tamanos.length, 4);
  });

  test('POST /productos tipo alimento con tamaños responde 400', async () => {
    const res = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        nombre: 'Torta',
        tipo: 'alimento',
        precio_centavos: 4000,
        tamanos: [
          { tamano: 'ch', precio_centavos: 4000 },
          { tamano: 'g',  precio_centavos: 5000 },
        ],
      }),
    });

    assert.equal(res.status, 400);
    const body = await res.json();
    assert.ok(body.error);
  });

  test('POST /productos sin tamaños sigue requiriendo precio_centavos (comportamiento actual)', async () => {
    // Sin tamanos, precio_centavos es obligatorio
    const res = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: 'Agua', tipo: 'bebida_fria' }),
    });

    assert.equal(res.status, 400);
    const body = await res.json();
    assert.ok(body.error);
  });

  test('POST /productos con tamaños ignora el precio_centavos enviado y usa el menor', async () => {
    const res = await fetch(`${baseUrl}/productos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        nombre: 'Café americano',
        tipo: 'bebida_caliente',
        precio_centavos: 9999,
        tamanos: [
          { tamano: 'g', precio_centavos: 4200 },
          { tamano: 'ch', precio_centavos: 3000 },
        ],
      }),
    });

    assert.equal(res.status, 201);
    const body = await res.json();
    assert.equal(body.precio_centavos, 3000);
    // Se devuelven ordenados ch → md → g → xl
    assert.deepEqual(body.tamanos.map((t) => t.tamano), ['ch', 'g']);
  });

  test('POST /productos con tamaños inválidos responde 400', async () => {
    const invalidos = [
      [{}],
      [{ tamano: 'mega', precio_centavos: 3000 }],
      [{ tamano: 'ch' }],
      [{ tamano: 'ch', precio_centavos: 3000 }, { tamano: 'ch', precio_centavos: 3500 }],
    ];

    for (const tamanos of invalidos) {
      const res = await fetch(`${baseUrl}/productos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nombre: 'Té helado', tipo: 'bebida_fria', tamanos }),
      });
      assert.equal(res.status, 400, JSON.stringify(tamanos));
    }
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

describe('tipo en /productos', () => {
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
    const res = await enviar('POST', '/productos', { nombre: 'Latte', precio_centavos: 3200, ...extra });
    return res.json();
  };

  test('POST sin tipo lo guarda como "alimento"', async () => {
    const res = await enviar('POST', '/productos', { nombre: 'Sope', precio_centavos: 2500 });
    assert.equal(res.status, 201);
    const creado = await res.json();
    assert.equal(creado.tipo, 'alimento');
  });

  for (const tipo of ['alimento', 'bebida_caliente', 'bebida_fria']) {
    test(`POST acepta el tipo "${tipo}"`, async () => {
      const res = await enviar('POST', '/productos', { nombre: `Prod ${tipo}`, precio_centavos: 2000, tipo });
      assert.equal(res.status, 201);
      const creado = await res.json();
      assert.equal(creado.tipo, tipo);
    });
  }

  for (const invalido of ['postre', '', null, 7, 'BEBIDA_FRIA']) {
    test(`POST rechaza tipo inválido (${JSON.stringify(invalido)})`, async () => {
      const res = await enviar('POST', '/productos', { nombre: 'Raro', precio_centavos: 1000, tipo: invalido });
      assert.equal(res.status, 400);
      const body = await res.json();
      assert.match(body.error, /tipo/);
    });
  }

  test('PUT actualiza el tipo', async () => {
    const producto = await crear({ tipo: 'bebida_caliente' });
    const res = await enviar('PUT', `/productos/${producto.id}`, { tipo: 'bebida_fria' });
    assert.equal(res.status, 200);
    const actualizado = await res.json();
    assert.equal(actualizado.tipo, 'bebida_fria');
  });

  test('PUT sin tipo conserva el que ya tenía', async () => {
    const producto = await crear({ tipo: 'bebida_fria' });
    const res = await enviar('PUT', `/productos/${producto.id}`, { precio_centavos: 3500 });
    assert.equal(res.status, 200);
    const actualizado = await res.json();
    assert.equal(actualizado.tipo, 'bebida_fria');
  });

  test('PUT rechaza tipo inválido y no cambia el producto', async () => {
    const producto = await crear({ tipo: 'bebida_caliente' });
    const res = await enviar('PUT', `/productos/${producto.id}`, { nombre: 'Otro nombre', tipo: 'postre' });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.match(body.error, /tipo/);

    const actual = await (await fetch(`${baseUrl}/productos/${producto.id}`)).json();
    assert.equal(actual.nombre, 'Latte');
    assert.equal(actual.tipo, 'bebida_caliente');
  });

  test('GET /productos?tipo=bebida_fria filtra por tipo', async () => {
    const fria = await crear({ nombre: 'Agua de jamaica', tipo: 'bebida_fria' });
    const caliente = await crear({ nombre: 'Café de olla', tipo: 'bebida_caliente' });
    const alimento = await crear({ nombre: 'Torta de milanesa', tipo: 'alimento' });

    const res = await fetch(`${baseUrl}/productos?tipo=bebida_fria`);
    assert.equal(res.status, 200);
    const lista = await res.json();
    const ids = lista.map((p) => p.id);

    assert.ok(ids.includes(fria.id));
    assert.ok(!ids.includes(caliente.id));
    assert.ok(!ids.includes(alimento.id));
    assert.ok(lista.every((p) => p.tipo === 'bebida_fria'));
  });

  test('GET /productos?tipo=alimento filtra solo alimentos', async () => {
    const alimento = await crear({ nombre: 'Sincronizada', tipo: 'alimento' });
    const fria = await crear({ nombre: 'Refresco', tipo: 'bebida_fria' });

    const res = await fetch(`${baseUrl}/productos?tipo=alimento`);
    assert.equal(res.status, 200);
    const lista = await res.json();
    const ids = lista.map((p) => p.id);

    assert.ok(ids.includes(alimento.id));
    assert.ok(!ids.includes(fria.id));
    assert.ok(lista.every((p) => p.tipo === 'alimento'));
  });

  test('GET /productos sin tipo no filtra y sigue incluyendo todos', async () => {
    const fria = await crear({ nombre: 'Limonada', tipo: 'bebida_fria' });
    const caliente = await crear({ nombre: 'Chocolate', tipo: 'bebida_caliente' });

    const res = await fetch(`${baseUrl}/productos`);
    assert.equal(res.status, 200);
    const ids = (await res.json()).map((p) => p.id);

    assert.ok(ids.includes(fria.id));
    assert.ok(ids.includes(caliente.id));
  });
});
