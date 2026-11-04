import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../molecules/campo_contrasena.dart';
import '../molecules/mensaje_formulario.dart';

/// Formulario de inicio de sesión: pinta lo que recibe y avisa con callbacks.
class FormularioLogin extends StatelessWidget {
  final TextEditingController correo;
  final TextEditingController contrasena;
  final bool cargando;
  final String? error;
  final VoidCallback onEnviar;
  // El registro llega con Firebase en la sesión 2; sin callback no se muestra.
  final VoidCallback? onIrARegistro;

  const FormularioLogin({
    super.key,
    required this.correo,
    required this.contrasena,
    required this.cargando,
    required this.onEnviar,
    this.onIrARegistro,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Inicia sesión', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: correo,
          enabled: !cargando,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Correo'),
        ),
        const SizedBox(height: AppSpacing.md),
        CampoContrasena(
          controller: contrasena,
          habilitado: !cargando,
          onEnviar: onEnviar,
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.md),
          MensajeFormulario(texto: error!),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: cargando ? null : onEnviar,
          child: cargando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Entrar'),
        ),
        if (onIrARegistro != null)
          TextButton(
            onPressed: cargando ? null : onIrARegistro,
            child: const Text('Crear una cuenta'),
          ),
      ],
    );
  }
}
