import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/producto.dart';
import '../atoms/badge_disponible.dart';
import '../atoms/precio_texto.dart';

/// Una fila del menú con su precio, su estado y sus acciones.
class TarjetaProducto extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEditar;
  final VoidCallback onDarDeBaja;
  final VoidCallback onReactivar;

  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.onEditar,
    required this.onDarDeBaja,
    required this.onReactivar,
  });

  @override
  Widget build(BuildContext context) {
    final agotado = !producto.disponible;
    final borde = BorderRadius.circular(AppRadii.lg);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 5,
      ),
      child: Material(
        color: AppColors.superficie,
        borderRadius: borde,
        child: InkWell(
          onTap: onEditar,
          borderRadius: borde,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: borde,
              border: Border.all(color: AppColors.borde),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: agotado
                        ? AppColors.agotadoSuave
                        : AppColors.terracotaSuave,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    Icons.local_cafe_outlined,
                    size: 24,
                    color: agotado ? AppColors.agotado : AppColors.terracota,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: agotado
                                  ? AppColors.agotado
                                  : AppColors.texto,
                              decoration: agotado
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (producto.tamanos.isEmpty)
                            PrecioTexto(
                              centavos: producto.precioCentavos,
                              tenue: agotado,
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Desde ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: agotado
                                        ? AppColors.agotado
                                        : AppColors.textoSuave,
                                  ),
                                ),
                                PrecioTexto(
                                  centavos: producto.precioDesde,
                                  tenue: agotado,
                                ),
                              ],
                            ),
                          BadgeDisponible(disponible: producto.disponible),
                        ],
                      ),
                      if (producto.tamanos.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          producto.tamanos
                              .map((precio) => precio.tamano.etiqueta)
                              .join(' · '),
                          style: TextStyle(
                            fontSize: 12,
                            color: agotado
                                ? AppColors.agotado
                                : AppColors.textoSuave,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Acciones de ${producto.nombre}',
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textoSuave,
                  ),
                  onSelected: (opcion) {
                    switch (opcion) {
                      case 'editar':
                        onEditar();
                      case 'baja':
                        onDarDeBaja();
                      case 'reactivar':
                        onReactivar();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: _OpcionMenu(
                        icono: Icons.edit_outlined,
                        texto: 'Editar',
                      ),
                    ),
                    if (producto.disponible)
                      const PopupMenuItem(
                        value: 'baja',
                        child: _OpcionMenu(
                          icono: Icons.visibility_off_outlined,
                          texto: 'Dar de baja',
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'reactivar',
                        child: _OpcionMenu(
                          icono: Icons.visibility_outlined,
                          texto: 'Reactivar',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionMenu extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _OpcionMenu({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 20, color: AppColors.espressoSuave),
        const SizedBox(width: 12),
        Text(texto),
      ],
    );
  }
}
