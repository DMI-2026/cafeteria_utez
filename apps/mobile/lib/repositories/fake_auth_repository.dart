import 'dart:async';

import '../core/errors/auth_failure.dart';
import '../models/usuario.dart';
import 'auth_repository.dart';

/// Sesión en memoria para trabajar las pantallas antes de conectar Firebase.
/// shortcut: sin persistencia ni red; se reemplaza por FirebaseAuthRepository en la sesión 2.
class FakeAuthRepository implements AuthRepository {
  static const correoDemo = 'personal@utez.edu.mx';
  static const contrasenaDemo = 'cafeteria2026';

  FakeAuthRepository({Usuario? sesionInicial}) : _actual = sesionInicial {
    _cuentas[correoDemo] = (
      contrasena: contrasenaDemo,
      usuario: Usuario(id: 'u-demo', correo: correoDemo, nombre: 'Personal'),
    );
  }

  final _cambios = StreamController<Usuario?>.broadcast();
  final _cuentas = <String, ({String contrasena, Usuario usuario})>{};
  Usuario? _actual;

  @override
  Stream<Usuario?> get sesion async* {
    yield _actual;
    yield* _cambios.stream;
  }

  void _emitir(Usuario? usuario) {
    _actual = usuario;
    _cambios.add(usuario);
  }

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String constrasena,
  }) async {
    final cuenta = _cuentas[correo.trim()];
    if (cuenta == null || cuenta.contrasena != constrasena) {
      throw const CredencialesIvalidas();
    }
    _emitir(cuenta.usuario);
    return cuenta.usuario;
  }

  @override
  Future<Usuario?> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
  }) async {
    final limpio = correo.trim();
    if (_cuentas.containsKey(limpio)) throw const CorreoYaRegistrado();
    final usuario = Usuario(
      id: 'u-${_cuentas.length + 1}',
      correo: limpio,
      nombre: nombre,
    );
    _cuentas[limpio] = (contrasena: contrasena, usuario: usuario);
    _emitir(usuario);
    return usuario;
  }

  @override
  Future<void> cerrarSesion() async => _emitir(null);
}
