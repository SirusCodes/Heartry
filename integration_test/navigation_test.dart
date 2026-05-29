import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:heartry/database/database.dart';
import 'package:heartry/database/config.dart';
import 'package:heartry/init_get_it.dart';
import 'package:heartry/utils/router.dart';
import 'package:heartry/main.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setupTestDatabase() async {
  SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': false});

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
Full Navigation Flow: Onboarding, Poems list, Settings traversal, and browser fallbacks''',
    (WidgetTester tester) async {
      // 1. Setup DB and SharedPreferences mocks
      await setupTestDatabase();

      // 2. Launch App with MaterialApp.router and goRouter
      await tester.pumpWidget(const ProviderScope(child: MyApp()));

      await tester.pumpAndSettle();

      // 3. Verify onboarding welcomes user initially
      expect(find.text("Welcome!"), findsOneWidget);

      // Programmatically set name and complete
      // onboarding using the Riverpod container
      final element = tester.element(find.byType(MyApp));
      final container = ProviderScope.containerOf(element);
      container.read(configProvider.notifier).name = 'Test Poet';
      container.read(configProvider.notifier).hasCompletedOnboarding = true;

      // Navigate straight to '/poems' to test home and settings traversal
      goRouter.go('/poems');
      await tester.pumpAndSettle();

      // Verify PoemScreen is loaded
      expect(find.text("Heartry"), findsOneWidget);

      // 4. Navigate to Settings programmatically
      goRouter.go('/settings');
      await tester.pumpAndSettle();

      // Verify SettingsScreen is loaded
      expect(find.text("Settings"), findsOneWidget);

      // Traversing Settings Options
      final settingsList = [
        {'route': '/profile', 'text': 'Profile'},
        {'route': '/personalize', 'text': 'Personalize'},
        {'route': '/backup', 'text': 'Backup Setting'},
        {'route': '/bin', 'text': 'Bin'},
        {'route': '/about', 'text': 'About'},
      ];

      for (final option in settingsList) {
        goRouter.go(option['route']!);
        await tester.pumpAndSettle();

        // Verify sub-page is open
        expect(find.text(option['text']!), findsOneWidget);

        // Navigate back to Settings programmatically
        goRouter.go('/settings');
        await tester.pumpAndSettle();

        // Verify back on SettingsScreen
        expect(find.text("Settings"), findsOneWidget);
      }

      // Go back to home
      goRouter.go('/poems');
      await tester.pumpAndSettle();
      expect(find.text("Heartry"), findsOneWidget);

      // 5. Test Browser fallback for writing screen with non-existent ID -> redirects to /writing
      goRouter.go('/writing/9999');
      await tester.pumpAndSettle();

      // It should redirect to '/writing' and show new empty writing screen (with Title field empty)
      expect(find.text("Title"), findsOneWidget);

      // 6. Test Browser fallback for reader screen with
      // non-existent ID -> displays Poem not found
      goRouter.go('/reader/9999');
      await tester.pumpAndSettle();

      // Verify 'Poem not found' error screen is visible
      expect(find.text("Poem not found"), findsOneWidget);

      // Tap 'Go back to home' button programmatically or via click
      goRouter.go('/poems');
      await tester.pumpAndSettle();

      // Verify we are back on home
      expect(find.text("Heartry"), findsOneWidget);
    },
  );
}
