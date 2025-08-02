import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kybers_flutter/models/user_profile.dart';
import 'package:kybers_flutter/services/profile_service.dart';

void main() {
  group('ProfileService Tests', () {
    setUp(() {
      // Reset shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and retrieve profile correctly', () async {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime.now(),
      );

      // Act
      await ProfileService.saveProfile(profile);
      final profiles = await ProfileService.getProfiles();

      // Assert
      expect(profiles.length, 1);
      expect(profiles.first.id, profile.id);
      expect(profiles.first.name, profile.name);
      expect(profiles.first.host, profile.host);
      expect(profiles.first.username, profile.username);
      expect(profiles.first.password, profile.password);
    });

    test('should set and get active profile correctly', () async {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime.now(),
      );

      // Act
      await ProfileService.saveProfile(profile);
      await ProfileService.setActiveProfile(profile.id);
      final activeProfile = await ProfileService.getActiveProfile();

      // Assert
      expect(activeProfile, isNotNull);
      expect(activeProfile!.id, profile.id);
    });

    test('should return null when no active profile is set', () async {
      // Act
      final activeProfile = await ProfileService.getActiveProfile();

      // Assert
      expect(activeProfile, isNull);
    });

    test('should delete profile correctly', () async {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime.now(),
      );

      // Act
      await ProfileService.saveProfile(profile);
      await ProfileService.setActiveProfile(profile.id);
      await ProfileService.deleteProfile(profile.id);
      
      final profiles = await ProfileService.getProfiles();
      final activeProfile = await ProfileService.getActiveProfile();

      // Assert
      expect(profiles.length, 0);
      expect(activeProfile, isNull);
    });

    test('should clear active profile correctly', () async {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime.now(),
      );

      // Act
      await ProfileService.saveProfile(profile);
      await ProfileService.setActiveProfile(profile.id);
      await ProfileService.clearActiveProfile();
      
      final activeProfile = await ProfileService.getActiveProfile();

      // Assert
      expect(activeProfile, isNull);
    });

    test('should generate unique profile IDs', () {
      // Act
      final id1 = ProfileService.generateProfileId();
      final id2 = ProfileService.generateProfileId();

      // Assert
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });

    test('should update existing profile when saving with same ID', () async {
      // Arrange
      final originalProfile = UserProfile(
        id: 'test-id',
        name: 'Original Name',
        host: 'http://original.com:8080',
        username: 'original',
        password: 'original',
        createdAt: DateTime.now(),
      );

      final updatedProfile = UserProfile(
        id: 'test-id',
        name: 'Updated Name',
        host: 'http://updated.com:8080',
        username: 'updated',
        password: 'updated',
        createdAt: originalProfile.createdAt,
      );

      // Act
      await ProfileService.saveProfile(originalProfile);
      await ProfileService.saveProfile(updatedProfile);
      final profiles = await ProfileService.getProfiles();

      // Assert
      expect(profiles.length, 1);
      expect(profiles.first.name, 'Updated Name');
      expect(profiles.first.host, 'http://updated.com:8080');
      expect(profiles.first.username, 'updated');
      expect(profiles.first.password, 'updated');
    });
  });
}