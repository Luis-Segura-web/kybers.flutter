import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/metadata.dart';

/// Service for interacting with TMDB API
class TMDBService {
  static String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  /// Search for movies/TV shows by title
  static Future<Metadata?> searchByTitle(String title) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    try {
      // First try searching for movies
      final movieResult = await _searchMovies(title);
      if (movieResult != null) return movieResult;

      // Then try searching for TV shows
      final tvResult = await _searchTVShows(title);
      if (tvResult != null) return tvResult;

      return null;
    } catch (e) {
      print('Error searching TMDB: $e');
      return null;
    }
  }

  /// Search for movies
  static Future<Metadata?> _searchMovies(String title) async {
    final params = {
      'api_key': _apiKey,
      'query': title,
      'language': 'es-ES',
    };

    final uri = Uri.parse('$_baseUrl/search/movie')
        .replace(queryParameters: params);
    
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      
      if (results.isNotEmpty) {
        return Metadata.fromJson(results.first);
      }
    }

    return null;
  }

  /// Search for TV shows
  static Future<Metadata?> _searchTVShows(String title) async {
    final params = {
      'api_key': _apiKey,
      'query': title,
      'language': 'es-ES',
    };

    final uri = Uri.parse('$_baseUrl/search/tv')
        .replace(queryParameters: params);
    
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      
      if (results.isNotEmpty) {
        return Metadata.fromJson(results.first);
      }
    }

    return null;
  }

  /// Get trending movies/TV shows
  static Future<List<Metadata>> getTrending() async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final params = {
        'api_key': _apiKey,
        'language': 'es-ES',
      };

      final uri = Uri.parse('$_baseUrl/trending/all/day')
          .replace(queryParameters: params);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        return results.map((json) => Metadata.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching trending: $e');
    }

    return [];
  }

  /// Test TMDB API connection
  static Future<bool> testConnection() async {
    if (_apiKey.isEmpty) {
      return false;
    }

    try {
      final params = {'api_key': _apiKey};
      final uri = Uri.parse('$_baseUrl/configuration')
          .replace(queryParameters: params);
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}