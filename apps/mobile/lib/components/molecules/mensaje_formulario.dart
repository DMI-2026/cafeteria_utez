import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Texto de error o de aviso bajo un formulario.
class MensajeFormulario extends StatelessWidget {
  final String texto;
  final bool esError;

  const MensajeFormulario({
    super.key,
    required this.texto,
    this.esError = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = esError ? AppColors.error : AppColors.verde;
    return Row(
      children: [
        Icon(
          esError ? Icons.error_outline : Icons.check_circle_outline,
          size: 20,
          color: color,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(texto, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}
