import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format/dinero.dart';
import '../../core/theme/app_theme.dart';
import '../../models/producto.dart';
import '../../models/tamano.dart';

/// Datos capturados en el formulario; el precio ya va en centavos (M-01).
class ProductoFormData {
  final String nombre;

  /// Con tamaños, es el menor de ellos (contrato del issue #5).
  final int precioCentavos;
  final bool disponible;

  /// Tamaños elegidos con su precio, en orden ch → md → g → xl.
  final List<PrecioPorTamano> tamanos;

  const ProductoFormData({
    required this.nombre,
    required this.precioCentavos,
    required this.disponible,
    this.tamanos = const [],
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

  /// Tamaños marcados en el selector y el precio capturado de cada uno.
  final Set<Tamano> _tamanosElegidos = <Tamano>{};
  final Map<Tamano, TextEditingController> _preciosPorTamano = {};

  bool get _esEdicion => widget.producto != null;

  /// Con tamaños, el precio general se calcula solo: no se pide.
  bool get _usaTamanos => _tamanosElegidos.isNotEmpty;

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

    for (final precio in producto?.tamanos ?? const <PrecioPorTamano>[]) {
      _tamanosElegidos.add(precio.tamano);
      _preciosPorTamano[precio.tamano] = TextEditingController(
        text: formatPrecio(precio.precioCentavos).replaceFirst('\$', ''),
      );
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    for (final control in _preciosPorTamano.values) {
      control.dispose();
    }
    super.dispose();
  }

  TextEditingController _controlDe(Tamano tamano) {
    return _preciosPorTamano.putIfAbsent(
      tamano,
      () => TextEditingController(),
    );
  }

  void _alternarTamano(Tamano tamano, bool elegido) {
    setState(() {
      if (elegido) {
        _tamanosElegidos.add(tamano);
      } else {
        _tamanosElegidos.remove(tamano);
      }
    });
  }

  /// Centavos de cada tamaño marcado, en el orden del contrato.
  List<PrecioPorTamano> _tamanosCapturados() {
    return [
      for (final tamano in Tamano.values)
        if (_tamanosElegidos.contains(tamano))
          PrecioPorTamano(
            tamano: tamano,
            precioCentavos:
                parsePrecioACentavos(_controlDe(tamano).text) ?? 0,
          ),
    ];
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final tamanos = _tamanosCapturados();
    final precioCentavos = tamanos.isEmpty
        ? parsePrecioACentavos(_precio.text)!
        : tamanos
              .map((precio) => precio.precioCentavos)
              .reduce((menor, precio) => precio < menor ? precio : menor);

    Navigator.of(context).pop(
      ProductoFormData(
        nombre: _nombre.text.trim(),
        precioCentavos: precioCentavos,
        disponible: _disponible,
        tamanos: tamanos,
      ),
    );
  }

  String? _validarPrecio(String? valor) {
    final centavos = parsePrecioACentavos(valor ?? '');
    if (centavos == null) {
      return 'Escribe un precio válido, por ejemplo 12.50';
    }
    return null;
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
              if (!_usaTamanos) ...[
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
                  validator: _validarPrecio,
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Tamaños',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Si la bebida se vende por tamaños, márcalos y anota el '
                'precio de cada uno.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tamano in Tamano.values)
                    FilterChip(
                      key: Key('chip-tamano-${tamano.codigo}'),
                      label: Text(tamano.etiqueta),
                      selected: _tamanosElegidos.contains(tamano),
                      onSelected: (elegido) => _alternarTamano(tamano, elegido),
                    ),
                ],
              ),
              for (final tamano in Tamano.values)
                if (_tamanosElegidos.contains(tamano)) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    key: Key('campo-precio-tamano-${tamano.codigo}'),
                    controller: _controlDe(tamano),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.$]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Precio ${tamano.etiqueta} (MXN)',
                      hintText: '12.50',
                      prefixText: '\$ ',
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validarPrecio,
                  ),
                ],
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
