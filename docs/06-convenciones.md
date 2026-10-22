# 06 · Convenciones · Cafetería de la UTEZ

> Convenciones = cómo escribimos, probamos y organizamos el repo para que cualquiera del equipo pueda continuar el trabajo de otra persona.

## Tabla de decisiones

| # | Decisión | Por qué | Fecha |
|---|---|---|---|
| C-01 | Una rama por issue: `feat/<n>-<tema>` o `fix/<n>-<tema>`. Descartado: trabajar todos sobre `main`. El arranque de la semana 8 se hizo en clase directo sobre `main`; la regla vale desde la semana 9 | Cada cambio se revisa y se revierte por separado | 2026-10-22 |
| C-02 | Conventional Commits en español (`feat`, `fix`, `docs`, `test`, `chore`). Descartado: mensajes libres | Historial legible para el equipo y para la defensa | 2026-10-22 |
| C-03 | `main` solo recibe pull requests aprobados por otra persona. Descartado: aprobar el propio PR | La revisión automática es un sensor más, no la aprobación | 2026-10-22 |
| C-04 | `./scripts/check.sh` es la única forma de verificar, y el hook `pre-commit` lo ejecuta. Descartado: recordar correr cada comando a mano | El mismo comando para personas, agentes y hook; un commit con una prueba rota es rechazado | 2026-10-22 |
| C-05 | API: pruebas con `node --test`, sin frameworks extra. Descartado: Jest | Cero dependencias de pruebas que mantener | 2026-10-22 |
| C-06 | Una prueba nueva se escribe primero y se ve fallar antes de implementar (rojo y luego verde). Descartado: escribir la prueba al final | Una prueba que nunca falló no demuestra que detecta el error | 2026-10-22 |

## Organización del repositorio

```text
apps/mobile/   app Flutter (cafeteria_utez, org mx.edu.utez)
apps/api/      API Node + Express (src/, test/)
docs/          alcance, PRD, integraciones, modelo de datos y convenciones
scripts/       check.sh, el sensor que verifica todo
.githooks/     hooks versionados (pre-commit corre check.sh)
AGENTS.md      reglas para cualquier persona o agente
README.md      cómo correr el proyecto y las etiquetas por sesión
```

## Patrones de código

- Flutter: una carpeta por funcionalidad dentro de `lib/` (`menu/`, `pedido/`) con su estado, su pantalla y sus pruebas en `test/` con la misma ruta.
- Backend: un archivo por recurso en `apps/api/src/` (`menu.js`, `pedidos.js`) que exporta su router; `app.js` solo los monta y `server.js` solo arranca.
- Nombres en inglés para clases y funciones; textos de pantalla en español; errores con un mensaje que diga qué hacer.
- Dart: `dart format` y `flutter analyze` sin advertencias antes de cada commit.

## Estrategia de testing

- App: un widget test por cada widget con lógica y pruebas unitarias para el estado; se corren con `cd apps/mobile && flutter test`.
- Backend: una prueba por endpoint en `apps/api/test/<recurso>.test.js` que levanta la app en un puerto libre; se corren con `cd apps/api && npm test`.
- Las dos se corren juntas con `./scripts/check.sh` antes de cada commit; si fallan, el hook rechaza el commit y no se usa `--no-verify`.
- Un bug corregido llega con la prueba que lo habría detectado.

## Flujo de Git

- Se crea la rama desde `main` actualizado, se hacen commits pequeños con Conventional Commits y se abre un PR que enlaza el issue.
- Otra persona lo revisa y deja al menos un comentario concreto; quien lo abrió no lo aprueba.
- Al entrar a `main` se corre `./scripts/check.sh`; si falla en `main`, arreglarlo es lo primero.

## Al clonar (una vez por persona)

```bash
git clone <url-del-repositorio> cafeteria-utez && cd cafeteria-utez
git config core.hooksPath .githooks
(cd apps/api && npm install)
(cd apps/mobile && flutter pub get)
./scripts/check.sh
```
