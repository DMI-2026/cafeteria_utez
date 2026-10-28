import 'package:cafeteria_utez/components/molecules/tarjeta_producto.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/models/tipo_producto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TarjetaProducto', () {
    Future<void> mostrar(WidgetTester tester, Producto producto) {
      return tester.pumpWidget(
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
    }

    Producto producto({
      String descripcion = '',
      TipoProducto tipo = TipoProducto.alimento,
    }) {
      return Producto(
        id: 'p-1',
        nombre: 'Café americano',
        precioCentavos: 3000,
        disponible: true,
        descripcion: descripcion,
        tipo: tipo,
      );
    }

    testWidgets('muestra la descripción con un máximo de 2 líneas', (
      tester,
    ) async {
      await mostrar(tester, producto(descripcion: 'Café de grano de Morelos'));

      final texto = tester.widget<Text>(find.text('Café de grano de Morelos'));
      expect(texto.maxLines, 2);
      expect(texto.overflow, TextOverflow.ellipsis);
    });

    testWidgets('sin descripción no deja un texto vacío', (tester) async {
      await mostrar(tester, producto());

      expect(find.byKey(const Key('descripcion-producto')), findsNothing);
    });

    testWidgets('una bebida caliente muestra ícono y texto "Caliente"', (
      tester,
    ) async {
      await mostrar(tester, producto(tipo: TipoProducto.bebidaCaliente));

      final indicador = find.byKey(const Key('indicador-temperatura'));
      expect(indicador, findsOneWidget);
      expect(
        find.descendant(of: indicador, matching: find.text('Caliente')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: indicador, matching: find.byType(Icon)),
        findsOneWidget,
      );
    });

    testWidgets('una bebida fría muestra ícono y texto "Fría"', (tester) async {
      await mostrar(tester, producto(tipo: TipoProducto.bebidaFria));

      final indicador = find.byKey(const Key('indicador-temperatura'));
      expect(indicador, findsOneWidget);
      expect(
        find.descendant(of: indicador, matching: find.text('Fría')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: indicador, matching: find.byType(Icon)),
        findsOneWidget,
      );
    });

    testWidgets('caliente y fría usan íconos distintos', (tester) async {
      await mostrar(tester, producto(tipo: TipoProducto.bebidaCaliente));
      final caliente = tester
          .widget<Icon>(
            find.descendant(
              of: find.byKey(const Key('indicador-temperatura')),
              matching: find.byType(Icon),
            ),
          )
          .icon;

      await mostrar(tester, producto(tipo: TipoProducto.bebidaFria));
      final fria = tester
          .widget<Icon>(
            find.descendant(
              of: find.byKey(const Key('indicador-temperatura')),
              matching: find.byType(Icon),
            ),
          )
          .icon;

      expect(caliente, isNot(fria));
    });

    testWidgets('un alimento no muestra indicador de temperatura', (
      tester,
    ) async {
      await mostrar(tester, producto(descripcion: 'Con pollo y crema'));

      expect(find.byKey(const Key('indicador-temperatura')), findsNothing);
      expect(find.text('Caliente'), findsNothing);
      expect(find.text('Fría'), findsNothing);
    });
  });
}
