import 'package:flutter/material.dart';

import 'core/network/app_http_client.dart';
import 'core/network/backend_config.dart';
import 'repositories/menu_repository.dart';
import 'views/home_view.dart';

void main() {
  runApp(const CafeteriaApp());
}

class CafeteriaApp extends StatelessWidget {
  final AppHttpClient? httpClient;
  final MenuRepository? repository;

  const CafeteriaApp({super.key, this.httpClient, this.repository});

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: HomeView(repository: menuRepository),
    );
  }
}
