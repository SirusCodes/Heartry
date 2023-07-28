import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

typedef AsyncAccount = AsyncValue<GoogleSignInAccount?>;

final authProvider = StateNotifierProvider<AuthProvider, AsyncAccount>(
  (_) => AuthProvider(),
);

class AuthProvider extends StateNotifier<AsyncAccount> {
  AuthProvider() : super(const AsyncAccount.data(null));

  static const accessScopes = [DriveApi.driveAppdataScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: accessScopes);

  GoogleSignInAccount? getAccount() {
    return _googleSignIn.currentUser;
  }

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      final canAccess = await _googleSignIn.canAccessScopes(accessScopes);
      if (!canAccess) {
        await _googleSignIn.requestScopes(accessScopes);
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
}
