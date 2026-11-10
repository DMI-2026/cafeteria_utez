import 'package:flutter/material.dart';

import '../components/organisms/formulario_login.dart';
import '../core/theme/app_theme.dart';
import '../viewmodels/auth_view_model.dart';

/// Pantalla de inicio de sesión: dueña de los controladores del formulario.
class LoginView extends StatefulWidget {
  final AuthViewModel viewModel;
  final VoidCallback? onIrARegistro;

  const LoginView({super.key, required this.viewModel, this.onIrARegistro});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _enviar() => widget.viewModel.iniciarSesion(
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
                builder: (context, _) => FormularioLogin(
                  correo: _correo,
                  contrasena: _contrasena,
                  cargando: widget.viewModel.cargando,
                  // El ViewModel usa '' para «sin error».
                  error: widget.viewModel.error.isEmpty
                      ? null
                      : widget.viewModel.error,
                  onEnviar: _enviar,
                  onIrARegistro: widget.onIrARegistro,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
