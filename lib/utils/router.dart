import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/config.dart';
import '../database/database.dart';
import '../screens/about_screen/about_screen.dart';
import '../screens/backup_setting_screen/backup_setting_screen.dart';
import '../screens/bin_screen/bin_screen.dart';
import '../screens/image_screen/custom_template_creator.dart';
import '../screens/image_screen/image_screen.dart';
import '../screens/intro_screen/intro_screen.dart';
import '../screens/personalize_theme/personalize_theme.dart';
import '../screens/poems_screen/poems_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/reader_screen/reader_screen.dart';
import '../screens/restore_screen/restore_screen.dart';
import '../screens/settings_screen/settings_screen.dart';
import '../screens/share_images_screen/share_images_screen.dart';
import '../screens/writing_screen/writing_screen.dart';

class RootInitialScreen extends ConsumerWidget {
  const RootInitialScreen({super.key});

  static const String routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configProvider);
    return configAsync.when(
      data: (config) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (config.hasCompletedOnboarding) {
            context.go(PoemScreen.routePath);
          } else {
            context.go(IntroScreen.routePath);
          }
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (err, st) => Scaffold(body: Center(child: Text("$err"))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

final GoRouter goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: RootInitialScreen.routePath,
      builder: (context, state) => const RootInitialScreen(),
    ),
    GoRoute(
      path: IntroScreen.routePath,
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: RestoreScreen.routePath,
      builder: (context, state) => const RestoreScreen(),
    ),
    GoRoute(
      path: PoemScreen.routePath,
      builder: (context, state) => const PoemScreen(),
    ),
    GoRoute(
      path: WritingScreen.routePath,
      builder: (context, state) => const WritingScreen(),
    ),
    GoRoute(
      path: WritingScreen.routePathWithId,
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = idStr != null ? int.tryParse(idStr) : null;
        final extraModel = state.extra as PoemModel?;
        return WritingScreen(model: extraModel, poemId: id);
      },
    ),
    GoRoute(
      path: ReaderScreen.routePath,
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = idStr != null ? int.tryParse(idStr) : null;
        final extraModel = state.extra as PoemModel?;
        final isFromBin = state.uri.queryParameters['bin'] == 'true';
        return ReaderScreen(
          model: extraModel,
          poemId: id,
          isFromBin: isFromBin,
        );
      },
    ),
    GoRoute(
      path: ImageScreen.routePath,
      builder: (context, state) {
        final params = state.extra as Map<String, String?>;
        return ImageScreen(
          title: params['title'],
          poet: params['poet'],
          poem: params['poem'] ?? "",
        );
      },
    ),
    GoRoute(
      path: CustomTemplateCreator.routePath,
      builder: (context, state) => const CustomTemplateCreator(),
    ),
    GoRoute(
      path: ShareImagesScreen.routePath,
      builder: (context, state) {
        final images = state.extra as List<String>;
        return ShareImagesScreen(images: images);
      },
    ),
    GoRoute(
      path: SettingsScreen.routePath,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: ProfileScreen.routePath,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: PersonalizeScreen.routePath,
      builder: (context, state) => const PersonalizeScreen(),
    ),
    GoRoute(
      path: BackupSettingScreen.routePath,
      builder: (context, state) => const BackupSettingScreen(),
    ),
    GoRoute(
      path: BinScreen.routePath,
      builder: (context, state) => const BinScreen(),
    ),
    GoRoute(
      path: AboutScreen.routePath,
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
