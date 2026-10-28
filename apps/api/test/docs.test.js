const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const leer = (...ruta) => fs.readFileSync(path.join(__dirname, '..', '..', '..', ...ruta), 'utf8');

test('docs/05-datos.md tiene la fila M-06 con la alternativa categoría + temperatura', () => {
  const fila = leer('docs', '05-datos.md')
    .split('\n')
    .find((linea) => linea.startsWith('| M-06 |'));

  assert.ok(fila, 'falta la fila M-06 en la tabla de decisiones');
  assert.match(fila, /categor[ií]a/i);
  assert.match(fila, /temperatura/i);
});

test('el ERD de docs/05-datos.md tiene descripcion y tipo en PRODUCTO', () => {
  const producto = leer('docs', '05-datos.md').match(/PRODUCTO \{([^}]*)\}/);

  assert.ok(producto, 'falta la entidad PRODUCTO en el ERD');
  assert.match(producto[1], /string descripcion/);
  assert.match(producto[1], /string tipo/);
});

test('apps/api/README.md documenta el filtro tipo de GET /productos', () => {
  const readme = leer('apps', 'api', 'README.md');
  const get = readme.slice(readme.indexOf('#### `GET /productos`'), readme.indexOf('#### `GET /productos/:id`'));

  assert.match(get, /`tipo=alimento\|bebida_caliente\|bebida_fria`/);
});

test('apps/api/README.md documenta el POST de productos con descripcion y tipo', () => {
  const readme = leer('apps', 'api', 'README.md');
  const post = readme.slice(readme.indexOf('#### `POST /productos`'), readme.indexOf('#### `PUT /productos/:id`'));

  assert.match(post, /"descripcion":/);
  assert.match(post, /"tipo": "bebida_caliente"/);
  assert.match(post, /bebida_fria/);
  assert.match(post, /200/);
});
