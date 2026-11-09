import 'package:flutter/material.dart';

import 'core/network/app_http_client.dart';
import 'core/network/backend_config.dart';
import 'core/theme/app_theme.dart';
import 'repositories/auth_repository.dart';
import 'repositories/menu_repository.dart';
import 'views/puerta_sesion_view.dart';

//Importar firebase
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'repositories/firebase_auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(CafeteriaApp(authRepository: FirebaseAuthRepository()));
}

class CafeteriaApp extends StatelessWidget {
  final AuthRepository authRepository;
  final AppHttpClient? httpClient;
  final MenuRepository? repository;

  const CafeteriaApp({
    super.key,
    required this.authRepository,
    this.httpClient,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final menuRepository =
        repository ??
        ApiMenuRepository(
          client: httpClient ?? AppHttpClient(),
          baseUrl: defaultBackendBaseUrl,
        );

    return MaterialApp(
      title: 'Cafetería UTEZ',
      theme: AppTheme.light,
      home: PuertaSesionView(
        authRepository: authRepository,
        menuRepository: menuRepository,
      ),
    );
  }
}
