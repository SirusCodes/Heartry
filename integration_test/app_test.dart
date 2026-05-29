import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';
import 'package:heartry/screens/image_screen/image_screen.dart';
import 'package:heartry/screens/image_screen/custom_template_creator.dart';
import 'package:heartry/database/database.dart';
import 'package:heartry/init_get_it.dart';
import 'package:drift/native.dart';

Future<void> setupTestDatabase() async {
  if (locator.isRegistered<Database>()) {
    await locator<Database>().close();
  }
  await locator.reset();
  locator.registerSingleton<Database>(Database(NativeDatabase.memory()));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    '''
Verify custom template flow: configure, save, load, and delete''',
    (WidgetTester tester) async {
      // Initialize in-memory database and
      // GetIt locator to isolate tests cleanly
      await setupTestDatabase();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const ImageScreen(
              title: "Test Poem",
              poet: "Test Author",
              poem: "Line 1 of poem\nLine 2 of poem",
            ),
          ),
          GoRoute(
            path: '/create-template',
            builder: (_, __) => const CustomTemplateCreator(),
          ),
        ],
      );

      // Pump ImageScreen wrapped in ProviderScope and
      // MaterialApp.router for go_router support
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.pumpAndSettle();

      // Verify default template screen is loaded
      expect(find.byType(ImageScreen), findsOneWidget);

      // Tap "Templates" bottom sheet option
      await tester.tap(find.text("Templates"));
      await tester.pumpAndSettle();

      // Verify "Save Current" option is present in the bottom sheet
      expect(find.text("Save Current"), findsOneWidget);

      // Tap "Save Current" to open dialogue
      await tester.tap(find.text("Save Current"));
      await tester.pumpAndSettle();

      // Verify Dialog is open
      expect(find.text("Save Custom Template"), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter name "Custom Aesthetic Style"
      await tester.enterText(find.byType(TextField), "Custom Aesthetic Style");
      await tester.pump();

      // Tap "Save" button in dialog
      await tester.tap(find.text("Save"));
      await tester.pumpAndSettle();

      // Verify Dialog closed
      expect(find.text("Save Custom Template"), findsNothing);

      // Tap "Templates" to check selector list
      await tester.tap(find.text("Templates"));
      await tester.pumpAndSettle();

      final temps1 = await locator<Database>().getTemplates();
      debugPrint(
        "DEBUG TEST 1: DB templates: ${temps1.map((t) => t.name).toList()}",
      );

      // Scroll until our custom template "Custom Aesthetic Style" is visible
      final listFinder1 = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text("Custom Aesthetic Style"),
        50.0,
        scrollable: listFinder1,
      );
      await tester.pumpAndSettle();

      // Verify our custom template
      // "Custom Aesthetic Style" is in the modal list
      expect(find.text("Custom Aesthetic Style"), findsOneWidget);

      // Tap on our custom template to select it
      await tester.tap(find.text("Custom Aesthetic Style"));
      await tester.pumpAndSettle();

      // Re-open Templates list to verify deletion flow
      await tester.tap(find.text("Templates"));
      await tester.pumpAndSettle();

      // Scroll until our custom template "Custom Aesthetic Style" is visible
      final listFinder3 = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text("Custom Aesthetic Style"),
        50.0,
        scrollable: listFinder3,
      );
      await tester.pumpAndSettle();

      // Verify trash can icon (delete button) exists for our custom template
      expect(find.byIcon(Icons.delete_rounded), findsOneWidget);

      // Tap delete button to remove it
      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.pumpAndSettle();

      // Verify custom template is deleted
      // and no longer visible in selector list
      expect(find.text("Custom Aesthetic Style"), findsNothing);
    },
  );

  testWidgets(
    'Verify truly custom template flow: configure, save, load, and delete',
    (WidgetTester tester) async {
      // Initialize in-memory database
      // and GetIt locator to isolate tests cleanly
      await setupTestDatabase();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const ImageScreen(
              title: "Test Poem",
              poet: "Test Author",
              poem: "Line 1 of poem\nLine 2 of poem",
            ),
          ),
          GoRoute(
            path: '/create-template',
            builder: (_, __) => const CustomTemplateCreator(),
          ),
        ],
      );

      // Pump ImageScreen wrapped in ProviderScope and
      // MaterialApp.router for go_router support
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.pumpAndSettle();

      // Verify default template screen is loaded
      expect(find.byType(ImageScreen), findsOneWidget);

      // Tap "Templates" to check selector list
      await tester.tap(find.text("Templates"));
      await tester.pumpAndSettle();

      // Verify "Create Custom" option is present on top of bottom sheet
      expect(find.text("Create Custom"), findsOneWidget);

      // Tap "Create Custom" button to open creator screen
      await tester.tap(find.text("Create Custom"));
      await tester.pumpAndSettle();

      // Verify CustomTemplateCreator is open
      expect(find.text("Create Template"), findsOneWidget);

      // Change template name
      final nameField = find.byKey(const Key('template_name_field'));
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, "My Super Custom Style");
      await tester.pump();

      // Select Gradient background
      await tester.tap(find.text("Gradient"));
      await tester.pumpAndSettle();

      // Select Bubble overlay
      await tester.tap(find.text("Bubble"));
      await tester.pumpAndSettle();

      // Select Frosted Glass frame
      await tester.tap(find.text("Frosted Glass"));
      await tester.pumpAndSettle();

      // Tap save icon button
      await tester.tap(find.byIcon(Icons.save_rounded));
      await tester.pumpAndSettle();

      // Verify creator screen closed and we are back on ImageScreen
      expect(find.text("Create Template"), findsNothing);

      // Open Templates list to verify it's loaded and selected
      await tester.tap(find.text("Templates"));
      await tester.pumpAndSettle();

      final temps2 = await locator<Database>().getTemplates();
      debugPrint(
        "DEBUG TEST 2: DB templates: ${temps2.map((t) => t.name).toList()}",
      );

      // Scroll until our custom template "My Super Custom Style" is visible
      final listFinder2 = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text("My Super Custom Style"),
        50.0,
        scrollable: listFinder2,
      );
      await tester.pumpAndSettle();

      // Verify "My Super Custom Style" custom template
      // is in the selector list and selected
      expect(find.text("My Super Custom Style"), findsOneWidget);

      // Delete custom template
      expect(find.byIcon(Icons.delete_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.pumpAndSettle();

      // Verify custom template is deleted
      // and no longer visible in selector list
      expect(find.text("My Super Custom Style"), findsNothing);
    },
  );
}
