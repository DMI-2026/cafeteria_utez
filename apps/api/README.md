# API · Cafetería de la UTEZ

Backend en Node 22 o 24 con Express (decisión D-03 de `docs/01-alcance.md`).

## Estado en la semana 8

- `GET /health` responde `200` con `{ "status": "ok" }`, con su prueba en `test/health.test.js`.
- Las rutas del menú y los pedidos llegan en las semanas 9 y 10.

## Comandos

```bash
npm install      # una vez
npm start        # http://localhost:3000/health
npm test         # node --test, sin frameworks extra (C-05)
```
