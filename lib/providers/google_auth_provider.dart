import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_keys.dart';
import 'shared_prefs_provider.dart';

final googleAuthProvider =
    StateNotifierProvider<GoogleAuthProvider, AsyncValue<String?>>((ref) {
  return GoogleAuthProvider(ref.read);
});

class GoogleAuthProvider extends StateNotifier<AsyncValue<String?>> {
  GoogleAuthProvider(Reader read) : super(const AsyncLoading()) {
    read(sharedPrefsProvider.future).then((sharedPrefs) {
      _sharedPreferences = sharedPrefs;
      _init();
    });
  }

  static const String _authKey = "auth";

  late SharedPreferences _sharedPreferences;

  void _init() {
    state = const AsyncLoading();
    state = AsyncData(_sharedPreferences.getString(_authKey));
  }

  void login() {}

  void _setAuthKey(String key) {
    _sharedPreferences.setString(_authKey, key);
    state = AsyncData(key);
  }
}

class _GoogleAuthService {
  _GoogleAuthService()
      : _googleSignIn = GoogleSignIn(
          clientId: APIKeys.googleAuth,
          scopes: <String>["https://www.googleapis.com/auth/drive.appdata"],
        );

  final GoogleSignIn _googleSignIn;

  Stream<GoogleSignInAccount?> get _onAuthStateChange =>
      _googleSignIn.onCurrentUserChanged;

  Future<void> _login() async {
    await _googleSignIn.signIn();
  }

  Future<void> _logout() async {
    await _googleSignIn.disconnect();
  }
}
