import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

const _accessScopes = [DriveApi.driveAppdataScope];

typedef AsyncAccount = AsyncValue<GoogleSignInAccount?>;

final _googleSignInProvider = Provider(
  (_) => GoogleSignIn(scopes: _accessScopes),
);

final authProvider = StateNotifierProvider<AuthProvider, AsyncAccount>(
  AuthProvider.new,
);

class AuthProvider extends StateNotifier<AsyncAccount> {
  AuthProvider(Ref ref)
      : _ref = ref,
        super(const AsyncAccount.data(null)) {
    userState = _googleSignIn.onCurrentUserChanged.listen((account) {
      state = AsyncAccount.data(account);
    });
  }

  final Ref _ref;
  late final StreamSubscription<GoogleSignInAccount?> userState;

  GoogleSignIn get _googleSignIn => _ref.read(_googleSignInProvider);

  GoogleSignInAccount? getAccount() {
    return _googleSignIn.currentUser;
  }

  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      final canAccess = await _googleSignIn.requestScopes(_accessScopes);
      if (!canAccess) {
        throw Exception("Cannot access Google Drive");
      }

      state = AsyncAccount.data(account);
    } catch (e, st) {
      state = AsyncAccount.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      state = const AsyncAccount.data(null);
    } catch (e, st) {
      state = AsyncAccount.error(e, st);
    }
  }

  @override
  void dispose() {
    super.dispose();
    userState.cancel();
  }
}
