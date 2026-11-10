//Implementacion Base
sealed class AuthFailure implements Exception {
  const AuthFailure();
}

class CredencialesInvalidas extends AuthFailure {
  const CredencialesInvalidas();
}

class CorreoYaRegistrado extends AuthFailure {
  const CorreoYaRegistrado();
}

class ContrasenaDebil extends AuthFailure {
  const ContrasenaDebil();
}

class CorreoNoConfirmado extends AuthFailure {
  const CorreoNoConfirmado();
}

class DemasiadosIntentos extends AuthFailure {
  const DemasiadosIntentos();
}

class SinConexion extends AuthFailure {
  const SinConexion();
}

class AuthDesconocida extends AuthFailure {
  const AuthDesconocida();
}
