import 'package:flutter/material.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (textoBoton != null && onBoton != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onBoton,
                icon: const Icon(Icons.refresh),
                label: Text(textoBoton!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
