import 'package:flutter/material.dart';

import '../components/organisms/formulario_registro.dart';
import '../core/theme/app_theme.dart';
import '../viewmodels/auth_view_model.dart';

/// Pantalla de registro: dueña de los controladores del formulario.
class RegistroView extends StatefulWidget {
  final AuthViewModel viewModel;
  final VoidCallback onIrALogin;

  const RegistroView({
    super.key,
    required this.viewModel,
    required this.onIrALogin,
  });

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _enviar() => widget.viewModel.registrar(
    nombre: _nombre.text,
    correo: _correo.text,
    contrasena: _contrasena.text,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) => FormularioRegistro(
                  nombre: _nombre,
                  correo: _correo,
                  contrasena: _contrasena,
                  cargando: widget.viewModel.cargando,
                  error: widget.viewModel.error.isEmpty
                      ? null
                      : widget.viewModel.error,
                  onEnviar: _enviar,
                  onIrALogin: widget.onIrALogin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
