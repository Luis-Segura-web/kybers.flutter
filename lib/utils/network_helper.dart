import 'dart:io';

/// Network connectivity helper
class NetworkHelper {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /// Check if a specific host is reachable
  static Future<bool> canReachHost(String host) async {
    try {
      // Extract hostname from URL if needed
      final uri = Uri.tryParse(host);
      final hostname = uri?.host ?? host;
      
      final result = await InternetAddress.lookup(hostname);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}