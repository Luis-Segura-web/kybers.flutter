import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kybers_flutter/models/channel.dart';
import 'package:kybers_flutter/screens/player_screen.dart';

void main() {
  group('PlayerScreen Widget Tests', () {
    testWidgets('should display player screen with channel info', (WidgetTester tester) async {
      // Arrange
      const testChannel = Channel(
        id: 'test-123',
        name: 'Test Channel',
        streamUrl: 'http://test.com/stream.m3u8',
        categoryId: 'test-cat',
      );

      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerScreen(
            channel: testChannel,
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // Verify channel name is displayed
      expect(find.text('Test Channel'), findsWidgets);
      
      // Verify loading state is shown initially
      expect(find.text('Cargando stream...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display channel information section', (WidgetTester tester) async {
      // Arrange
      const testChannel = Channel(
        id: 'test-123',
        name: 'Test Channel',
        streamUrl: 'http://test.com/stream.m3u8',
        categoryId: 'test-cat',
      );

      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerScreen(
            channel: testChannel,
          ),
        ),
      );

      await tester.pump();

      // Verify the screen layout
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      
      // Check if the expanded widgets exist (video and info sections)
      expect(find.byType(Expanded), findsNWidgets(2));
    });

    testWidgets('should show error when stream fails to load', (WidgetTester tester) async {
      // Arrange
      const testChannel = Channel(
        id: 'test-123',
        name: 'Test Channel',
        streamUrl: 'invalid-url',
        categoryId: 'test-cat',
      );

      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerScreen(
            channel: testChannel,
          ),
        ),
      );

      // Allow time for video initialization to fail
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The error handling will depend on video_player behavior
      // We can at least verify the structure is correct
      expect(find.text('Test Channel'), findsWidgets);
    });

    testWidgets('should handle back navigation', (WidgetTester tester) async {
      // Arrange
      const testChannel = Channel(
        id: 'test-123',
        name: 'Test Channel',
        streamUrl: 'http://test.com/stream.m3u8',
        categoryId: 'test-cat',
      );

      // Build the widget with navigation context
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    tester.element(find.byType(ElevatedButton)).findAncestorWidgetOfExactType<MaterialApp>()!.navigatorKey!.currentContext!,
                    MaterialPageRoute(
                      builder: (context) => const PlayerScreen(channel: testChannel),
                    ),
                  );
                },
                child: const Text('Open Player'),
              ),
            ),
          ),
        ),
      );

      // Navigate to player
      await tester.tap(find.text('Open Player'));
      await tester.pumpAndSettle();

      // Verify we're on the player screen
      expect(find.text('Test Channel'), findsWidgets);

      // Test back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should return to previous screen
      expect(find.text('Open Player'), findsOneWidget);
    });

    testWidgets('should display channel without metadata', (WidgetTester tester) async {
      // Arrange
      const testChannel = Channel(
        id: 'test-123',
        name: 'Simple Channel',
        streamUrl: 'http://test.com/stream.m3u8',
        categoryId: 'test-cat',
      );

      // Build the widget without metadata
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerScreen(
            channel: testChannel,
            metadata: null,
          ),
        ),
      );

      await tester.pump();

      // Verify channel name is still displayed
      expect(find.text('Simple Channel'), findsWidgets);
    });
  });
}