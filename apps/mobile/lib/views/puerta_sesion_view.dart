import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../repositories/menu_repository.dart';
import '../viewmodels/auth_view_model.dart';
import 'home_view.dart';
import 'login_view.dart';
import 'registro_view.dart';

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
  bool _mostrarRegistro = false;

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
        // Un booleano en lugar de rutas: al entrar no queda nada apilado
        // debajo del menú.
        if (_mostrarRegistro) {
          return RegistroView(
            viewModel: _auth,
            onIrALogin: () => _cambiarA(registro: false),
          );
        }
        return LoginView(
          viewModel: _auth,
          onIrARegistro: () => _cambiarA(registro: true),
        );
      },
    );
  }

  void _cambiarA({required bool registro}) {
    _auth.limpiarError();
    setState(() => _mostrarRegistro = registro);
  }
}
