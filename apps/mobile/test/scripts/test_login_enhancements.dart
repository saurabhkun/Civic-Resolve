import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/login_page.dart';

void main() {
  group('Login Page Enhancements Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('Login page should display password field under Aadhaar field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );

      // Find Aadhaar number field
      expect(find.byType(TextFormField), findsWidgets);
      
      // Find password field (should be second TextFormField for citizen login)
      final passwordField = find.byType(TextFormField).at(1);
      expect(passwordField, findsOneWidget);
      
      // Check if password field has correct properties
      final passwordWidget = tester.widget<TextFormField>(passwordField);
      expect(passwordWidget.obscureText, isTrue);
      expect(passwordWidget.decoration?.labelText, equals('Password'));
    });

    testWidgets('Login page should display Remember Me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );

      // Find Remember Me checkbox
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.text('Remember Me'), findsOneWidget);
      expect(find.text('Skip login next time'), findsOneWidget);
    });

    testWidgets('Password field should toggle visibility when eye icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );

      // Find the password field's visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility);
      expect(visibilityButton, findsOneWidget);

      // Tap the visibility toggle
      await tester.tap(visibilityButton);
      await tester.pump();

      // Check if icon changed to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Remember Me checkbox should toggle state when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );

      // Find Remember Me checkbox
      final checkboxListTile = find.byType(CheckboxListTile);
      expect(checkboxListTile, findsOneWidget);

      // Check initial state (should be unchecked)
      CheckboxListTile checkbox = tester.widget<CheckboxListTile>(checkboxListTile);
      expect(checkbox.value, isFalse);

      // Tap the checkbox
      await tester.tap(checkboxListTile);
      await tester.pump();

      // Check if state changed
      checkbox = tester.widget<CheckboxListTile>(checkboxListTile);
      expect(checkbox.value, isTrue);
    });

    testWidgets('Form validation should require password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );

      // Find Aadhaar field and enter valid Aadhaar
      final aadhaarField = find.byType(TextFormField).first;
      await tester.enterText(aadhaarField, '123456789012');

      // Leave password field empty and try to submit
      final submitButton = find.text('Send OTP & Login');
      await tester.tap(submitButton);
      await tester.pump();

      // Should show password validation error
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Password validation should enforce minimum length', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );

      // Find password field and enter short password
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, '123');

      // Try to submit
      final submitButton = find.text('Send OTP & Login');
      await tester.tap(submitButton);
      await tester.pump();

      // Should show minimum length validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}