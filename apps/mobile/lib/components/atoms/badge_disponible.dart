import 'package:flutter/material.dart';

/// Etiqueta que dice si un producto se puede pedir.
class BadgeDisponible extends StatelessWidget {
  final bool disponible;

  const BadgeDisponible({super.key, required this.disponible});

  @override
  Widget build(BuildContext context) {
    final color = disponible ? Colors.green.shade800 : Colors.grey.shade700;
    final fondo = disponible ? Colors.green.shade50 : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        disponible ? 'Disponible' : 'Agotado',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
