import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kybers_flutter/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    setUp(() {
      // Reset shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display login form elements', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Wait for the widget to build
      await tester.pump();

      // Verify form elements are present
      expect(find.text('Gestión de Perfiles IPTV'), findsOneWidget);
      expect(find.text('Nuevo Perfil'), findsOneWidget);
      expect(find.text('Nombre del perfil'), findsOneWidget);
      expect(find.text('Host/Servidor'), findsOneWidget);
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.pump();

      // Try to save without filling fields
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Verify validation errors appear
      expect(find.text('Por favor ingresa un nombre'), findsOneWidget);
      expect(find.text('Por favor ingresa el host'), findsOneWidget);
      expect(find.text('Por favor ingresa el usuario'), findsOneWidget);
      expect(find.text('Por favor ingresa la contraseña'), findsOneWidget);
    });

    testWidgets('should validate host URL format', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.pump();

      // Find the host field by its label
      final hostField = find.widgetWithText(TextFormField, 'Host/Servidor');

      // Enter invalid host
      await tester.enterText(hostField, 'invalid-url');
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Verify validation error
      expect(find.text('El host debe comenzar con http:// o https://'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.pump();

      // Find password field and visibility toggle
      final visibilityToggle = find.byIcon(Icons.visibility);

      // Verify visibility toggle exists
      expect(visibilityToggle, findsOneWidget);

      // Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Verify icon changed to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should show empty profiles message when no profiles exist', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Wait for profiles to load
      await tester.pump();

      // Verify empty state message
      expect(find.text('No hay perfiles guardados.\nCrea uno para comenzar.'), findsOneWidget);
      expect(find.text('Perfiles guardados'), findsOneWidget);
    });

    testWidgets('should fill form with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.pump();

      // Find form fields by their labels
      final nameField = find.widgetWithText(TextFormField, 'Nombre del perfil');
      final hostField = find.widgetWithText(TextFormField, 'Host/Servidor');
      final usernameField = find.widgetWithText(TextFormField, 'Usuario');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');

      // Fill form with valid data
      await tester.enterText(nameField, 'Test Profile');
      await tester.enterText(hostField, 'http://test.com:8080');
      await tester.enterText(usernameField, 'testuser');
      await tester.enterText(passwordField, 'testpass');

      // Verify fields are filled
      expect(find.text('Test Profile'), findsOneWidget);
      expect(find.text('http://test.com:8080'), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('testpass'), findsOneWidget);
    });

    testWidgets('should display form validation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.pump();

      // Test partial form filling
      final nameField = find.widgetWithText(TextFormField, 'Nombre del perfil');
      await tester.enterText(nameField, 'Test');
      
      // Try to save with incomplete form
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Should still show validation errors for other fields
      expect(find.text('Por favor ingresa el host'), findsOneWidget);
      expect(find.text('Por favor ingresa el usuario'), findsOneWidget);
      expect(find.text('Por favor ingresa la contraseña'), findsOneWidget);
    });
  });
}