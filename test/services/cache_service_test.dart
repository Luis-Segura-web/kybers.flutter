import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kybers_flutter/models/channel.dart';
import 'package:kybers_flutter/models/category.dart';
import 'package:kybers_flutter/services/cache_service.dart';

void main() {
  group('CacheService Tests', () {
    setUp(() {
      // Reset shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should cache and retrieve channels correctly', () async {
      // Arrange
      const profileId = 'test-profile-id';
      final channels = [
        const Channel(
          id: '1',
          name: 'Test Channel 1',
          streamUrl: 'http://test.com/stream1.m3u8',
          categoryId: 'cat1',
        ),
        const Channel(
          id: '2',
          name: 'Test Channel 2',
          streamUrl: 'http://test.com/stream2.m3u8',
          categoryId: 'cat1',
        ),
      ];

      // Act
      await CacheService.cacheChannels(profileId, channels);
      final cachedChannels = await CacheService.getCachedChannels(profileId);

      // Assert
      expect(cachedChannels, isNotNull);
      expect(cachedChannels!.length, 2);
      expect(cachedChannels.first.id, '1');
      expect(cachedChannels.first.name, 'Test Channel 1');
      expect(cachedChannels.last.id, '2');
      expect(cachedChannels.last.name, 'Test Channel 2');
    });

    test('should cache and retrieve categories correctly', () async {
      // Arrange
      const profileId = 'test-profile-id';
      final categories = [
        const Category(id: '1', name: 'Sports'),
        const Category(id: '2', name: 'Movies'),
      ];

      // Act
      await CacheService.cacheCategories(profileId, categories);
      final cachedCategories = await CacheService.getCachedCategories(profileId);

      // Assert
      expect(cachedCategories, isNotNull);
      expect(cachedCategories!.length, 2);
      expect(cachedCategories.first.id, '1');
      expect(cachedCategories.first.name, 'Sports');
      expect(cachedCategories.last.id, '2');
      expect(cachedCategories.last.name, 'Movies');
    });

    test('should cache channels by category correctly', () async {
      // Arrange
      const profileId = 'test-profile-id';
      const categoryId = 'sports';
      final channels = [
        const Channel(
          id: '1',
          name: 'Sports Channel',
          streamUrl: 'http://test.com/sports.m3u8',
          categoryId: categoryId,
        ),
      ];

      // Act
      await CacheService.cacheChannels(profileId, channels, categoryId);
      final cachedChannels = await CacheService.getCachedChannels(profileId, categoryId);

      // Assert
      expect(cachedChannels, isNotNull);
      expect(cachedChannels!.length, 1);
      expect(cachedChannels.first.categoryId, categoryId);
    });

    test('should return null for non-existent cache', () async {
      // Act
      final cachedChannels = await CacheService.getCachedChannels('non-existent');
      final cachedCategories = await CacheService.getCachedCategories('non-existent');

      // Assert
      expect(cachedChannels, isNull);
      expect(cachedCategories, isNull);
    });

    test('should clear profile cache correctly', () async {
      // Arrange
      const profileId = 'test-profile-id';
      final channels = [
        const Channel(
          id: '1',
          name: 'Test Channel',
          streamUrl: 'http://test.com/test.m3u8',
          categoryId: 'test',
        ),
      ];
      final categories = [
        const Category(id: '1', name: 'Test Category'),
      ];

      // Act
      await CacheService.cacheChannels(profileId, channels);
      await CacheService.cacheCategories(profileId, categories);
      await CacheService.clearProfileCache(profileId);
      
      final cachedChannels = await CacheService.getCachedChannels(profileId);
      final cachedCategories = await CacheService.getCachedCategories(profileId);

      // Assert
      expect(cachedChannels, isNull);
      expect(cachedCategories, isNull);
    });

    test('should clear all cache correctly', () async {
      // Arrange
      const profileId1 = 'profile-1';
      const profileId2 = 'profile-2';
      final channels = [
        const Channel(
          id: '1',
          name: 'Test Channel',
          streamUrl: 'http://test.com/test.m3u8',
          categoryId: 'test',
        ),
      ];

      // Act
      await CacheService.cacheChannels(profileId1, channels);
      await CacheService.cacheChannels(profileId2, channels);
      await CacheService.clearAllCache();
      
      final cachedChannels1 = await CacheService.getCachedChannels(profileId1);
      final cachedChannels2 = await CacheService.getCachedChannels(profileId2);

      // Assert
      expect(cachedChannels1, isNull);
      expect(cachedChannels2, isNull);
    });

    test('should handle empty channel list', () async {
      // Arrange
      const profileId = 'test-profile-id';
      final channels = <Channel>[];

      // Act
      await CacheService.cacheChannels(profileId, channels);
      final cachedChannels = await CacheService.getCachedChannels(profileId);

      // Assert
      expect(cachedChannels, isNotNull);
      expect(cachedChannels!.length, 0);
    });

    test('should handle empty category list', () async {
      // Arrange
      const profileId = 'test-profile-id';
      final categories = <Category>[];

      // Act
      await CacheService.cacheCategories(profileId, categories);
      final cachedCategories = await CacheService.getCachedCategories(profileId);

      // Assert
      expect(cachedCategories, isNotNull);
      expect(cachedCategories!.length, 0);
    });
  });
}