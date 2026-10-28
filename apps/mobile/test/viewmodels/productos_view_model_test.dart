import 'package:cafeteria_utez/core/errors/http_failure.dart';
import 'package:cafeteria_utez/models/producto.dart';
import 'package:cafeteria_utez/viewmodels/productos_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_menu_repository.dart';

void main() {
  const cafe = Producto(
    id: 'p-1',
    nombre: 'Café americano',
    precioCentavos: 1800,
    disponible: true,
  );

  group('ProductosViewModel', () {
    test('cargar deja la lista y quita el estado de cargando', () async {
      final repo = FakeMenuRepository(inicial: [cafe]);
      final vm = ProductosViewModel(repo);

      final futuro = vm.cargar();
      expect(vm.cargando, isTrue);
      await futuro;

      expect(vm.cargando, isFalse);
      expect(vm.productos, hasLength(1));
      expect(vm.error, isNull);
      expect(vm.vacio, isFalse);
    });

    test('cargar con el menú vacío marca vacio', () async {
      final vm = ProductosViewModel(FakeMenuRepository());

      await vm.cargar();

      expect(vm.vacio, isTrue);
      expect(vm.error, isNull);
    });

    test('un fallo de conexión deja un mensaje accionable', () async {
      final repo = FakeMenuRepository()
        ..fallaAlListar = const ConnectionFailure('sin red');
      final vm = ProductosViewModel(repo);

      await vm.cargar();

      expect(vm.cargando, isFalse);
      expect(vm.error, contains('No pudimos cargar'));
      expect(vm.productos, isEmpty);
    });

    test('un error del servidor se explica sin stack trace', () async {
      final repo = FakeMenuRepository()
        ..fallaAlListar = const ServerFailure(500);
      final vm = ProductosViewModel(repo);

      await vm.cargar();

      expect(vm.error, contains('servidor'));
      expect(vm.error, isNot(contains('Instance of')));
    });

    test('crear agrega el producto y recarga la lista', () async {
      final repo = FakeMenuRepository();
      final vm = ProductosViewModel(repo);
      await vm.cargar();

      final ok = await vm.crear(nombre: 'Pan dulce', precioCentavos: 1250);

      expect(ok, isTrue);
      expect(vm.productos.single.nombre, 'Pan dulce');
      expect(vm.productos.single.precioCentavos, 1250);
      expect(repo.llamadasListar, greaterThanOrEqualTo(2));
    });

    test(
      'flujo de duplicado: muestra el 409, corrige el nombre y guarda',
      () async {
        final repo = FakeMenuRepository(inicial: [cafe]);
        final vm = ProductosViewModel(repo);
        await vm.cargar();
        expect(repo.llamadasListar, 1);

        repo.fallasAlCrear.add(
          const ClientFailure(
            409,
            body: '{"error":"Ya existe un producto con ese nombre"}',
            message: 'Ya existe un producto con ese nombre',
          ),
        );

        final duplicado = await vm.crear(
          nombre: 'Café americano',
          precioCentavos: 1800,
        );

        expect(duplicado, isFalse);
        expect(vm.error, contains('Ya existe un producto con ese nombre'));
        expect(vm.productos, hasLength(1));
        expect(vm.productos.single.nombre, 'Café americano');
        expect(repo.llamadasCrear, 1);
        expect(repo.llamadasListar, 1);

        final corregido = await vm.crear(
          nombre: 'Café de olla',
          precioCentavos: 1800,
        );

        expect(corregido, isTrue);
        expect(vm.error, isNull);
        expect(vm.productos.map((p) => p.nombre), contains('Café de olla'));
        expect(repo.llamadasCrear, 2);
        expect(repo.llamadasListar, 2);
      },
    );

    test('actualizar reemplaza el producto con los nuevos datos', () async {
      final repo = FakeMenuRepository(inicial: [cafe]);
      final vm = ProductosViewModel(repo);
      await vm.cargar();

      final ok = await vm.actualizar(
        'p-1',
        nombre: 'Café de olla',
        precioCentavos: 2000,
        disponible: true,
      );

      expect(ok, isTrue);
      expect(vm.productos.single.nombre, 'Café de olla');
      expect(vm.productos.single.precioCentavos, 2000);
    });

    test('darDeBaja deja el producto como agotado (M-04)', () async {
      final repo = FakeMenuRepository(inicial: [cafe]);
      final vm = ProductosViewModel(repo);
      await vm.cargar();

      final ok = await vm.darDeBaja('p-1');

      expect(ok, isTrue);
      expect(vm.productos.single.disponible, isFalse);
    });

    test('reactivar vuelve a marcar disponible', () async {
      final repo = FakeMenuRepository(
        inicial: [cafe.copyWith(disponible: false)],
      );
      final vm = ProductosViewModel(repo);
      await vm.cargar();

      final ok = await vm.reactivar('p-1');

      expect(ok, isTrue);
      expect(vm.productos.single.disponible, isTrue);
    });

    test('si guardar falla regresa false y conserva la lista', () async {
      final repo = FakeMenuRepository(inicial: [cafe])
        ..fallaAlGuardar = const ServerFailure(500);
      final vm = ProductosViewModel(repo);
      await vm.cargar();

      final ok = await vm.crear(nombre: 'Té', precioCentavos: 1000);

      expect(ok, isFalse);
      expect(vm.productos, hasLength(1));
      expect(vm.error, contains('servidor'));
    });

    test('un 409 deja el mensaje en errorNombre sin error general', () async {
      final repo = FakeMenuRepository(inicial: [cafe])
        ..fallaAlGuardar = const ClientFailure(
          409,
          message: 'Ya existe un producto con ese nombre',
        );
      final vm = ProductosViewModel(repo);
      await vm.cargar();

      final ok = await vm.crear(nombre: 'Café americano', precioCentavos: 1800);

      expect(ok, isFalse);
      expect(vm.errorNombre, 'Ya existe un producto con ese nombre');
      expect(vm.error, isNull);
      expect(vm.productos, hasLength(1));
    });

    test('notifica a quien escucha en cada cambio de estado', () async {
      final vm = ProductosViewModel(FakeMenuRepository(inicial: [cafe]));
      var notificaciones = 0;
      vm.addListener(() => notificaciones++);

      await vm.cargar();

      expect(notificaciones, greaterThanOrEqualTo(2));
    });

    test('hayNombreDuplicado compara el nombre normalizado', () async {
      final vm = ProductosViewModel(FakeMenuRepository(inicial: [cafe]));
      await vm.cargar();

      expect(vm.hayNombreDuplicado(' cafe   AMERICANO '), isTrue);
    });

    test('hayNombreDuplicado cuenta también los productos agotados', () async {
      final vm = ProductosViewModel(
        FakeMenuRepository(inicial: [cafe.copyWith(disponible: false)]),
      );
      await vm.cargar();

      expect(vm.hayNombreDuplicado('Café americano'), isTrue);
    });

    test('hayNombreDuplicado ignora el propio id al editar', () async {
      final vm = ProductosViewModel(FakeMenuRepository(inicial: [cafe]));
      await vm.cargar();

      expect(
        vm.hayNombreDuplicado('Café americano', excluirId: 'p-1'),
        isFalse,
      );
    });

    test('hayNombreDuplicado es falso con un nombre distinto', () async {
      final vm = ProductosViewModel(FakeMenuRepository(inicial: [cafe]));
      await vm.cargar();

      expect(vm.hayNombreDuplicado('Té'), isFalse);
    });
  });
}
