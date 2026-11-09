//Estos son de Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Estos del proyecto
import '../models/usuario.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  Usuario? _aUsario(User? u) => u == null
      ? null
      : Usuario(id: u.uid, correo: u.email ?? '', nombre: u.displayName ?? '');

  @override
  Stream<Usuario?> get sesion => _auth.userChanges().map(_aUsario);

  @override
  Future<Usuario?> iniciarSesion({
    required String correo,
    required String constrasena,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: constrasena,
      );
      return _aUsario(cred.user);
    } on FirebaseException {
      rethrow;
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
      final user = cred.user;
      await user!.updateDisplayName(nombre);
      //Registro en la base de datos
      await _db.collection('usuarios').doc(user.uid).set({
        'correo': correo,
        'nombre': nombre,
      });
      return Usuario(id: user.uid, correo: correo, nombre: nombre);
    } on FirebaseException {
      rethrow;
    }
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();
}
