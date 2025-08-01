import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/channel.dart';
import '../models/category.dart';
import '../models/user_profile.dart';
import 'profile_service.dart';

/// Service for interacting with Xtream Codes API
class XtreamService {
  // Fallback to .env variables if no profile is provided (for backward compatibility)
  static String get _fallbackHost => dotenv.env['XTREAM_HOST'] ?? '';
  static String get _fallbackUsername => dotenv.env['XTREAM_USER'] ?? '';
  static String get _fallbackPassword => dotenv.env['XTREAM_PASS'] ?? '';

  /// Get current active profile credentials or fallback to .env
  static Future<Map<String, String>> _getCredentials([UserProfile? profile]) async {
    if (profile != null) {
      return {
        'host': profile.host,
        'username': profile.username,
        'password': profile.password,
      };
    }

    // Try to get active profile
    final activeProfile = await ProfileService.getActiveProfile();
    if (activeProfile != null) {
      return {
        'host': activeProfile.host,
        'username': activeProfile.username,
        'password': activeProfile.password,
      };
    }

    // Fallback to .env
    return {
      'host': _fallbackHost,
      'username': _fallbackUsername,
      'password': _fallbackPassword,
    };
  }

  /// Get authentication parameters
  static Future<Map<String, String>> _getAuthParams([UserProfile? profile]) async {
    final credentials = await _getCredentials(profile);
    return {
      'username': credentials['username']!,
      'password': credentials['password']!,
    };
  }

  /// Get list of live stream categories
  static Future<List<Category>> getCategories([UserProfile? profile]) async {
    try {
      final credentials = await _getCredentials(profile);
      final baseUrl = '${credentials['host']}/player_api.php';
      final authParams = await _getAuthParams(profile);
      
      final params = {
        ...authParams,
        'action': 'get_live_categories',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
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
  static Future<List<Channel>> getChannels([String? categoryId, UserProfile? profile]) async {
    try {
      final credentials = await _getCredentials(profile);
      final baseUrl = '${credentials['host']}/player_api.php';
      final authParams = await _getAuthParams(profile);
      
      final params = {
        ...authParams,
        'action': 'get_live_streams',
        if (categoryId != null) 'category_id': categoryId,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) {
          // Build stream URL for each channel
          final streamId = json['stream_id'];
          final streamUrl = '${credentials['host']}/live/${credentials['username']}/${credentials['password']}/$streamId.m3u8';
          
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
  static Future<String> getStreamUrl(String streamId, [UserProfile? profile]) async {
    final credentials = await _getCredentials(profile);
    return '${credentials['host']}/live/${credentials['username']}/${credentials['password']}/$streamId.m3u8';
  }

  /// Test connection to Xtream server
  static Future<bool> testConnection([UserProfile? profile]) async {
    try {
      final credentials = await _getCredentials(profile);
      final baseUrl = '${credentials['host']}/player_api.php';
      final authParams = await _getAuthParams(profile);
      
      final params = {
        ...authParams,
        'action': 'get_live_categories',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}