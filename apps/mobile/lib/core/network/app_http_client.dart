import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/http_failure.dart';

class AppHttpClient {
  final http.Client _client;
  final Duration timeout;
  String? authToken;

  AppHttpClient({
    http.Client? client,
    this.authToken,
    this.timeout = const Duration(seconds: 5),
  }) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    authToken = token;
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?customHeaders,
    };

    final token = authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _execute(() => _client.get(url, headers: _buildHeaders(headers)));
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _execute(
      () => _client.post(url, headers: _buildHeaders(headers), body: body),
    );
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _execute(
      () => _client.put(url, headers: _buildHeaders(headers), body: body),
    );
  }

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _execute(
      () => _client.delete(url, headers: _buildHeaders(headers), body: body),
    );
  }

  Future<http.Response> _execute(
    Future<http.Response> Function() action,
  ) async {
    try {
      final response = await action().timeout(timeout);
      return _evaluateResponse(response);
    } on SocketException catch (e) {
      throw ConnectionFailure('Fallo de red o host inalcanzable: ${e.message}');
    } on TimeoutException {
      throw const ConnectionFailure(
        'Tiempo de espera agotado al conectar con el servidor',
      );
    } on http.ClientException catch (e) {
      throw ConnectionFailure('Error en la conexión del cliente: ${e.message}');
    } on HttpFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Error inesperado durante la petición: $e', e);
    }
  }

  http.Response _evaluateResponse(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      return response;
    } else if (code >= 400 && code < 500) {
      throw ClientFailure(code, body: response.body);
    } else if (code >= 500 && code < 600) {
      throw ServerFailure(code, body: response.body);
    } else {
      throw UnknownFailure('Código de estado HTTP no esperado: $code');
    }
  }

  void close() {
    _client.close();
  }
}
