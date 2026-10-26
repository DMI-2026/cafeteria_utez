# API · Cafetería de la UTEZ

Backend en Node 22 o 24 con Express (decisión D-03 de `docs/01-alcance.md`).

## Configuración y CORS

La API tiene habilitado el middleware `cors()` de forma global (decisión C-07), lo que expone las cabeceras `Access-Control-Allow-Origin: *` requeridas para que la aplicación en Flutter (móvil, emuladores Android/iOS o web) pueda comunicarse con el backend sin bloqueos de origen cruzado.

## Comandos

```bash
npm install      # Instalar dependencias
npm start        # Iniciar servidor en http://localhost:3000
npm test         # Pruebas con node --test (C-05)
```

---

## Documentación de Endpoints

### 1. Sistema / Salud

#### `GET /health`
Verifica el estado del servicio y cabeceras CORS.

- **Respuesta 200 OK**:
  ```json
  {
    "status": "ok"
  }
  ```

---

### 2. Productos (`/productos`)

Reglas del modelo de datos:
- **M-01**: Los precios se expresan siempre en centavos enteros (`precio_centavos: int`), nunca decimales (por ejemplo, $35.00 MXN = `3500`).
- **M-04**: Los productos no se eliminan físicamente; `DELETE /productos/:id` realiza un borrado lógico marcando `disponible: false`.

#### `GET /productos`
Lista todos los productos registrados.

- **Query params (opcional)**:
  - `disponible=true|false`: Filtra productos por su estado de disponibilidad.
- **Respuesta 200 OK**:
  ```json
  [
    {
      "id": "e0b8a5b2-300c-4c74-9130-f8f6df74f762",
      "nombre": "Café Americano",
      "precio_centavos": 3500,
      "disponible": true
    }
  ]
  ```

#### `GET /productos/:id`
Obtiene los detalles de un producto por su identificador único.

- **Respuesta 200 OK**:
  ```json
  {
    "id": "e0b8a5b2-300c-4c74-9130-f8f6df74f762",
    "nombre": "Café Americano",
    "precio_centavos": 3500,
    "disponible": true
  }
  ```
- **Respuesta 404 Not Found**:
  ```json
  {
    "error": "Producto no encontrado"
  }
  ```

#### `POST /productos`
Crea un nuevo producto en el catálogo.

- **Cuerpo de la petición (JSON)**:
  ```json
  {
    "nombre": "Café Americano",
    "precio_centavos": 3500,
    "disponible": true
  }
  ```
  *(Nota: `disponible` es opcional, por defecto es `true`).*
- **Respuesta 201 Created**: Objeto del producto creado con su `id` asignado.
- **Respuesta 400 Bad Request**: Cuando falta el nombre o el precio no es un entero positivo (M-01).

#### `PUT /productos/:id`
Actualiza campos de un producto existente.

- **Cuerpo de la petición (JSON)**:
  ```json
  {
    "nombre": "Café Americano Grande",
    "precio_centavos": 4200,
    "disponible": true
  }
  ```
- **Respuesta 200 OK**: Objeto del producto actualizado.
- **Respuesta 404 Not Found**: Si no existe el identificador.

#### `DELETE /productos/:id`
Desactiva un producto (borrado lógico: `disponible: false`).

- **Respuesta 200 OK**:
  ```json
  {
    "id": "e0b8a5b2-300c-4c74-9130-f8f6df74f762",
    "nombre": "Café Americano",
    "precio_centavos": 3500,
    "disponible": false
  }
  ```
- **Respuesta 404 Not Found**: Si no existe el identificador.

---

### 3. Usuarios (`/usuarios`)

Reglas del modelo de datos:
- Privacidad: Solo se almacenan `correo` y `nombre` del usuario (según el PRD y `docs/05-datos.md`).

#### `GET /usuarios`
Lista todos los usuarios registrados.

- **Respuesta 200 OK**:
  ```json
  [
    {
      "id": "52210a4d-bb62-4217-9c98-1e4a7a8e0f51",
      "nombre": "Juan Pérez",
      "correo": "juan.perez@utez.edu.mx"
    }
  ]
  ```

#### `GET /usuarios/:id`
Obtiene los datos de un usuario por su identificador.

- **Respuesta 200 OK**:
  ```json
  {
    "id": "52210a4d-bb62-4217-9c98-1e4a7a8e0f51",
    "nombre": "Juan Pérez",
    "correo": "juan.perez@utez.edu.mx"
  }
  ```
- **Respuesta 404 Not Found**:
  ```json
  {
    "error": "Usuario no encontrado"
  }
  ```

#### `POST /usuarios`
Registra un nuevo usuario en la plataforma.

- **Cuerpo de la petición (JSON)**:
  ```json
  {
    "nombre": "Juan Pérez",
    "correo": "juan.perez@utez.edu.mx"
  }
  ```
- **Respuesta 201 Created**: Objeto con el usuario creado y su `id`.
- **Respuesta 400 Bad Request**: Si falta nombre o correo, o el formato del correo es inválido.

#### `PUT /usuarios/:id`
Actualiza el nombre o correo de un usuario.

- **Cuerpo de la petición (JSON)**:
  ```json
  {
    "nombre": "Juan Carlos Pérez",
    "correo": "juanc.perez@utez.edu.mx"
  }
  ```
- **Respuesta 200 OK**: Objeto de usuario con los datos actualizados.
- **Respuesta 404 Not Found**: Si no existe el identificador.

#### `DELETE /usuarios/:id`
Elimina un usuario del sistema.

- **Respuesta 200 OK**: Objeto del usuario eliminado.
- **Respuesta 404 Not Found**: Si no existe el identificador.
