sealed class HttpFailure implements Exception {
  final String message;
  const HttpFailure(this.message);

  @override
  String toString() => message;
}

class ConnectionFailure extends HttpFailure {
  const ConnectionFailure([
    super.message = 'Error de conexión: tiempo de espera o sin red',
  ]);
}

class ClientFailure extends HttpFailure {
  final int statusCode;
  final String body;

  const ClientFailure(this.statusCode, {this.body = '', String? message})
    : super(message ?? 'Error del cliente ($statusCode)');
}

class ServerFailure extends HttpFailure {
  final int statusCode;
  final String body;

  const ServerFailure(this.statusCode, {this.body = '', String? message})
    : super(message ?? 'Error del servidor ($statusCode)');
}

class UnknownFailure extends HttpFailure {
  final Object? cause;

  const UnknownFailure([
    super.message = 'Error desconocido en la comunicación',
    this.cause,
  ]);
}
