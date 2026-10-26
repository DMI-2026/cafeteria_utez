import 'package:flutter/material.dart';

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onEditar,
        leading: CircleAvatar(
          backgroundColor: agotado
              ? Colors.grey.shade300
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.local_cafe_outlined,
            color: agotado ? Colors.grey.shade600 : null,
          ),
        ),
        title: Text(
          producto.nombre,
          style: TextStyle(
            color: agotado ? Colors.grey : null,
            decoration: agotado ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              PrecioTexto(centavos: producto.precioCentavos, tenue: agotado),
              const SizedBox(width: 8),
              BadgeDisponible(disponible: producto.disponible),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Acciones de ${producto.nombre}',
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
              child: _OpcionMenu(icono: Icons.edit_outlined, texto: 'Editar'),
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
      children: [Icon(icono, size: 20), const SizedBox(width: 12), Text(texto)],
    );
  }
}
