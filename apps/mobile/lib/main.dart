import 'package:flutter/material.dart';

import 'views/home_view.dart';

void main() {
  runApp(const CafeteriaApp());
}

class CafeteriaApp extends StatelessWidget {
  const CafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Cafetería UTEZ', home: HomeView());
  }
}
