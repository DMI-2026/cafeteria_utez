# 03 · Integraciones · Cafetería de la UTEZ

> Integraciones = qué servicios externos usa el producto y en qué orden entran. Si una integración necesita más detalle, lleva su propia sección.

## Tabla de decisiones

| # | Decisión | Por qué | Fecha |
|---|---|---|---|
| I-01 | Primero Firebase Auth y Firestore (semanas 7 y 9), después Open-Meteo (semana 10) y al final Cloud Messaging (semana 14). Descartada: empezar por la API de terceros | Sin sesión y sin datos no hay pedido que mostrar; el clima es un extra que no bloquea nada | 2026-10-22 |
| I-02 | Ninguna llave vive en el repositorio: la configuración de Firebase se genera en cada máquina y las variables de la API se leen del entorno (`.env` ignorado). Descartada: llaves en un archivo versionado de configuración | Un secreto subido sigue expuesto en el historial aunque se borre después | 2026-10-22 |
| I-03 | La API de terceros es Open-Meteo, sin llave. Descartada: OpenWeatherMap | No pide registro ni llave, así que no hay secreto que cuidar y cualquier persona del grupo corre el proyecto | 2026-10-22 |

## Familias de integraciones y orden en el roadmap

| Orden | Familia | Integración | Para qué | Fase |
|---|---|---|---|---|
| 1 | Autenticación | Firebase Auth | Iniciar sesión sin guardar contraseñas | 1 |
| 2 | Datos en la nube | Firestore | Menú y pedidos en tiempo real | 1 |
| 3 | API de terceros | Open-Meteo | Sugerir una bebida fría o caliente según el clima del día | 1 (semana 10, flujo completo) |
| 4 | Notificaciones | Firebase Cloud Messaging | Avisar que el pedido está listo | 3 |
| 5 | Pagos | Pasarela de pagos [por elegir] | Pagar desde la app | Fuera de la v1 (D-04) |

## Firebase Auth

- Qué datos viajan: correo y token de sesión; la contraseña nunca llega a nuestra API.
- Dónde viven las credenciales: el token en almacenamiento seguro del dispositivo; la configuración del proyecto de Firebase se genera con la herramienta de Firebase en cada máquina y no se sube.
- Si falla: la app muestra «No pudimos iniciar sesión, intenta de nuevo» y conserva el carrito.
- Límites o costo: plan gratuito de Firebase; la verificación por correo no tiene costo para este volumen.
- Cómo se prueba: con un doble de la fuente de autenticación; sin llamadas reales a Firebase en las pruebas.

## Firestore

- Qué datos viajan: productos, pedidos y líneas de pedido; el pedido lleva el identificador del usuario, no su correo.
- Dónde viven las credenciales: no hay llave de servidor en la app; el acceso lo limitan las reglas de Firestore, que sí se versionan (`firestore.rules`, semana 9).
- Si falla: la app muestra el último menú que tenía y avisa que no pudo actualizar; el pedido no se confirma sin conexión.
- Límites o costo: cuota diaria gratuita de lecturas y escrituras [CONFIRMAR cifras vigentes en la documentación de Firebase antes de la semana 9].
- Cómo se prueba: con el emulador de Firestore para las reglas y con un repositorio falso en las pruebas de widgets.

## Open-Meteo

- Qué datos viajan: las coordenadas fijas de la cafetería (no la ubicación de la persona) y, de regreso, la temperatura actual en JSON.
- Dónde viven las credenciales: no hay llave; la URL base vive en una constante de la API.
- Si falla o tarda más de 3 segundos, la app omite la sugerencia y muestra el menú completo; el clima nunca bloquea un pedido.
- Límites o costo: gratuita para uso no comercial [CONFIRMAR límite diario vigente en su documentación antes de la semana 10]; la API guarda la última respuesta 10 minutos para no consultarla en cada pantalla.
- Cómo se prueba: con una respuesta JSON de ejemplo en `apps/api/test/`, sin llamar al servicio real.
