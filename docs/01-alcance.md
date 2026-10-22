# 01 · Alcance (SOW) · Cafetería de la UTEZ

> SOW = qué se va a construir, en qué orden y cuándo. Una decisión no se contradice en otro documento: si cambia, se actualiza aquí con su nueva justificación y fecha.

## Objetivo

Que la comunidad universitaria haga pedidos a la cafetería de la UTEZ desde el celular y los recoja sin hacer fila. Se nota que funciona cuando una persona registrada pide en menos de 1 minuto y la cocina ve el pedido sin recargar la pantalla.

## Tabla de decisiones

| # | Decisión | Por qué | Fecha |
|---|---|---|---|
| D-01 | Monorepo con `apps/mobile`, `apps/api` y `docs/`. Alternativa descartada: un repositorio por app | Un solo contexto para el equipo y los agentes: un cambio de la API y el de la app que lo usa viajan en el mismo PR, y los documentos están al lado del código | 2026-10-22 |
| D-02 | Flutter para la app móvil. Alternativa descartada: Kotlin y Swift nativos | Una base de código para Android e iOS; es el framework del curso y el grupo ya lo usó en las semanas 4 a 7 | 2026-10-22 |
| D-03 | Node 22 o 24 con Express para la API. Alternativa descartada: Firebase Cloud Functions | Cloud Functions exige el plan de pago de Firebase con tarjeta, y el equipo debe poder correr todo gratis; Express se levanta en local y se prueba con `node --test` | 2026-10-22 |
| D-04 | Pagos en línea fuera de la v1. Alternativa descartada: pasarela de pagos dentro de la app | Riesgo alto (dinero y datos de tarjeta) y un trámite con la cafetería que no depende del equipo; en la v1 se paga en caja al recoger | 2026-10-22 |
| D-05 | Autenticación con Firebase Auth. Alternativa descartada: usuarios y contraseñas propios en la API | No guardamos contraseñas, que es el dato más riesgoso de proteger (semanas 6 y 7); reutiliza lo construido en la semana 7 | 2026-10-22 |
| D-06 | Menú y pedidos en Firestore. Alternativa descartada: base SQL propia detrás de la API | Firestore entrega cambios en tiempo real a la cocina y a la app sin escribir ese mecanismo; una base SQL obligaría a pagar un servidor y a operarlo | 2026-10-22 |
| D-07 | Programa de lealtad y cupones fuera de la v1. Alternativa descartada: puntos por pedido desde la fase 1 | Nadie lo pidió en la entrevista con la cafetería y duplicaría las historias; se evalúa después de medir cuántos pedidos hay por día | 2026-10-22 |
| D-08 | Solo Android e iOS, sin versión web. Alternativa descartada: Flutter web para la cocina | El resultado de aprendizaje de la unidad II pide una aplicación móvil; una pantalla web para la cocina abriría una superficie de ataque más que cuidar | 2026-10-22 |

## Módulos y fases

| Fase | Módulos | Qué incluye |
|---|---|---|
| 1 (v1) | Menú, pedido, estado del pedido | La persona inicia sesión, ve el menú, arma y confirma un pedido y ve si está en preparación o listo. En esta fase el personal cambia el estado desde la consola de Firebase |
| 2 | Cocina | Pantalla para que la cocina vea los pedidos nuevos sin recargar y cambie su estado |
| 3 | Notificaciones | Aviso en el celular cuando el pedido está listo, con el permiso pedido en el momento adecuado |

## Plan temporal

| Fecha | Hito | Evidencia |
|---|---|---|
| 2026-10-22 | Semana 8: monorepo con documentos base y AGENTS.md | Etiqueta `s08-fin` del repositorio |
| 2026-10-29 | Semana 9: Firestore con `productos` y `pedidos`, y reglas de acceso | Reglas probadas con el emulador |
| 2026-11-05 | Semana 10: API de clima de Open-Meteo y flujo completo menú, pedido y estado | Demostración en el dispositivo |
| 2026-11-11 | Semana 11: demostración de la unidad II | Enlace del repositorio en funcionamiento |
| 2026-11-19 | Semana 12: pruebas unitarias, de widgets y de integración | `flutter test` y `npm test` en verde |
| 2026-11-26 | Semana 13: flujo de extremo a extremo y versión release | Reporte de pruebas y el APK de release |
| 2026-12-03 | Semana 14: permisos y notificaciones (fase 3) | Pantalla que explica y pide el permiso |
| Semana 15 (fecha [CONFIRMAR]) | Distribución y defensa final | Código fuente y construcción |

## Criterios de aceptación de alto nivel

- Una persona registrada puede hacer un pedido en menos de 1 minuto desde que abre la app.
- La cocina ve un pedido nuevo en menos de 5 segundos sin recargar la pantalla y puede cambiar su estado.
- El menú aparece en menos de 2 segundos con conexión Wi-Fi.
- `./scripts/check.sh` termina con código 0 en `main` en todo momento.
- Ninguna llave ni secreto está en el repositorio (`git log -p` no encuentra ninguno).

## Fuera de alcance (v1)

- Pagos en línea (D-04).
- Programa de lealtad y cupones (D-07).
- Versión web (D-08).

## Documentos del proyecto

| Documento | ¿Lo necesitamos? | Por qué |
|---|---|---|
| SOW / alcance (`01-alcance.md`) | Sí | Siempre |
| PRD / producto (`02-prd.md`) | Sí | Siempre |
| Integraciones (`03-integraciones.md`) | Sí | Usamos tres servicios externos en las fases 1 y 2 (Firebase Auth, Firestore y Open-Meteo) y un cuarto en la fase 3 (Firebase Cloud Messaging); su orden en el roadmap y dónde viven las llaves importan |
| Arquitectura (`04-arquitectura.md`) | No por ahora | Un cliente (la app) y una API que por ahora solo responde `/health`; D-01, D-03 y D-06 ya dicen cómo se compone y no hay roles ni organizaciones que aislar. Se escribe si aparece un segundo cliente (la pantalla de cocina como app aparte) o si dos cafeterías deben ver solo sus pedidos |
| Modelo de datos (`05-datos.md`) | Sí | Cuatro entidades con relaciones (usuario, producto, pedido y línea de pedido); el PRD y las reglas de Firestore dependen de ellas |
| Convenciones (`06-convenciones.md`) | Sí | Siempre |
