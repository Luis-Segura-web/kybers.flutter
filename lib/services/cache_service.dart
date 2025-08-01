import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel.dart';
import '../models/category.dart';

/// Service for managing persistent cache of channels and categories
class CacheService {
  static const String _channelsCachePrefix = 'channels_cache_';
  static const String _categoriesCachePrefix = 'categories_cache_';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  
  // Cache expiration time in hours
  static const int cacheExpirationHours = 1;

  /// Get cached channels for a user profile
  static Future<List<Channel>?> getCachedChannels(String profileId, [String? categoryId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getChannelsCacheKey(profileId, categoryId);
      final timestampKey = '${_cacheTimestampPrefix}${cacheKey}';
      
      // Check if cache exists and is not expired
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null || _isCacheExpired(timestamp)) {
        return null;
      }
      
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;
      
      final List<dynamic> channelsJson = jsonDecode(cachedData);
      return channelsJson.map((json) => Channel.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache channels for a user profile
  static Future<void> cacheChannels(String profileId, List<Channel> channels, [String? categoryId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getChannelsCacheKey(profileId, categoryId);
      final timestampKey = '${_cacheTimestampPrefix}${cacheKey}';
      
      final channelsJson = channels.map((channel) => channel.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(channelsJson));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail cache operations
    }
  }

  /// Get cached categories for a user profile
  static Future<List<Category>?> getCachedCategories(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_categoriesCachePrefix}${profileId}';
      final timestampKey = '${_cacheTimestampPrefix}${cacheKey}';
      
      // Check if cache exists and is not expired
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null || _isCacheExpired(timestamp)) {
        return null;
      }
      
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;
      
      final List<dynamic> categoriesJson = jsonDecode(cachedData);
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache categories for a user profile
  static Future<void> cacheCategories(String profileId, List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_categoriesCachePrefix}${profileId}';
      final timestampKey = '${_cacheTimestampPrefix}${cacheKey}';
      
      final categoriesJson = categories.map((category) => category.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(categoriesJson));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail cache operations
    }
  }

  /// Clear all cache for a specific profile
  static Future<void> clearProfileCache(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final keysToRemove = keys.where((key) => 
        key.contains(profileId) && (
          key.startsWith(_channelsCachePrefix) ||
          key.startsWith(_categoriesCachePrefix) ||
          key.startsWith(_cacheTimestampPrefix)
        )).toList();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Silently fail cache operations
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final keysToRemove = keys.where((key) => 
        key.startsWith(_channelsCachePrefix) ||
        key.startsWith(_categoriesCachePrefix) ||
        key.startsWith(_cacheTimestampPrefix)
      ).toList();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Silently fail cache operations
    }
  }

  /// Check if cache is expired
  static bool _isCacheExpired(int timestamp) {
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expirationTime = cacheTime.add(Duration(hours: cacheExpirationHours));
    return DateTime.now().isAfter(expirationTime);
  }

  /// Generate cache key for channels
  static String _getChannelsCacheKey(String profileId, String? categoryId) {
    if (categoryId != null) {
      return '${_channelsCachePrefix}${profileId}_category_${categoryId}';
    }
    return '${_channelsCachePrefix}${profileId}_all';
  }

  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final profileKeys = keys.where((key) => key.contains(profileId)).toList();
      final cacheInfo = <String, dynamic>{};
      
      for (final key in profileKeys) {
        if (key.startsWith(_cacheTimestampPrefix)) {
          final timestamp = prefs.getInt(key);
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final isExpired = _isCacheExpired(timestamp);
            cacheInfo[key] = {
              'timestamp': cacheTime.toIso8601String(),
              'expired': isExpired,
            };
          }
        }
      }
      
      return cacheInfo;
    } catch (e) {
      return {};
    }
  }
}