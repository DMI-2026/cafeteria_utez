import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/errors/auth_failure.dart';
import '../models/usuario.dart';
import 'auth_repository.dart';

/// Traduce el código de error de Firebase a una falla de la app.
/// El ViewModel nunca ve una excepción de Firebase, solo [AuthFailure].
AuthFailure authFailureDesde(String codigo) => switch (codigo) {
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' ||
  'invalid-email' => const CredencialesInvalidas(),
  'email-already-in-use' => const CorreoYaRegistrado(),
  'weak-password' => const ContrasenaDebil(),
  'too-many-requests' => const DemasiadosIntentos(),
  'network-request-failed' => const SinConexion(),
  _ => const AuthDesconocida(),
};

/// Sesión con Firebase Auth y perfil en Firestore (`usuarios/{uid}`).
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  Usuario? _aUsuario(User? u) => u == null
      ? null
      : Usuario(id: u.uid, correo: u.email ?? '', nombre: u.displayName ?? '');

  /// Firebase guarda la sesión en el dispositivo: al abrir la app,
  /// este stream emite al usuario que ya había entrado.
  @override
  Stream<Usuario?> get sesion => _auth.userChanges().map(_aUsuario);

  @override
  Future<Usuario?> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      return _aUsuario(cred.user);
    } on FirebaseException catch (e) {
      throw authFailureDesde(e.code);
    }
  }

  @override
  Future<Usuario?> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      final user = cred.user!;
      await user.updateDisplayName(nombre);
      // Perfil en Firestore: solo correo y nombre (docs/05-datos.md).
      await _db.collection('usuarios').doc(user.uid).set({
        'correo': correo,
        'nombre': nombre,
      });
      return Usuario(id: user.uid, correo: correo, nombre: nombre);
    } on FirebaseException catch (e) {
      throw authFailureDesde(e.code);
    }
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();
}
