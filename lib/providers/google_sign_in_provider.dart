import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

final googleSignInProvider = StateNotifierProvider<GoogleSignInProvider,
    AsyncValue<GoogleSignInAccount?>>((ref) {
  return GoogleSignInProvider();
});

class GoogleSignInProvider
    extends StateNotifier<AsyncValue<GoogleSignInAccount?>> {
  GoogleSignInProvider()
      : googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]),
        super(const AsyncLoading()) {
    state = AsyncData(googleSignIn.currentUser);
  }
  final GoogleSignIn googleSignIn;

  Future<Map<String, String>>? get authHeader =>
      googleSignIn.currentUser?.authHeaders;

  Future<void> signIn() async {
    try {
      final user = await googleSignIn.signIn();
      if (user == null) {
        state = AsyncError("Please sign in to continue");
      } else {
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

  Future<void> signOut() async {
    try {
      state = AsyncData(await googleSignIn.signOut());
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
