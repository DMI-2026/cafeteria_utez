import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Encabezado propio de la app: marca, título y resumen del menú.
class EncabezadoMenu extends StatelessWidget {
  final int totalProductos;
  final int disponibles;
  final bool cargando;

  const EncabezadoMenu({
    super.key,
    required this.totalProductos,
    required this.disponibles,
    this.cargando = false,
  });

  String get _resumen {
    if (cargando && totalProductos == 0) return 'Cargando el menú…';
    if (totalProductos == 0) return 'Menú vacío · agrega el primer producto';
    final productos = totalProductos == 1
        ? '1 producto'
        : '$totalProductos productos';
    final libres = disponibles == 1
        ? '1 disponible'
        : '$disponibles disponibles';
    return '$productos · $libres';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.espresso,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: const Icon(
                Icons.local_cafe,
                color: AppColors.crema,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cafetería UTEZ',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _resumen,
                      key: ValueKey(_resumen),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
