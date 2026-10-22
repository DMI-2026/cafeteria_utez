# 02 · PRD · Cafetería de la UTEZ

> PRD = qué necesita la persona que usa el producto y cómo sabremos que se cumplió. No dice cómo se programa.

## Tabla de decisiones

| # | Decisión | Por qué | Fecha |
|---|---|---|---|
| P-01 | Tres historias en la v1: menú, pedido y estado del pedido. Descartada: incluir la pantalla de cocina en la v1 | Es lo mínimo para que alguien pida y recoja sin fila; la cocina entra en la fase 2 del SOW y mientras tanto cambia el estado desde la consola de Firebase | 2026-10-22 |
| P-02 | El pedido se paga en caja. Descartada: pagar desde la app | Pagos en línea quedan fuera (D-04 de `01-alcance.md`) | 2026-10-22 |
| P-03 | Pedir exige iniciar sesión; ver el menú no. Descartada: pedir como invitado | Sin cuenta no hay a quién avisar ni cómo evitar pedidos falsos; el menú público baja la barrera para entrar (D-05) | 2026-10-22 |

## Personas usuarias

- Estudiante de la UTEZ con 15 minutos entre clases y poco saldo: quiere saber qué hay y cuánto cuesta antes de caminar a la cafetería.
- Persona de la cocina en hora pico: necesita ver qué pedir preparar sin dejar de cocinar (fase 2).

## Historias de usuario

### H-01 · Ver el menú

Como persona de la comunidad universitaria quiero ver el menú del día para decidir qué pedir sin ir a la cafetería.

Módulo del SOW: Menú (fase 1).

Criterios de aceptación:
- El menú aparece en menos de 2 segundos con conexión Wi-Fi.
- Cada producto muestra nombre y precio en pesos.
- Un producto agotado se ve gris y no se puede agregar al pedido.

### H-02 · Hacer un pedido

Como persona registrada quiero armar un pedido y confirmarlo para recogerlo sin hacer fila.

Módulo del SOW: Pedido (fase 1).

Criterios de aceptación:
- Se confirma en máximo 4 toques desde el menú.
- Al confirmar, el pedido recibe un número de 3 dígitos que se muestra en pantalla.
- Sin sesión iniciada, la app manda a iniciar sesión y conserva el carrito.

### H-03 · Ver el estado del pedido

Como persona que ya pidió quiero ver si mi pedido está en preparación o listo para saber cuándo ir.

Módulo del SOW: Estado del pedido (fase 1).

Criterios de aceptación:
- El estado cambia en la app en menos de 5 segundos después de que la cocina lo cambia.
- Cuando está listo, la app muestra el número del pedido en grande.

## Requisitos no funcionales

- Seguridad: el token de sesión se guarda en almacenamiento seguro del dispositivo, nunca en texto plano (semana 7), y todo el tráfico entre la app y la API viaja por HTTPS.
- Seguridad: las reglas de Firestore permiten leer y escribir un pedido solo a quien lo creó y a la cocina (semanas 6 y 9).
- Privacidad: solo se guardan el correo institucional y el nombre; no se piden teléfono ni ubicación (semana 6).
- Rendimiento: la lista del menú carga en menos de 2 segundos con Wi-Fi.
- Accesibilidad: el texto se lee con el tamaño de letra del sistema al 150 %.

## Fuera de alcance

- Pagos en línea (D-04).
- Programa de lealtad y cupones (D-07).
- Versión web (D-08).
