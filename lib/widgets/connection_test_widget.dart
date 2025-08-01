import 'package:flutter/material.dart';
import '../services/xtream_service.dart';
import '../services/tmdb_service.dart';
import '../utils/network_helper.dart';
import '../utils/helpers.dart';

/// Helper widget to test API connections
class ConnectionTestWidget extends StatefulWidget {
  const ConnectionTestWidget({super.key});

  @override
  State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
}

class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
  bool _isTesting = false;
  String _results = '';

  Future<void> _testConnections() async {
    setState(() {
      _isTesting = true;
      _results = 'Probando conexiones...\n';
    });

    final buffer = StringBuffer(_results);

    // Test internet connection
    buffer.writeln('🌐 Probando conexión a internet...');
    final hasInternet = await NetworkHelper.hasInternetConnection();
    buffer.writeln(hasInternet ? '✅ Internet: OK' : '❌ Internet: Sin conexión');

    if (hasInternet) {
      // Test Xtream connection
      buffer.writeln('\n📺 Probando conexión Xtream...');
      final xtreamOk = await XtreamService.testConnection();
      buffer.writeln(xtreamOk ? '✅ Xtream: OK' : '❌ Xtream: Error de conexión');

      // Test TMDB connection
      buffer.writeln('\n🎬 Probando conexión TMDB...');
      final tmdbOk = await TMDBService.testConnection();
      buffer.writeln(tmdbOk ? '✅ TMDB: OK' : '❌ TMDB: Error de conexión');

      buffer.writeln('\n--- Resumen ---');
      if (xtreamOk && tmdbOk) {
        buffer.writeln('🎉 Todas las conexiones están funcionando correctamente!');
      } else {
        buffer.writeln('⚠️ Algunas conexiones tienen problemas. Verifica tu configuración.');
      }
    }

    setState(() {
      _isTesting = false;
      _results = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Conexión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prueba las conexiones de API para verificar que la configuración es correcta.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            Center(
              child: ElevatedButton(
                onPressed: _isTesting ? null : _testConnections,
                child: _isTesting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Probando...'),
                        ],
                      )
                    : const Text('Probar Conexiones'),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (_results.isNotEmpty) ...[
              const Text(
                'Resultados:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _results,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}