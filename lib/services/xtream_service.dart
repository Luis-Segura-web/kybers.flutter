import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/channel.dart';
import '../models/category.dart';

/// Service for interacting with Xtream Codes API
class XtreamService {
  static String get _host => dotenv.env['XTREAM_HOST'] ?? '';
  static String get _username => dotenv.env['XTREAM_USER'] ?? '';
  static String get _password => dotenv.env['XTREAM_PASS'] ?? '';

  static String get _baseUrl => '$_host/player_api.php';

  /// Get authentication parameters
  static Map<String, String> get _authParams => {
        'username': _username,
        'password': _password,
      };

  /// Get list of live stream categories
  static Future<List<Category>> getCategories() async {
    try {
      final params = {
        ..._authParams,
        'action': 'get_live_categories',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Get list of channels for a specific category
  static Future<List<Channel>> getChannels([String? categoryId]) async {
    try {
      final params = {
        ..._authParams,
        'action': 'get_live_streams',
        if (categoryId != null) 'category_id': categoryId,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) {
          // Build stream URL for each channel
          final streamId = json['stream_id'];
          final streamUrl = '$_host/live/$_username/$_password/$streamId.m3u8';
          
          return Channel.fromJson({
            ...json,
            'stream_url': streamUrl,
          });
        }).toList();
      } else {
        throw Exception('Failed to load channels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching channels: $e');
    }
  }

  /// Get stream URL for a specific channel
  static String getStreamUrl(String streamId) {
    return '$_host/live/$_username/$_password/$streamId.m3u8';
  }

  /// Test connection to Xtream server
  static Future<bool> testConnection() async {
    try {
      final params = {
        ..._authParams,
        'action': 'get_live_categories',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}