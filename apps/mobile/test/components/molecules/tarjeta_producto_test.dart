import 'package:cafeteria_utez/components/molecules/tarjeta_producto.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/models/tamano.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _mostrar(WidgetTester tester, Producto producto) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TarjetaProducto(
          producto: producto,
          onEditar: () {},
          onDarDeBaja: () {},
          onReactivar: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('TarjetaProducto y tamaños', () {
    testWidgets('sin tamaños muestra el precio normal', (tester) async {
      const producto = Producto(
        id: 'p-1',
        nombre: 'Pan dulce',
        precioCentavos: 1250,
        disponible: true,
      );

      await _mostrar(tester, producto);

      expect(find.text('\$12.50'), findsOneWidget);
      expect(find.text('Desde '), findsNothing);
    });

    testWidgets('con tamaños muestra «Desde» y el precio menor', (tester) async {
      const producto = Producto(
        id: 'p-2',
        nombre: 'Café americano',
        precioCentavos: 4200,
        disponible: true,
        tamanos: [
          PrecioPorTamano(tamano: Tamano.g, precioCentavos: 4200),
          PrecioPorTamano(tamano: Tamano.ch, precioCentavos: 3000),
        ],
      );

      await _mostrar(tester, producto);

      expect(find.text('Desde '), findsOneWidget);
      expect(find.text('\$30.00'), findsOneWidget);
      expect(find.text('\$42.00'), findsNothing);
    });

    testWidgets('lista los tamaños disponibles', (tester) async {
      const producto = Producto(
        id: 'p-3',
        nombre: 'Café americano',
        precioCentavos: 3000,
        disponible: true,
        tamanos: [
          PrecioPorTamano(tamano: Tamano.ch, precioCentavos: 3000),
          PrecioPorTamano(tamano: Tamano.md, precioCentavos: 3600),
          PrecioPorTamano(tamano: Tamano.g, precioCentavos: 4200),
        ],
      );

      await _mostrar(tester, producto);

      expect(find.text('Chico · Mediano · Grande'), findsOneWidget);
    });

    testWidgets('un producto agotado con tamaños conserva el «Desde»', (
      tester,
    ) async {
      const producto = Producto(
        id: 'p-4',
        nombre: 'Café americano',
        precioCentavos: 3000,
        disponible: false,
        tamanos: [
          PrecioPorTamano(tamano: Tamano.ch, precioCentavos: 3000),
        ],
      );

      await _mostrar(tester, producto);

      expect(find.text('Desde '), findsOneWidget);
      expect(find.text('Agotado'), findsOneWidget);
    });
  });
}
