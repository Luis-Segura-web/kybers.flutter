/// Application constants
class AppConstants {
  static const String appName = 'Kybers IPTV';
  static const String appVersion = '1.0.0';
  
  // API timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  
  // UI constants
  static const double cardBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  
  // Video player constants
  static const Duration seekDuration = Duration(seconds: 10);
  static const Duration bufferDuration = Duration(seconds: 30);
  
  // Cache constants
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // Error messages
  static const String networkError = 'Error de conexión. Verifique su conexión a internet.';
  static const String serverError = 'Error del servidor. Intente nuevamente más tarde.';
  static const String notFoundError = 'Contenido no encontrado.';
  static const String playbackError = 'Error al reproducir el video. Intente con otro canal.';
  static const String configError = 'Error de configuración. Verifique sus credenciales.';
}