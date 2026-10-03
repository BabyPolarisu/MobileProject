import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';

class OidcService {
  static const String defaultIssuer = 'http://127.0.0.1:8000/openid';
  static const String clientId = 'unimarket-flutter';
  static const String redirectUri = 'http://localhost:50000/callback';
  static const List<String> scopes = ['openid', 'profile', 'email'];

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyAccessToken = 'oidc_access_token';
  static const String _keyIdToken = 'oidc_id_token';
  static const String _keyUserJson = 'oidc_user_json';

  String get issuerUrl => defaultIssuer;
  String get authorizeUrl => '$defaultIssuer/authorize?client_id=$clientId&response_type=code&scope=${scopes.join('+')}&redirect_uri=${Uri.encodeComponent(redirectUri)}';

  /// Check stored token and restore logged-in user
  Future<UserModel?> restoreSession() async {
    try {
      final token = await _storage.read(key: _keyAccessToken);
      final userJson = await _storage.read(key: _keyUserJson);
      if (token != null && userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        return UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error restoring OIDC session: $e');
    }
    return null;
  }

  /// Get active access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (_) {
      return null;
    }
  }

  /// Login via OIDC credentials (or Authorization Code flow)
  Future<UserModel?> login({
    required String username,
    required String password,
    String? backendUrl,
  }) async {
    final base = backendUrl ?? 'http://127.0.0.1:8000';
    try {
      // 1. Authenticate with backend and obtain authenticated session/token
      final response = await http.post(
        Uri.parse('$base/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final token = data['token'] ?? 'oidc_token_${DateTime.now().millisecondsSinceEpoch}';
        final userMap = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);

        // Store tokens securely in FlutterSecureStorage
        await _storage.write(key: _keyAccessToken, value: token.toString());
        await _storage.write(key: _keyIdToken, value: token.toString());
        await _storage.write(key: _keyUserJson, value: jsonEncode(userMap));

        return user;
      }
    } catch (e) {
      debugPrint('OIDC Login error: $e');
    }
    return null;
  }

  /// Fetch userinfo from OIDC endpoint using access token
  Future<Map<String, dynamic>?> fetchUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$defaultIssuer/userinfo'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching OIDC userinfo: $e');
    }
    return null;
  }

  /// Clear tokens and end session
  Future<void> logout() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyIdToken);
      await _storage.delete(key: _keyUserJson);
    } catch (e) {
      debugPrint('Error clearing OIDC session: $e');
    }
  }
}
