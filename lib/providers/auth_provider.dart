import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

import '../database/config.dart';
import 'token_manager.dart';

const _accessScopes = [DriveApi.driveAppdataScope];

typedef AsyncAccount = AsyncValue<GoogleSignInAccount?>;

final _googleSignInProvider = Provider(
  (_) => GoogleSignIn(
    scopes: _accessScopes,
    forceCodeForRefreshToken: true,
    serverClientId: const String.fromEnvironment('GOOGLE_CLIENT_ID'),
  ),
);

final authProvider = AsyncNotifierProvider<AuthProvider, GoogleSignInAccount?>(
  AuthProvider.new,
);

class AuthProvider extends AsyncNotifier<GoogleSignInAccount?> {
  GoogleSignIn get _googleSignIn => ref.read(_googleSignInProvider);

  GoogleSignInAccount? getAccount() {
    return _googleSignIn.currentUser;
  }

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      final canAccess = await _googleSignIn.requestScopes(_accessScopes);
      if (account == null || !canAccess) {
        state = AsyncAccount.error('Access denied', StackTrace.current);
        return;
      }

      await ref
          .read(tokenManagerProvider)
          .getAndSaveTokensFromAuthCode(account.serverAuthCode!);
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
        _googleSignIn.signOut(),
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
  FutureOr<GoogleSignInAccount?> build() {
    return getAccount();
  }
}
