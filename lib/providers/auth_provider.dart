import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;

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

  static const ACCESS_TOKEN = 'access_token';
  static const REFRESH_TOKEN = 'refresh_token';

  GoogleSignInAccount? getAccount() {
    return _googleSignIn.currentUser;
  }

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      final canAccess = await _googleSignIn.requestScopes(_accessScopes);
      if (!canAccess) {
        state = AsyncAccount.error('Access denied', StackTrace.current);
      }

      // final refreshToken = await _getRefreshToken(account!.serverAuthCode!);
      // final accessToken = (await account.authentication).accessToken;

      // if (refreshToken == null || accessToken == null) {
      //   state = AsyncAccount.error('Failed to get tokens', StackTrace.current);
      //   return;
      // }

      // await _saveTokens(refreshToken, accessToken);

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

  Future<String?> _getRefreshToken(String authCode) async {
    final url = Uri.parse('https://accounts.google.com/o/oauth2/token');

    final body = {
      'code': authCode,
      'client_id': const String.fromEnvironment('GOOGLE_CLIENT_ID'),
      'client_secret': const String.fromEnvironment('GOOGLE_CLIENT_SECRET'),
      'redirect_uri': '',
      'grant_type': 'code',
      'access_type': 'offline',
    };

    final response = await http.post(url, body: body);

    final json = jsonDecode(response.body);

    return json['refresh_token'];
  }

  Future<void> _saveTokens(String refreshToken, String accessToken) {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    return Future.wait([
      storage.write(key: REFRESH_TOKEN, value: refreshToken),
      storage.write(key: ACCESS_TOKEN, value: accessToken),
    ]);
  }

  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    if (!forceRefresh) {
      return storage.read(key: ACCESS_TOKEN);
    }

    final newToken = await _getAccessTokenFromServer();

    await storage.write(key: ACCESS_TOKEN, value: newToken);

    return newToken;
  }

  Future<String> _getAccessTokenFromServer() {
    final uri = Uri.parse('https://www.googleapis.com/oauth2/v4/token');

    final body = {
      'client_id': const String.fromEnvironment('GOOGLE_CLIENT_ID'),
      'client_secret': const String.fromEnvironment('GOOGLE_CLIENT_SECRET'),
      'refresh_token': '',
      'grant_type': 'refresh_token',
    };

    return http
        .post(uri, body: body)
        .then((value) => jsonDecode(value.body)['access_token']);
  }

  @override
  FutureOr<GoogleSignInAccount?> build() {
    return getAccount();
  }
}
