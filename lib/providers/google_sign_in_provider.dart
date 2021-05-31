import 'dart:io';

import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'shared_prefs_provider.dart';

final googleSignInProvider = StateNotifierProvider<GoogleSignInProvider,
    AsyncValue<GoogleSignInAccount?>>((ref) {
  return GoogleSignInProvider(ref.read);
});

class GoogleSignInProvider
    extends StateNotifier<AsyncValue<GoogleSignInAccount?>> {
  GoogleSignInProvider(Reader read)
      : googleSignIn = GoogleSignIn(scopes: [
          drive.DriveApi.driveAppdataScope,
        ]),
        super(const AsyncLoading()) {
    state = AsyncData(googleSignIn.currentUser);
    _sharedPrefsProvider = read(sharedPrefsProvider);
  }

  final GoogleSignIn googleSignIn;
  late SharedPrefsProvider _sharedPrefsProvider;

  Future<Map<String, String>>? get authHeader =>
      googleSignIn.currentUser?.authHeaders;

  Future<void> signIn() async {
    try {
      final user = await googleSignIn.signIn();
      if (user == null) {
        state = AsyncError("Please sign in to continue");
      } else {
        _updateUserInfo(user);
        state = AsyncData(user);
      }
    } on PlatformException catch (e) {
      if (e.code == "sign_in_failed") {
        state = AsyncError("Something went wrong while signing in");
      }
    } on SocketException {
      state = AsyncError("Please check your network connection");
    }
  }

  void _updateUserInfo(GoogleSignInAccount user) {
    // update name if not set
    _sharedPrefsProvider.name ??= user.displayName;

    // add profile if present and not set
    if (user.photoUrl != null && _sharedPrefsProvider.profile == null) {
      // TODO: Add save and update image
    }
  }

  Future<void> signOut() async {
    try {
      state = AsyncData(await googleSignIn.disconnect());
    } on PlatformException catch (e) {
      if (e.code == "status") {
        state = AsyncError(
          e.code,
          StackTrace.fromString(e.stacktrace ?? ""),
        );
      }
    } on SocketException {
      state = AsyncError("Please check your network connection");
    }
  }
}
