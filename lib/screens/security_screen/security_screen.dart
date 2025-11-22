import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/utils/lock_helper.dart';

import '../../database/config.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../about_screen/widgets/base_info_widget.dart';

// TODO: disable lock if hardware lock is not available once we are not supporting android Q and below

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: [
            const CScreenTitle(title: "Privacy and Security"),
            config.when(
              data: (model) {
                return BaseInfoWidget(
                  title: "Lock",
                  children: [
                    SwitchListTile.adaptive(
                      value: model.appLock,
                      title: const Text("App Lock"),
                      subtitle: const Text(
                        "When enabled, you'll need to use fingerprint or"
                        " face recognition to open the app.",
                      ),
                      onChanged: (value) async {
                        final authenticated = await LockHelper.validateLock(
                          context,
                          reason: value
                              ? 'Please authenticate to enable app lock'
                              : 'Please authenticate to disable app lock',
                        );
                        if (authenticated) {
                          ref.read(configProvider.notifier).appLock = value;
                        }
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e\n$s")),
            ),
          ],
        ),
        bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
      ),
    );
  }
}
