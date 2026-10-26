import 'package:flutter/material.dart';

import '../../core/format/dinero.dart';

/// Precio de un producto en pesos, siempre a partir de centavos (M-01).
class PrecioTexto extends StatelessWidget {
  final int centavos;
  final bool tenue;

  const PrecioTexto({super.key, required this.centavos, this.tenue = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatPrecio(centavos),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: tenue ? Colors.grey : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
