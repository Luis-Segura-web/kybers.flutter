import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'xtream_service.dart';

/// Service for managing user profiles and authentication
class ProfileService {
  static const String _profilesKey = 'user_profiles';
  static const String _activeProfileKey = 'active_profile_id';

  /// Get all stored profiles
  static Future<List<UserProfile>> getProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList(_profilesKey) ?? [];
      
      return profilesJson
          .map((json) => UserProfile.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      throw Exception('Error loading profiles: $e');
    }
  }

  /// Get the currently active profile
  static Future<UserProfile?> getActiveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeProfileId = prefs.getString(_activeProfileKey);
      
      if (activeProfileId == null) return null;
      
      final profiles = await getProfiles();
      return profiles.where((profile) => profile.id == activeProfileId).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Save a new profile or update existing one
  static Future<void> saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profiles = await getProfiles();
      
      // Remove existing profile with same ID if it exists
      profiles.removeWhere((p) => p.id == profile.id);
      
      // Add the new/updated profile
      profiles.add(profile);
      
      // Save to shared preferences
      final profilesJson = profiles
          .map((p) => jsonEncode(p.toJson()))
          .toList();
      
      await prefs.setStringList(_profilesKey, profilesJson);
    } catch (e) {
      throw Exception('Error saving profile: $e');
    }
  }

  /// Delete a profile
  static Future<void> deleteProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profiles = await getProfiles();
      
      profiles.removeWhere((p) => p.id == profileId);
      
      // If this was the active profile, clear it
      final activeProfileId = prefs.getString(_activeProfileKey);
      if (activeProfileId == profileId) {
        await prefs.remove(_activeProfileKey);
      }
      
      // Save updated profiles list
      final profilesJson = profiles
          .map((p) => jsonEncode(p.toJson()))
          .toList();
      
      await prefs.setStringList(_profilesKey, profilesJson);
    } catch (e) {
      throw Exception('Error deleting profile: $e');
    }
  }

  /// Set a profile as active
  static Future<void> setActiveProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeProfileKey, profileId);
      
      // Update the profile's last used timestamp
      final profiles = await getProfiles();
      final profileIndex = profiles.indexWhere((p) => p.id == profileId);
      
      if (profileIndex != -1) {
        final updatedProfile = profiles[profileIndex].copyWith(
          lastUsed: DateTime.now(),
        );
        profiles[profileIndex] = updatedProfile;
        
        // Save updated profiles
        final profilesJson = profiles
            .map((p) => jsonEncode(p.toJson()))
            .toList();
        
        await prefs.setStringList(_profilesKey, profilesJson);
      }
    } catch (e) {
      throw Exception('Error setting active profile: $e');
    }
  }

  /// Clear the active profile (logout)
  static Future<void> clearActiveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeProfileKey);
    } catch (e) {
      throw Exception('Error clearing active profile: $e');
    }
  }

  /// Generate a unique ID for new profiles
  static String generateProfileId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Validate profile credentials by testing connection
  static Future<bool> validateProfile(UserProfile profile) async {
    try {
      return await XtreamService.testConnection(profile);
    } catch (e) {
      return false;
    }
  }

  /// Test Xtream connection with provided credentials
  static Future<bool> _testXtreamConnection(UserProfile profile) async {
    try {
      // This is now handled by XtreamService.testConnection
      return await XtreamService.testConnection(profile);
    } catch (e) {
      return false;
    }
  }
}

// Extension to add firstOrNull method if not available
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}