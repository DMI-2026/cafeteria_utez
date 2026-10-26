import 'package:flutter/foundation.dart';

/// URL base de la API según la plataforma.
///
/// En el emulador de Android `localhost` es el propio emulador, por eso se usa
/// `10.0.2.2` para llegar a la máquina anfitriona.
String get defaultBackendBaseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}
