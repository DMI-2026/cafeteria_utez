import 'package:flutter/material.dart';

import 'core/network/app_http_client.dart';
import 'views/home_view.dart';

void main() {
  runApp(const CafeteriaApp());
}

class CafeteriaApp extends StatelessWidget {
  final AppHttpClient? httpClient;

  const CafeteriaApp({super.key, this.httpClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafetería UTEZ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: HomeView(httpClient: httpClient),
    );
  }
}
