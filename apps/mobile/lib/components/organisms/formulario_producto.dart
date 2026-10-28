import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format/dinero.dart';
import '../../core/theme/app_theme.dart';
import '../../models/producto.dart';

/// Datos capturados en el formulario; el precio ya va en centavos (M-01).
class ProductoFormData {
  final String nombre;
  final int precioCentavos;
  final bool disponible;
  final String descripcion;
  final String tipo;

  const ProductoFormData({
    required this.nombre,
    required this.precioCentavos,
    required this.disponible,
    required this.descripcion,
    required this.tipo,
  });
}

/// Opciones del selector de tipo (M-06 · contrato de #5).
const _tiposDisponibles = <_OpcionTipo>[
  _OpcionTipo('alimento', 'Alimento'),
  _OpcionTipo('bebida_caliente', 'Bebida caliente'),
  _OpcionTipo('bebida_fria', 'Bebida fría'),
];

class _OpcionTipo {
  final String valor;
  final String etiqueta;
  const _OpcionTipo(this.valor, this.etiqueta);
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
  late final TextEditingController _descripcion;
  late bool _disponible;
  late String _tipo;

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
    _descripcion = TextEditingController(text: producto?.descripcion ?? '');
    _disponible = producto?.disponible ?? true;
    _tipo = producto?.tipo ?? 'alimento';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _descripcion.dispose();
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
        descripcion: _descripcion.text.trim(),
        tipo: _tipo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borde,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _esEdicion ? 'Editar producto' : 'Nuevo producto',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                _esEdicion
                    ? 'Cambia lo que necesites; el precio se guarda en centavos.'
                    : 'El precio se escribe en pesos, por ejemplo 12.50.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
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
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('campo-descripcion'),
                controller: _descripcion,
                maxLength: 200,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Qué lleva el producto (opcional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('campo-tipo'),
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final opcion in _tiposDisponibles)
                    DropdownMenuItem<String>(
                      value: opcion.valor,
                      child: Text(opcion.etiqueta),
                    ),
                ],
                onChanged: (valor) {
                  if (valor == null) return;
                  setState(() => _tipo = valor);
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
