import 'package:flutter/material.dart';

import '../../core/format/dinero.dart';
import '../../core/theme/app_theme.dart';

/// Precio de un producto en pesos, siempre a partir de centavos (M-01).
class PrecioTexto extends StatelessWidget {
  final int centavos;
  final bool tenue;

  const PrecioTexto({super.key, required this.centavos, this.tenue = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatPrecio(centavos),
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: tenue ? AppColors.agotado : AppColors.espresso,
        decoration: tenue ? TextDecoration.lineThrough : null,
      ),
    );
  }
}
