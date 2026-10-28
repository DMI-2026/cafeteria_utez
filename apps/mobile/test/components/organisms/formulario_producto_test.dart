import 'package:cafeteria_utez/components/organisms/formulario_producto.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormularioProducto', () {
    Future<ProductoFormData?> abrir(
      WidgetTester tester, {
      Producto? producto,
    }) async {
      ProductoFormData? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  resultado = await FormularioProducto.mostrar(
                    context,
                    producto: producto,
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      return resultado;
    }

    testWidgets('el selector muestra los 3 tipos del contrato', (tester) async {
      await abrir(tester);

      await tester.tap(find.byKey(const Key('campo-tipo')));
      await tester.pumpAndSettle();

      expect(find.text('Alimento'), findsWidgets);
      expect(find.text('Bebida caliente'), findsOneWidget);
      expect(find.text('Bebida fría'), findsOneWidget);
    });

    testWidgets('la descripción es multilínea con tope de 200', (tester) async {
      await abrir(tester);

      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('campo-descripcion')),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.maxLength, 200);
      expect(campo.maxLines, greaterThan(1));
    });

    testWidgets('al editar precarga descripcion y tipo del producto', (
      tester,
    ) async {
      const producto = Producto(
        id: 'p-1',
        nombre: 'Café de olla',
        precioCentavos: 2500,
        disponible: true,
        descripcion: 'Café con canela y piloncillo',
        tipo: 'bebida_caliente',
      );

      await abrir(tester, producto: producto);

      expect(find.text('Café con canela y piloncillo'), findsOneWidget);
      expect(find.text('Bebida caliente'), findsOneWidget);
    });

    testWidgets('guarda descripcion y tipo seleccionados en ProductoFormData', (
      tester,
    ) async {
      ProductoFormData? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  resultado = await FormularioProducto.mostrar(context);
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('campo-nombre')),
        'Agua de jamaica',
      );
      await tester.enterText(find.byKey(const Key('campo-precio')), '20.00');
      await tester.enterText(
        find.byKey(const Key('campo-descripcion')),
        'Fría, bien de hielo',
      );
      await tester.tap(find.byKey(const Key('campo-tipo')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bebida fría').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(resultado?.descripcion, 'Fría, bien de hielo');
      expect(resultado?.tipo, 'bebida_fria');
    });

    testWidgets('por defecto el tipo es alimento y la descripcion vacía', (
      tester,
    ) async {
      ProductoFormData? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  resultado = await FormularioProducto.mostrar(context);
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('campo-nombre')), 'Taco');
      await tester.enterText(find.byKey(const Key('campo-precio')), '15.00');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(resultado?.tipo, 'alimento');
      expect(resultado?.descripcion, '');
    });
  });
}
