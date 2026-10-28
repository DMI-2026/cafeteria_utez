# cafeteria_utez

App móvil de la Cafetería de la UTEZ

## Duplicados al guardar

La API rechaza un nombre de producto repetido con `409` y un cuerpo como:

```json
{
  "error": "Ya existe un producto con ese nombre",
  "id": "<id del producto existente>"
}
```

El contrato de datos está definido en la issue #5. En la app, el flujo ante un duplicado es:

- El formulario permanece abierto y muestra «Ya existe un producto con ese nombre» junto al campo Nombre.
- El producto no se agrega a la lista hasta que se corrige el nombre.
- Al cambiar el nombre y volver a Guardar, el producto se crea y el error desaparece.
- Mientras la petición viaja, Guardar se deshabilita y muestra progreso para que un doble toque no cree dos productos.

La prueba del flujo completo vive en `test/viewmodels/productos_view_model_test.dart` y se ejecuta con:

```bash
cd apps/mobile
flutter test test/viewmodels/productos_view_model_test.dart
```

La verificación completa del repositorio se hace desde la raíz con `./scripts/check.sh` (Git Bash o WSL) o `bash ./scripts/check.sh` en PowerShell.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
