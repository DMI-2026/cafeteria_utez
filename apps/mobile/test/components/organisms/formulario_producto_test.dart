import 'package:cafeteria_utez/components/organisms/formulario_producto.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/models/tamano.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta el formulario suelto, como lo haría la hoja inferior.
Future<void> _mostrar(WidgetTester tester, {Producto? producto}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: FormularioProducto(producto: producto),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('selector de tamaños', () {
    testWidgets('ofrece los cuatro tamaños del contrato', (tester) async {
      await _mostrar(tester);

      for (final tamano in Tamano.values) {
        expect(
          find.byKey(Key('chip-tamano-${tamano.codigo}')),
          findsOneWidget,
          reason: 'falta el tamaño ${tamano.etiqueta}',
        );
      }
    });

    testWidgets('al marcar un tamaño pide su precio', (tester) async {
      await _mostrar(tester);

      expect(find.byKey(const Key('campo-precio-tamano-ch')), findsNothing);

      await tester.tap(find.byKey(const Key('chip-tamano-ch')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('campo-precio-tamano-ch')), findsOneWidget);
      expect(find.text('Precio Chico (MXN)'), findsOneWidget);
    });

    testWidgets('al desmarcar un tamaño quita su precio', (tester) async {
      await _mostrar(tester);

      await tester.tap(find.byKey(const Key('chip-tamano-g')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('campo-precio-tamano-g')), findsOneWidget);

      await tester.tap(find.byKey(const Key('chip-tamano-g')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('campo-precio-tamano-g')), findsNothing);
    });

    testWidgets('en edición precarga los tamaños y su precio', (tester) async {
      const producto = Producto(
        id: 'p-1',
        nombre: 'Café americano',
        precioCentavos: 3000,
        disponible: true,
        tamanos: [
          PrecioPorTamano(tamano: Tamano.ch, precioCentavos: 3000),
          PrecioPorTamano(tamano: Tamano.g, precioCentavos: 4200),
        ],
      );

      await _mostrar(tester, producto: producto);

      expect(find.byKey(const Key('campo-precio-tamano-ch')), findsOneWidget);
      expect(find.byKey(const Key('campo-precio-tamano-g')), findsOneWidget);
      expect(
        find.byKey(const Key('campo-precio-tamano-md')),
        findsNothing,
      );
      final ch = tester.widget<TextFormField>(
        find.byKey(const Key('campo-precio-tamano-ch')),
      );
      final g = tester.widget<TextFormField>(
        find.byKey(const Key('campo-precio-tamano-g')),
      );
      expect(ch.controller?.text, '30.00');
      expect(g.controller?.text, '42.00');
    });
  });

  group('guardar con tamaños', () {
    testWidgets('manda los tamaños y el precio es el menor', (tester) async {
      ProductoFormData? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    resultado =
                        await Navigator.of(context).push<ProductoFormData>(
                          MaterialPageRoute(
                            builder: (_) => const Scaffold(
                              body: SingleChildScrollView(
                                child: FormularioProducto(),
                              ),
                            ),
                          ),
                        );
                  },
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('campo-nombre')),
        'Café americano',
      );
      await tester.tap(find.byKey(const Key('chip-tamano-ch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chip-tamano-g')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('campo-precio-tamano-g')),
        '42.00',
      );
      await tester.enterText(
        find.byKey(const Key('campo-precio-tamano-ch')),
        '30.00',
      );
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(resultado, isNotNull);
      expect(resultado!.precioCentavos, 3000);
      expect(
        resultado!.tamanos.map((precio) => precio.tamano),
        [Tamano.ch, Tamano.g],
      );
      expect(resultado!.tamanos.first.precioCentavos, 3000);
      expect(resultado!.tamanos.last.precioCentavos, 4200);
    });

    testWidgets('con tamaños ya no pide el precio general', (tester) async {
      await _mostrar(tester);

      expect(find.byKey(const Key('campo-precio')), findsOneWidget);

      await tester.tap(find.byKey(const Key('chip-tamano-md')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('campo-precio')), findsNothing);
    });

    testWidgets('exige el precio de cada tamaño marcado', (tester) async {
      await _mostrar(tester);

      await tester.enterText(
        find.byKey(const Key('campo-nombre')),
        'Café americano',
      );
      await tester.tap(find.byKey(const Key('chip-tamano-xl')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Escribe un precio válido, por ejemplo 12.50'),
        findsOneWidget,
      );
    });

    testWidgets('sin tamaños el precio general sigue siendo obligatorio', (
      tester,
    ) async {
      await _mostrar(tester);

      await tester.enterText(
        find.byKey(const Key('campo-nombre')),
        'Pan dulce',
      );
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Escribe un precio válido, por ejemplo 12.50'),
        findsOneWidget,
      );
    });
  });
}
