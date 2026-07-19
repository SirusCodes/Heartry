import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

import '../database/config.dart';
import 'token_manager.dart';

const _accessScopes = [DriveApi.driveAppdataScope];

typedef AsyncAccount = AsyncValue<GoogleSignInAccount?>;

final _googleSignInProvider = Provider((_) => GoogleSignIn.instance);

final authProvider = AsyncNotifierProvider<AuthProvider, GoogleSignInAccount?>(
  AuthProvider.new,
);

class AuthProvider extends AsyncNotifier<GoogleSignInAccount?> {
  GoogleSignIn get _googleSignIn => ref.read(_googleSignInProvider);

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.authenticate();

      final serverAuth = await account.authorizationClient.authorizeServer(
        _accessScopes,
      );
      if (serverAuth == null) {
        state = AsyncAccount.error(
          'Failed to get server auth',
          StackTrace.current,
        );
        return;
      }
      final serverAuthCode = serverAuth.serverAuthCode;

      try {
        await ref
            .read(tokenManagerProvider)
            .getAndSaveTokensFromAuthCode(serverAuthCode);
      } catch (e) {
        await _googleSignIn.disconnect();
        rethrow;
      }
      ref.read(configProvider.notifier)
        ..backupEmail = account.email
        ..isAutoBackupEnabled = true;

      state = AsyncAccount.data(account);
    } catch (e, st) {
      state = AsyncAccount.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.disconnect(),
        ref.read(tokenManagerProvider).clearTokens(),
      ]);
      ref.read(configProvider.notifier)
        ..backupEmail = null
        ..isAutoBackupEnabled = false;

      state = const AsyncAccount.data(null);
    } catch (e, st) {
      state = AsyncAccount.error(e, st);
    }
  }

  @override
  FutureOr<GoogleSignInAccount?> build() async {
    await _googleSignIn.initialize(
      serverClientId: const String.fromEnvironment('GOOGLE_CLIENT_ID'),
    );
    final result = _googleSignIn.attemptLightweightAuthentication();
    if (result is Future<GoogleSignInAccount?>) {
      return await result;
    }
    return result;
  }
}
