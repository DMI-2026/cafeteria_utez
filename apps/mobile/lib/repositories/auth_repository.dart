import 'package:cafeteria_utez/models/usuario.dart';

abstract class AuthRepository {
  Stream<Usuario?> get sesion;
  Future<Usuario> iniciarSesion({
    required String correo,
    required String constrasena,
  });
  Future<Usuario?> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
  });
  Future<void> cerrarSesion();
}
