import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Etiqueta tipo píldora que dice si un producto se puede pedir.
class BadgeDisponible extends StatelessWidget {
  final bool disponible;

  const BadgeDisponible({super.key, required this.disponible});

  @override
  Widget build(BuildContext context) {
    final color = disponible ? AppColors.verde : AppColors.agotado;
    final fondo = disponible ? AppColors.verdeSuave : AppColors.agotadoSuave;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            disponible ? 'Disponible' : 'Agotado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
