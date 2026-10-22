# Cafetería de la UTEZ

Que la comunidad universitaria haga pedidos a la cafetería desde el celular y los recoja sin hacer fila.

Proyecto de clase de Desarrollo Móvil Integral (10.º cuatrimestre, DATID, UTEZ), a cargo del Ing. Maximiliano Carsi Castrejón. Es el ejemplo resuelto de la actividad «Monorepo del proyecto integrador»: muestra cómo se ve el repositorio de un equipo, con sus documentos y su `AGENTS.md`. Cada equipo escribe el suyo con su propio caso; copiar este no cuenta.

## Qué hay aquí

| Carpeta o archivo | Qué es |
|---|---|
| `apps/mobile/` | App Flutter (`cafeteria_utez`, org `mx.edu.utez`) |
| `apps/api/` | API Node + Express con `GET /health` |
| `docs/` | `01-alcance.md` (SOW), `02-prd.md`, `03-integraciones.md`, `05-datos.md`, `06-convenciones.md`; `04-arquitectura.md` se omite y el SOW dice por qué |
| `AGENTS.md` | Reglas para cualquier persona o agente |
| `scripts/check.sh` y `.githooks/` | El sensor: verifica todo con un comando y el hook lo ejecuta |

## Cómo correrlo

Requisitos: Git, Flutter estable (Dart 3) y Node 22 o 24.

```bash
git clone <url-del-repositorio> cafeteria-utez && cd cafeteria-utez
git config core.hooksPath .githooks        # activa el hook pre-commit
(cd apps/api && npm install)
(cd apps/mobile && flutter pub get)
./scripts/check.sh                          # analiza y prueba la app y la API
```

| Qué | Comando |
|---|---|
| Verificar todo | `./scripts/check.sh` |
| Levantar la API (`http://localhost:3000/health`) | `cd apps/api && npm start` |
| Correr la app | `cd apps/mobile && flutter run` |
| Pruebas de la API | `cd apps/api && npm test` |
| Pruebas y análisis de la app | `cd apps/mobile && flutter analyze && flutter test` |

## Etiquetas por sesión

Cada etiqueta marca cómo queda el repositorio al terminar la sesión. Para ver un estado: `git checkout s08-fin`.

| Etiqueta | Sesión | Qué contiene |
|---|---|---|
| `s08-fin` | Semana 8 (2026-10-22) | Monorepo con app Flutter base, API con `/health` probada, documentos base, `AGENTS.md` y el sensor `check.sh` |

Las demás etiquetas se publican después de cada sesión.
