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

  const ProductoFormData({
    required this.nombre,
    required this.precioCentavos,
    required this.disponible,
  });
}

/// Guarda los datos capturados; regresa `true` si se guardaron.
typedef GuardarProducto = Future<bool> Function(ProductoFormData datos);

/// Formulario para crear o editar un producto.
///
/// Espera a [onGuardar] antes de cerrarse: mientras guarda, el botón queda
/// deshabilitado (un toque = una petición) y, si falla, el formulario sigue
/// abierto con los datos capturados.
class FormularioProducto extends StatefulWidget {
  final Producto? producto;
  final GuardarProducto onGuardar;

  const FormularioProducto({super.key, this.producto, required this.onGuardar});

  /// Abre el formulario como hoja inferior; regresa `true` si se guardó.
  static Future<bool?> mostrar(
    BuildContext context, {
    Producto? producto,
    required GuardarProducto onGuardar,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          FormularioProducto(producto: producto, onGuardar: onGuardar),
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
  bool _guardando = false;

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

  Future<void> _guardar() async {
    // Un segundo toque antes de reconstruir el botón no manda otra petición.
    if (_guardando) return;
    if (!_formKey.currentState!.validate()) return;

    final precioCentavos = parsePrecioACentavos(_precio.text)!;
    setState(() => _guardando = true);
    final guardado = await widget.onGuardar(
      ProductoFormData(
        nombre: _nombre.text.trim(),
        precioCentavos: precioCentavos,
        disponible: _disponible,
      ),
    );
    if (!mounted) return;

    if (guardado) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _guardando = false);
    }
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
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('boton-guardar'),
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Guardando…'),
                              ],
                            )
                          : const Text('Guardar'),
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
