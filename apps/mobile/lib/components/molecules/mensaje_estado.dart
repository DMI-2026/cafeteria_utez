import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mensaje de pantalla completa para los estados vacío y de error.
class MensajeEstado extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final String? textoBoton;
  final VoidCallback? onBoton;

  const MensajeEstado({
    super.key,
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.textoBoton,
    this.onBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.terracotaSuave,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 40, color: AppColors.espresso),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textoSuave),
            ),
            if (textoBoton != null && onBoton != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onBoton,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(textoBoton!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
