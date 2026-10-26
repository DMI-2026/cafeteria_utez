import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format/dinero.dart';
import '../../models/producto.dart';

/// Datos capturados en el formulario; el precio ya va en centavos (M-01).
class ProductoFormData {
  final String nombre;
  final int precioCentavos;
  final bool disponible;

  const ProductoFormData({
    required this.nombre,
    required this.precioCentavos,
    required this.disponible,
  });
}

/// Formulario para crear o editar un producto.
class FormularioProducto extends StatefulWidget {
  final Producto? producto;

  const FormularioProducto({super.key, this.producto});

  /// Abre el formulario como hoja inferior y regresa los datos o `null`.
  static Future<ProductoFormData?> mostrar(
    BuildContext context, {
    Producto? producto,
  }) {
    return showModalBottomSheet<ProductoFormData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FormularioProducto(producto: producto),
    );
  }

  @override
  State<FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<FormularioProducto> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _precio;
  late bool _disponible;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final producto = widget.producto;
    _nombre = TextEditingController(text: producto?.nombre ?? '');
    _precio = TextEditingController(
      text: producto == null
          ? ''
          : formatPrecio(producto.precioCentavos).replaceFirst('\$', ''),
    );
    _disponible = producto?.disponible ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final precioCentavos = parsePrecioACentavos(_precio.text)!;
    Navigator.of(context).pop(
      ProductoFormData(
        nombre: _nombre.text.trim(),
        precioCentavos: precioCentavos,
        disponible: _disponible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _esEdicion ? 'Editar producto' : 'Nuevo producto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('campo-nombre'),
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Café americano',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Escribe el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('campo-precio'),
                controller: _precio,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.$]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Precio (MXN)',
                  hintText: '12.50',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final centavos = parsePrecioACentavos(valor ?? '');
                  if (centavos == null) {
                    return 'Escribe un precio válido, por ejemplo 12.50';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Disponible para pedir'),
                value: _disponible,
                onChanged: (valor) => setState(() => _disponible = valor),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
