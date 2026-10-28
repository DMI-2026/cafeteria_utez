# Cafetería de la UTEZ · monorepo

App para pedir en la cafetería sin hacer fila. Las decisiones viven en `docs/` con prefijo: D- alcance, P- PRD, I- integraciones, M- datos, C- convenciones. Si una regla de aquí choca con `docs/`, manda `docs/`.

## Comandos

| Para | Comando |
|---|---|
| Verificar todo (único criterio de «listo», C-04) | `./scripts/check.sh` |
| Pruebas de la app | `cd apps/mobile && flutter analyze && flutter test` |
| Pruebas de la API | `cd apps/api && npm test` (`node --test`) |
| Levantar la API | `cd apps/api && npm start` (puerto `PORT`, por defecto 3000) |
| Activar el hook | `git config core.hooksPath .githooks` |

## Dónde va cada cosa

- `apps/api/src/`: Express 5. `app.js` monta rutas, `server.js` escucha, un archivo por recurso (`productos.js`, `usuarios.js`). Pruebas en `apps/api/test/<recurso>.test.js`.
- `apps/mobile/lib/` (MVVM + Atomic Design, C-08):
  - `models/`: datos con `fromJson`, `toJson`, `copyWith`.
  - `repositories/`: única capa que habla con la API, a través de `core/network/app_http_client.dart` (C-10).
  - `viewmodels/`: `ChangeNotifier`; sin widgets.
  - `views/`: pantallas; `components/atoms|molecules|organisms/`: piezas reutilizables.
  - `core/`: `errors/` (`HttpFailure` sellado), `format/` (dinero), `network/`, `theme/` (C-11).
- `apps/mobile/test/` refleja la estructura de `lib/`; los dobles de prueba van en `test/fakes/`.

## Reglas de código

- Dinero en centavos enteros (`precio_centavos`, `int`); se formatea solo con `core/format/dinero.dart` (M-01).
- Un producto no se borra: `DELETE` marca `disponible: false` (M-04).
- Errores HTTP en la app: atrapa `HttpFailure` en el repositorio o view model; nunca uses `http` directo fuera de `core/network/`.
- La API responde `{ "error": "<mensaje en español>" }` con 400, 404 o 409; nunca falla en silencio (ni si el puerto está ocupado).
- Estilo visual solo con el tema de `core/theme/`; no agregues paquetes de UI (C-11).
- Dependencias nuevas: solo con una decisión C- o D- que las justifique. Pruebas de la API sin Jest ni similares (C-05).
- Fuera de la v1: pagos, lealtad y web. No los propongas sin cambiar antes el alcance (D-04, D-07, D-08).

## Cómo se trabaja

1. Parte de un issue. Lee su contrato y los `docs/` que menciona; si el issue tiene padre, el contrato está ahí.
2. Propón un plan en pasos y espera aprobación antes de escribir código.
3. Rama `feat/<n>-<tema>` o `fix/<n>-<tema>` desde `main`; nunca push a `main` (C-01).
4. Prueba primero, mírala fallar, luego implementa (C-06).
5. `./scripts/check.sh` en verde; commit en español con Conventional Commits: `feat`, `fix`, `docs`, `test`, `chore` (C-02).
6. PR a `main` con `Closes #<n>`; lo aprueba otra persona del equipo (C-03, `CONTRIBUIDORES.md`). Si una PR aprobada ya contiene los commits de otra, fusiona la de arriba: fusionar primero la de abajo cambia su base y GitHub descarta la aprobación (`dismiss_stale_reviews`).
7. Una decisión nueva va a la tabla de su documento en `docs/`, con la alternativa descartada.

## Nunca

- Secretos o llaves en el repo; variables en `.env` ignorado (I-02).
- `--no-verify`, desactivar el hook, o borrar o debilitar pruebas para que pasen.
- Cambiar el contrato de datos de un issue sin avisar en ese issue.
