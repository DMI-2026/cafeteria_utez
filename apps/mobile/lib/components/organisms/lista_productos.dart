import 'package:flutter/material.dart';

import '../../models/producto.dart';
import '../molecules/tarjeta_producto.dart';

/// Lista desplazable de los productos del menú, con pull-to-refresh.
class ListaProductos extends StatelessWidget {
  final List<Producto> productos;
  final Future<void> Function() onRefrescar;
  final void Function(Producto producto) onEditar;
  final void Function(Producto producto) onDarDeBaja;
  final void Function(Producto producto) onReactivar;

  const ListaProductos({
    super.key,
    required this.productos,
    required this.onRefrescar,
    required this.onEditar,
    required this.onDarDeBaja,
    required this.onReactivar,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefrescar,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return TarjetaProducto(
            key: ValueKey(producto.id),
            producto: producto,
            onEditar: () => onEditar(producto),
            onDarDeBaja: () => onDarDeBaja(producto),
            onReactivar: () => onReactivar(producto),
          );
        },
      ),
    );
  }
}
