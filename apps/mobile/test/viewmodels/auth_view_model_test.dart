import 'package:cafeteria_utez/repositories/fake_auth_repository.dart';
import 'package:cafeteria_utez/viewmodels/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuthViewModel vm;

  setUp(() async {
    vm = AuthViewModel(FakeAuthRepository());
    await pumpEventQueue(); // deja llegar el estado inicial de la sesión
  });

  tearDown(() => vm.dispose());

  group('iniciarSesion', () {
    test('con credenciales válidas deja al usuario en sesión', () async {
      final ok = await vm.iniciarSesion(
        correo: FakeAuthRepository.correoDemo,
        contrasena: FakeAuthRepository.contrasenaDemo,
      );

      expect(ok, isTrue);
      expect(vm.usuario?.correo, FakeAuthRepository.correoDemo);
      expect(vm.error, isEmpty);
    });

    test('con correo mal escrito no llama al repositorio', () async {
      final ok = await vm.iniciarSesion(
        correo: 'personal.utez.edu.mx',
        contrasena: FakeAuthRepository.contrasenaDemo,
      );

      expect(ok, isFalse);
      expect(vm.usuario, isNull);
      expect(vm.error, 'Escribe un correo válido.');
    });

    test(
      'con contraseña equivocada muestra un mensaje sin texto técnico',
      () async {
        final ok = await vm.iniciarSesion(
          correo: FakeAuthRepository.correoDemo,
          contrasena: 'equivocada',
        );

        expect(ok, isFalse);
        expect(vm.error, 'Correo o contraseña incorrectos.');
      },
    );
  });

  group('registrar', () {
    test('con datos válidos crea la cuenta y abre sesión', () async {
      final ok = await vm.registrar(
        correo: 'ana@utez.edu.mx',
        contrasena: 'cafeteria2026',
        nombre: 'Ana',
      );

      expect(ok, isTrue);
      expect(vm.usuario?.nombre, 'Ana');
    });

    test('con nombre de una letra no llama al repositorio', () async {
      final ok = await vm.registrar(
        correo: 'ana@utez.edu.mx',
        contrasena: 'cafeteria2026',
        nombre: ' A ',
      );

      expect(ok, isFalse);
      expect(vm.usuario, isNull);
      expect(vm.error, 'Escribe tu nombre (mínimo 2 letras).');
    });

    test('con contraseña corta no llama al repositorio', () async {
      final ok = await vm.registrar(
        correo: 'ana@utez.edu.mx',
        contrasena: '1234',
        nombre: 'Ana',
      );

      expect(ok, isFalse);
      expect(vm.error, 'La contraseña debe tener al menos 8 caracteres.');
    });

    test('con un correo ya registrado avisa', () async {
      final ok = await vm.registrar(
        correo: FakeAuthRepository.correoDemo,
        contrasena: 'cafeteria2026',
        nombre: 'Otra persona',
      );

      expect(ok, isFalse);
      expect(vm.error, 'El correo ya está registrado.');
    });
  });

  test('cerrarSesion deja la sesión vacía', () async {
    await vm.iniciarSesion(
      correo: FakeAuthRepository.correoDemo,
      contrasena: FakeAuthRepository.contrasenaDemo,
    );

    await vm.cerrarSesion();

    expect(vm.usuario, isNull);
  });
}
