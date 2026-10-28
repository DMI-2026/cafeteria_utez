import 'package:flutter/material.dart';

import '../components/molecules/encabezado_menu.dart';
import '../components/molecules/mensaje_estado.dart';
import '../components/organisms/formulario_producto.dart';
import '../components/organisms/lista_productos.dart';
import '../models/producto.dart';
import '../repositories/menu_repository.dart';
import '../viewmodels/productos_view_model.dart';

/// Pantalla de inicio: el menú completo con las acciones del CRUD.
class HomeView extends StatefulWidget {
  final MenuRepository repository;

  const HomeView({super.key, required this.repository});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ProductosViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductosViewModel(widget.repository);
    _viewModel.cargar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario({Producto? producto}) async {
    final datos = await FormularioProducto.mostrar(context, producto: producto);
    if (datos == null || !mounted) return;

    final bool ok;
    if (producto == null) {
      ok = await _viewModel.crear(
        nombre: datos.nombre,
        precioCentavos: datos.precioCentavos,
        disponible: datos.disponible,
        tamanos: datos.tamanos,
      );
    } else {
      ok = await _viewModel.actualizar(
        producto.id,
        nombre: datos.nombre,
        precioCentavos: datos.precioCentavos,
        disponible: datos.disponible,
        tamanos: datos.tamanos,
      );
    }

    if (!mounted) return;
    _avisar(
      ok: ok,
      exito: producto == null ? 'Producto agregado' : 'Cambios guardados',
    );
  }

  Future<void> _confirmarBaja(Producto producto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dar de baja'),
        content: Text(
          '«${producto.nombre}» dejará de estar disponible para pedir. '
          'Los pedidos anteriores lo conservan (M-04).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final ok = await _viewModel.darDeBaja(producto.id);
    if (!mounted) return;
    _avisar(ok: ok, exito: 'Producto dado de baja');
  }

  Future<void> _reactivar(Producto producto) async {
    final ok = await _viewModel.reactivar(producto.id);
    if (!mounted) return;
    _avisar(ok: ok, exito: 'Producto reactivado');
  }

  void _avisar({required bool ok, required String exito}) {
    final mensaje = ok ? exito : (_viewModel.error ?? 'No se pudo guardar');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: ok ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Agregar producto',
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add, size: 22),
        label: const Text('Agregar'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Column(
          children: [
            EncabezadoMenu(
              totalProductos: _viewModel.productos.length,
              disponibles: _viewModel.productos
                  .where((producto) => producto.disponible)
                  .length,
              cargando: _viewModel.cargando,
            ),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_viewModel.cargando && _viewModel.productos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.error != null && _viewModel.productos.isEmpty) {
      return MensajeEstado(
        icono: Icons.cloud_off,
        titulo: 'No pudimos cargar el menú',
        detalle: _viewModel.error!,
        textoBoton: 'Reintentar',
        onBoton: _viewModel.cargar,
      );
    }

    if (_viewModel.vacio) {
      return const MensajeEstado(
        icono: Icons.storefront_outlined,
        titulo: 'Todavía no hay productos',
        detalle:
            'Agrega el primero con el botón +. Lo que agregues se verá aquí '
            'mismo.',
      );
    }

    return ListaProductos(
      productos: _viewModel.productos,
      onRefrescar: _viewModel.cargar,
      onEditar: (producto) => _abrirFormulario(producto: producto),
      onDarDeBaja: _confirmarBaja,
      onReactivar: _reactivar,
    );
  }
}
