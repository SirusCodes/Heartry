import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;

final tokenManagerProvider = Provider<TokenManager>((_) => TokenManager());

class TokenManager {
  TokenManager();

  static const storage = FlutterSecureStorage();

  static const String _accessTokenKey = "accessToken",
      _refreshToken = "refreshToken",
      _expireDate = "expireDate";

  final Uri _uri = Uri.parse('https://heartry-server.globeapp.dev');

  Future<String> getAccessToken() async {
    if (!(await _isTokenExpired())) {
      final accessToken = await storage.read(key: _accessTokenKey);
      if (accessToken == null) {
        throw Exception('Access token is null');
      }

      return accessToken;
    }

    return _getAccessTokenFromRefreshToken();
  }

  Future<void> getAndSaveTokensFromAuthCode(String serverAuthCode) async {
    final response = await http.post(
      _uri.replace(path: '/api/oauth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': serverAuthCode}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get tokens from auth code');
    }

    final json = jsonDecode(response.body);
    final refreshToken = json['refresh_token'];
    final accessToken = json['access_token'];
    final expireDate = DateTime.now().add(
      Duration(seconds: json['expires_in']),
    );

    if (!json['scope'].toString().contains(DriveApi.driveAppdataScope)) {
      throw Exception('Invalid scope');
    }

    await _saveTokensAndExpireDate(
      refreshToken: refreshToken,
      accessToken: accessToken,
      expireDate: expireDate,
    );

    return;
  }

  Future<void> clearTokens() {
    return Future.wait([
      storage.delete(key: _refreshToken),
      storage.delete(key: _accessTokenKey),
      storage.delete(key: _expireDate),
    ]);
  }

  Future<bool> hasRefreshToken() {
    return storage
        .read(key: _refreshToken)
        .then((value) => value != null)
        .catchError((_) => false);
  }

  Future<bool> _isTokenExpired() async {
    final expireDateString = await storage.read(key: _expireDate);
    if (expireDateString == null) return false;

    final expireDate = DateTime.parse(expireDateString);
    return expireDate.isBefore(DateTime.now());
  }

  Future<String> _getAccessTokenFromRefreshToken() async {
    final refreshToken = await storage.read(key: _refreshToken);
    if (refreshToken == null) {
      throw Exception('Refresh token is null');
    }

    final response = await http.post(
      _uri.replace(path: '/api/refresh_token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get access token from refresh token');
    }

    final json = jsonDecode(response.body);
    final accessToken = json['access_token'];
    final expireDate = DateTime.now().add(
      Duration(seconds: json['expires_in']),
    );
    final scope = json['scope'].toString();

    if (!scope.contains(DriveApi.driveAppdataScope)) {
      throw Exception('Invalid scope: $scope');
    }

    await updateAccessToken(accessToken: accessToken, expireDate: expireDate);

    return accessToken;
  }

  Future<void> _saveTokensAndExpireDate({
    required String refreshToken,
    required String accessToken,
    required DateTime expireDate,
  }) async {
    await Future.wait([
      storage.write(key: _refreshToken, value: refreshToken),
      storage.write(key: _accessTokenKey, value: accessToken),
      storage.write(key: _expireDate, value: expireDate.toIso8601String()),
    ]);

    return;
  }

  Future<void> updateAccessToken({
    required String accessToken,
    required DateTime expireDate,
  }) async {
    await Future.wait([
      storage.write(key: _accessTokenKey, value: accessToken),
      storage.write(key: _expireDate, value: expireDate.toIso8601String()),
    ]);

    return;
  }
}
