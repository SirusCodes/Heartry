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
    state = const AsyncLoading();
    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: _accessScopes,
      );
      await _saveAuthTokensAndConfig(account);
      state = AsyncAccount.data(account);
    } on GoogleSignInException catch (e, st) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        state = const AsyncAccount.data(null);
      } else {
        state = AsyncAccount.error(e, st);
      }
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
    const serverClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    await _googleSignIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    try {
      final account = await _googleSignIn.attemptLightweightAuthentication();

      if (account != null) {
        await _saveAuthTokensAndConfig(account);
      }

      return account;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveAuthTokensAndConfig(GoogleSignInAccount account) async {
    final serverAuth = await account.authorizationClient.authorizeServer(
      _accessScopes,
    );
    if (serverAuth == null) {
      throw Exception('Failed to get server auth');
    }
    try {
      await ref
          .read(tokenManagerProvider)
          .getAndSaveTokensFromAuthCode(serverAuth.serverAuthCode);
    } catch (e) {
      await _googleSignIn.disconnect();
      rethrow;
    }
    ref.read(configProvider.notifier)
      ..backupEmail = account.email
      ..isAutoBackupEnabled = true;
  }
}
