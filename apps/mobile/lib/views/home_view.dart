import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/errors/http_failure.dart';
import '../core/network/app_http_client.dart';

String get defaultBackendBaseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

class HomeView extends StatefulWidget {
  final AppHttpClient? httpClient;
  final String? baseUrl;

  const HomeView({super.key, this.httpClient, this.baseUrl});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AppHttpClient _client;
  late final String _baseUrl;

  bool _loading = true;
  String? _statusMessage;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _client = widget.httpClient ?? AppHttpClient();
    _baseUrl = widget.baseUrl ?? defaultBackendBaseUrl;
    _checkBackendConnection();
  }

  Future<void> _checkBackendConnection() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    try {
      final response = await _client.get(Uri.parse('$_baseUrl/health'));
      if (mounted) {
        setState(() {
          _loading = false;
          _isConnected = true;
          _statusMessage = 'Conectado al backend (${response.body})';
        });
      }
    } on HttpFailure catch (e) {
      if (mounted) {
        final message = switch (e) {
          ConnectionFailure(:final message) => 'Fallo de conexión: $message',
          ClientFailure(:final statusCode) =>
            'Error de cliente HTTP ($statusCode)',
          ServerFailure(:final statusCode) =>
            'Error en servidor HTTP ($statusCode)',
          UnknownFailure(:final message) => 'Error desconocido: $message',
        };
        setState(() {
          _loading = false;
          _isConnected = false;
          _statusMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _isConnected = false;
          _statusMessage = 'Error inesperado: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cafetería UTEZ')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_loading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Verificando conexión con el backend...'),
              ] else ...[
                Icon(
                  _isConnected
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _isConnected
                      ? 'Conexión Exitosa'
                      : 'Sin Conexión con Backend',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isConnected ? Colors.black87 : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _checkBackendConnection,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar conexión'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
