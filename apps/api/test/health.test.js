const { test } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/app');

test('GET /health responde 200 con status ok', async (t) => {
  const server = app.listen(0); // puerto libre que asigna el sistema
  t.after(() => server.close());
  const { port } = server.address();

  const res = await fetch(`http://localhost:${port}/health`);

  assert.equal(res.status, 200);
  assert.deepEqual(await res.json(), { status: 'ok' });
});

test('CORS permite peticiones de origen cruzado', async (t) => {
  const server = app.listen(0);
  t.after(() => server.close());
  const { port } = server.address();

  const res = await fetch(`http://localhost:${port}/health`, {
    headers: { Origin: 'http://localhost:5000' },
  });

  assert.equal(res.headers.get('access-control-allow-origin'), '*');
});
