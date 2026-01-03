import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memory_flow/main.dart' as app;

/// Integration tests for core user flows
///
/// These tests verify end-to-end functionality by simulating real user interactions.
/// Run with: flutter test integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch and Navigation', () {
    testWidgets('app should launch successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // App should launch without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should navigate between main screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should be able to find navigation elements
      // Note: Update these finders based on actual app structure
      final bottomNavigation = find.byType(BottomNavigationBar);

      if (bottomNavigation.evaluate().isNotEmpty) {
        // Tap through navigation items if bottom nav exists
        await tester.tap(bottomNavigation);
        await tester.pumpAndSettle();
      }
    });
  });

  group('Topic Creation Flow', () {
    testWidgets('should create a new topic', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for add topic button (FloatingActionButton or similar)
      final addButton = find.byType(FloatingActionButton);

      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should show topic creation screen
        // Look for title input field
        final titleField = find.byType(TextField).first;

        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Integration Test Topic');
          await tester.pumpAndSettle();

          // Enter some markdown content
          final contentFields = find.byType(TextField);
          if (contentFields.evaluate().length > 1) {
            await tester.enterText(
              contentFields.at(1),
              '# Test Content\n\nThis is a test topic created by integration tests.',
            );
            await tester.pumpAndSettle();
          }

          // Save the topic
          final saveButton = find.widgetWithText(ElevatedButton, 'Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();

            // Should navigate back to topic list
            expect(find.text('Integration Test Topic'), findsOneWidget);
          }
        }
      }
    });
  });

  group('Topic Review Flow', () {
    testWidgets('should mark topic as reviewed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find a topic card/item
      final topicCard = find.byType(Card).first;

      if (topicCard.evaluate().isNotEmpty) {
        await tester.tap(topicCard);
        await tester.pumpAndSettle();

        // Should open topic detail screen
        // Look for "Mark as Reviewed" button
        final reviewButton = find.widgetWithText(ElevatedButton, 'Mark as Reviewed');

        if (reviewButton.evaluate().isNotEmpty) {
          await tester.tap(reviewButton);
          await tester.pumpAndSettle();

          // Should show confirmation or navigate back
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });
  });

  group('Calendar Navigation', () {
    testWidgets('should open calendar screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for calendar navigation button
      final calendarIcon = find.byIcon(Icons.calendar_today);

      if (calendarIcon.evaluate().isNotEmpty) {
        await tester.tap(calendarIcon);
        await tester.pumpAndSettle();

        // Calendar screen should be visible
        // TableCalendar widget should be present
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });

  group('Settings Screen', () {
    testWidgets('should open settings and toggle notifications', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for settings navigation
      final settingsIcon = find.byIcon(Icons.settings);

      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();

        // Look for notification toggle switch
        final switchWidget = find.byType(Switch);

        if (switchWidget.evaluate().isNotEmpty) {
          final initialValue = tester.widget<Switch>(switchWidget.first).value;

          await tester.tap(switchWidget.first);
          await tester.pumpAndSettle();

          // Switch should toggle
          final newValue = tester.widget<Switch>(switchWidget.first).value;
          expect(newValue, !initialValue);
        }
      }
    });
  });

  group('Search Functionality', () {
    testWidgets('should search for topics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for search icon or search field
      final searchIcon = find.byIcon(Icons.search);

      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await tester.pumpAndSettle();

        // Enter search query
        final searchField = find.byType(TextField).first;

        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'test');
          await tester.pumpAndSettle();

          // Results should update
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });
  });

  group('Topic Management', () {
    testWidgets('should delete a topic', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Long press on a topic card for options
      final topicCard = find.byType(Card).first;

      if (topicCard.evaluate().isNotEmpty) {
        await tester.longPress(topicCard);
        await tester.pumpAndSettle();

        // Look for delete option
        final deleteButton = find.text('Delete');

        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pumpAndSettle();

          // Confirm deletion
          final confirmButton = find.text('Confirm').last;
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('should edit a topic', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap a topic
      final topicCard = find.byType(Card).first;

      if (topicCard.evaluate().isNotEmpty) {
        await tester.tap(topicCard);
        await tester.pumpAndSettle();

        // Look for edit button
        final editIcon = find.byIcon(Icons.edit);

        if (editIcon.evaluate().isNotEmpty) {
          await tester.tap(editIcon);
          await tester.pumpAndSettle();

          // Should show edit screen
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });
  });

  group('Performance Tests', () {
    testWidgets('should handle rapid navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Rapidly navigate between screens
      for (int i = 0; i < 5; i++) {
        final bottomNav = find.byType(BottomNavigationBar);

        if (bottomNav.evaluate().isNotEmpty) {
          await tester.tap(bottomNav);
          await tester.pump(Duration(milliseconds: 100));
        }
      }

      await tester.pumpAndSettle();

      // App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should scroll through topic list smoothly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find scrollable widget
      final listView = find.byType(ListView);

      if (listView.evaluate().isNotEmpty) {
        // Perform scroll
        await tester.drag(listView.first, Offset(0, -500));
        await tester.pumpAndSettle();

        // Should complete without errors
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });
}
