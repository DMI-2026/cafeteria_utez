import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Indica si una bebida es caliente o fría, con ícono y texto (no solo color).
///
/// Un alimento, o cualquier otro tipo, no muestra nada.
class BadgeTemperatura extends StatelessWidget {
  final String tipo;

  const BadgeTemperatura({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final caliente = tipo == 'bebida_caliente';
    if (!caliente && tipo != 'bebida_fria') return const SizedBox.shrink();

    final color = caliente ? AppColors.terracota : AppColors.espressoSuave;
    final fondo = caliente ? AppColors.terracotaSuave : AppColors.crema;

    return Container(
      key: const Key('indicador-temperatura'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            caliente ? Icons.local_fire_department_outlined : Icons.ac_unit,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            caliente ? 'Caliente' : 'Fría',
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
