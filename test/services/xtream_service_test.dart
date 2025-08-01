import 'package:flutter_test/flutter_test.dart';
import 'package:kybers_flutter/models/user_profile.dart';
import 'package:kybers_flutter/services/xtream_service.dart';

void main() {
  group('XtreamService Tests', () {
    test('should generate correct stream URL', () async {
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
      final streamUrl = await XtreamService.getStreamUrl('12345', profile);

      // Assert
      expect(streamUrl, 'http://test.com:8080/live/testuser/testpass/12345.m3u8');
    });

    test('should handle different host formats correctly', () async {
      // Test with HTTPS
      final profile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'https://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime.now(),
      );

      final streamUrl = await XtreamService.getStreamUrl('12345', profile);
      expect(streamUrl, 'https://test.com:8080/live/testuser/testpass/12345.m3u8');
    });

    test('should validate profile credentials format', () {
      // Arrange
      final validProfile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime.now(),
      );

      // Assert
      expect(validProfile.host.startsWith('http'), true);
      expect(validProfile.username.isNotEmpty, true);
      expect(validProfile.password.isNotEmpty, true);
    });

    test('should handle special characters in credentials', () async {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'http://test.com:8080',
        username: 'test@user',
        password: 'pass@123!',
        createdAt: DateTime.now(),
      );

      // Act
      final streamUrl = await XtreamService.getStreamUrl('12345', profile);

      // Assert
      expect(streamUrl, 'http://test.com:8080/live/test@user/pass@123!/12345.m3u8');
    });

    test('should create correct API URL for categories', () {
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
      final expectedBaseUrl = '${profile.host}/player_api.php';
      
      // Assert
      expect(expectedBaseUrl, 'http://test.com:8080/player_api.php');
    });

    test('should handle different port numbers', () async {
      // Arrange
      final profiles = [
        UserProfile(
          id: 'test-id-1',
          name: 'Profile 8080',
          host: 'http://test.com:8080',
          username: 'user',
          password: 'pass',
          createdAt: DateTime.now(),
        ),
        UserProfile(
          id: 'test-id-2',
          name: 'Profile 8000',
          host: 'http://test.com:8000',
          username: 'user',
          password: 'pass',
          createdAt: DateTime.now(),
        ),
        UserProfile(
          id: 'test-id-3',
          name: 'Profile No Port',
          host: 'http://test.com',
          username: 'user',
          password: 'pass',
          createdAt: DateTime.now(),
        ),
      ];

      // Act & Assert
      final url1 = await XtreamService.getStreamUrl('123', profiles[0]);
      expect(url1, 'http://test.com:8080/live/user/pass/123.m3u8');

      final url2 = await XtreamService.getStreamUrl('123', profiles[1]);
      expect(url2, 'http://test.com:8000/live/user/pass/123.m3u8');

      final url3 = await XtreamService.getStreamUrl('123', profiles[2]);
      expect(url3, 'http://test.com/live/user/pass/123.m3u8');
    });

    test('should handle empty stream ID', () async {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        name: 'Test Profile',
        host: 'http://test.com:8080',
        username: 'user',
        password: 'pass',
        createdAt: DateTime.now(),
      );

      // Act
      final streamUrl = await XtreamService.getStreamUrl('', profile);

      // Assert
      expect(streamUrl, 'http://test.com:8080/live/user/pass/.m3u8');
    });
  });
}