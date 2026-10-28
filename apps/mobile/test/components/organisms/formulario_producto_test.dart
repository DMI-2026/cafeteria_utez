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
}
