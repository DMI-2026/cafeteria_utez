import 'package:cafeteria_utez/core/errors/auth_failure.dart';
import 'package:cafeteria_utez/models/usuario.dart';
import 'package:cafeteria_utez/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    _suscripcion = _repository.sesion.listen(
      _alCambiarSesion,
      onError: (Object _) => _alCambiarSesion(null),
    );
  }

  final AuthRepository _repository;
  StreamSubscription<Usuario?>? _suscripcion;

  bool _iniciando = true;
  bool _cargando = false;
  String _error = '';
  Usuario? _usuario;

  bool get cargando => _cargando;
  bool get iniciando => _iniciando;
  String get error => _error;
  Usuario? get usuario => _usuario;

  static final _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validarCorreo(String correo) =>
      _formatoCorreo.hasMatch(correo.trim())
          ? null
          : 'Correo con formato invalido';

  static String? validarContrasena(String contrasena) =>
      contrasena.length >= 8 ? null : 'Minimo 8 Caracteres';

  Future<bool> _ejecutar(Future<Object?> Function() accion) async {
    _cargando = true;
    _error = '';
    notifyListeners();
    try {
      await accion();
      return true;
    } on AuthFailure catch (e) {
      _error = _mensaje(e);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  void _alCambiarSesion(Usuario? usuario) {
    _usuario = usuario;
    _iniciando = false;
    notifyListeners();
  }

  Future<bool> iniciarSesion({
    required String correo,
    required String constrasena,
  }) async {
    return await _ejecutar(
      () async {
        _usuario = await _repository.iniciarSesion(
          correo: correo,
          constrasena: constrasena,
        );
        return null;
      },
    );
  }

  Future<bool> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
  }) async {
    return await _ejecutar(
      () async {
        _usuario = await _repository.registrar(
          correo: correo,
          contrasena: contrasena,
          nombre: nombre,
        );
        return null;
      },
    );
  }

  Future<void> cerrarSesion() async {
    await _repository.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }

  String _mensaje(AuthFailure failure) {
    return switch (failure) {
      CredencialesIvalidas() => 'Correo o contraseña incorrectos.',
      CorreoYaRegistrado() => 'El correo ya está registrado.',
      ContrasenaDebil() => 'La contraseña es muy débil.',
      CorreoNoConfirmado() => 'El correo no ha sido confirmado.',
      DemasiadosIntentos() => 'Demasiados intentos. Intenta más tarde.',
      SinConexion() => 'Sin conexión. Revisa tu red e intenta de nuevo.',
      AuthDesconocida() => 'Ocurrió un error inesperado. Intenta de nuevo.',
    };
  }
}
