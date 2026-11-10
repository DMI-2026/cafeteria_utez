import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firestore_menu_repository.dart';
import 'repositories/menu_repository.dart';
import 'views/puerta_sesion_view.dart';

Future<void> main() async {
  // Firebase debe estar listo antes de crear cualquier repositorio.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    CafeteriaApp(
      authRepository: FirebaseAuthRepository(),
      repository: FirestoreMenuRepository(),
    ),
  );
}

class CafeteriaApp extends StatelessWidget {
  final AuthRepository authRepository;
  final MenuRepository repository;

  const CafeteriaApp({
    super.key,
    required this.authRepository,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafetería UTEZ',
      theme: AppTheme.light,
      home: PuertaSesionView(
        authRepository: authRepository,
        menuRepository: repository,
      ),
    );
  }
}
