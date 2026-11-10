import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../molecules/campo_contrasena.dart';
import '../molecules/mensaje_formulario.dart';

/// Formulario de registro: pinta lo que recibe y avisa con callbacks.
class FormularioRegistro extends StatelessWidget {
  final TextEditingController nombre;
  final TextEditingController correo;
  final TextEditingController contrasena;
  final bool cargando;
  final String? error;
  final VoidCallback onEnviar;
  final VoidCallback onIrALogin;

  const FormularioRegistro({
    super.key,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.cargando,
    required this.onEnviar,
    required this.onIrALogin,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crea tu cuenta',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: nombre,
          enabled: !cargando,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        const SizedBox(height: AppSpacing.md),
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
              : const Text('Registrarme'),
        ),
        TextButton(
          onPressed: cargando ? null : onIrALogin,
          child: const Text('Ya tengo cuenta'),
        ),
      ],
    );
  }
}
