import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

final googleSignInProvider =
    StateNotifierProvider<GoogleSignInProvider, GoogleSignInAccount?>((ref) {
  return GoogleSignInProvider(
    ref.read,
    ref.read(_googleSignInService).currentUser,
  );
});

final _googleSignInService = Provider<_GoogleSignInService>(
  (ref) => _GoogleSignInService(),
);

class GoogleSignInProvider extends StateNotifier<GoogleSignInAccount?> {
  GoogleSignInProvider(this.read, GoogleSignInAccount? user) : super(user);
  final Reader read;

  Future<void> signIn() async {
    state = await read(_googleSignInService).signIn();
  }

  Future<void> signOut() async {
    state = await read(_googleSignInService).signOut();
  }
}

class _GoogleSignInService {
  _GoogleSignInService()
      : googleSignIn = GoogleSignIn(
          scopes: [drive.DriveApi.driveAppdataScope],
        );
  final GoogleSignIn googleSignIn;

  GoogleSignInAccount? get currentUser => googleSignIn.currentUser;
  Future<GoogleSignInAccount?> signIn() => googleSignIn.signIn();
  Future<GoogleSignInAccount?> signOut() => googleSignIn.disconnect();
}
