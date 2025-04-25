import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'shared_prefs_provider.dart';

final appVersionManagerProvider = Provider(AppVersionManagerProvider.new);

class AppVersionManagerProvider {
  const AppVersionManagerProvider(this.ref);

  static const _buildNumberKey = "buildNumber";
  final ProviderRef ref;

  Future<bool> isAppUpdated() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final sharedPrefs = await ref.read(sharedPrefsProvider.future);

    final installedVersion = packageInfo.version;
    final sharedPrefVersion = sharedPrefs.getString(_buildNumberKey);

    if (installedVersion != sharedPrefVersion) {
      sharedPrefs.setString(_buildNumberKey, packageInfo.version);
      return true;
    }

    return false;
  }
}
