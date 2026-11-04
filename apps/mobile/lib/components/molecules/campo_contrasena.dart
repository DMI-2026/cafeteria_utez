import 'package:flutter/material.dart';

/// Campo de contraseña con botón para mostrar u ocultar.
/// Su único estado es la visibilidad, que es solo de presentación.
class CampoContrasena extends StatefulWidget {
  final TextEditingController controller;
  final String etiqueta;
  final bool habilitado;
  final VoidCallback? onEnviar;

  const CampoContrasena({
    super.key,
    required this.controller,
    this.etiqueta = 'Contraseña',
    this.habilitado = true,
    this.onEnviar,
  });

  @override
  State<CampoContrasena> createState() => _CampoContrasenaState();
}

class _CampoContrasenaState extends State<CampoContrasena> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.habilitado,
      obscureText: _oculta,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => widget.onEnviar?.call(),
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        suffixIcon: IconButton(
          tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(_oculta ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
    );
  }
}
