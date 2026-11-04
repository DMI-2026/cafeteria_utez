import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../repositories/menu_repository.dart';
import '../viewmodels/auth_view_model.dart';
import 'home_view.dart';
import 'login_view.dart';

/// Muestra el indicador, el login o el menú según el estado de la sesión.
class PuertaSesionView extends StatefulWidget {
  final AuthRepository authRepository;
  final MenuRepository menuRepository;

  const PuertaSesionView({
    super.key,
    required this.authRepository,
    required this.menuRepository,
  });

  @override
  State<PuertaSesionView> createState() => _PuertaSesionViewState();
}

class _PuertaSesionViewState extends State<PuertaSesionView> {
  late final AuthViewModel _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthViewModel(widget.authRepository);
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) {
        if (_auth.iniciando) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (_auth.usuario != null) {
          return HomeView(
            repository: widget.menuRepository,
            onCerrarSesion: _auth.cerrarSesion,
          );
        }
        return LoginView(viewModel: _auth);
      },
    );
  }
}
