import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';

class OidcService {
  static const String defaultIssuer = 'http://127.0.0.1:8000/openid';
  static const String clientId = 'unimarket-flutter';
  static const String clientSecret = 'unimarket_secret_key';
  static const String redirectUri = 'http://localhost:50000/';
  static const List<String> scopes = ['openid', 'profile', 'email'];

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyAccessToken = 'oidc_access_token';
  static const String _keyIdToken = 'oidc_id_token';
  static const String _keyRefreshToken = 'oidc_refresh_token';
  static const String _keyUserJson = 'oidc_user_json';

  String get issuerUrl => defaultIssuer;

  String get authorizeUrl =>
      '$defaultIssuer/authorize/?client_id=$clientId&response_type=code&scope=${scopes.join('+')}&redirect_uri=${Uri.encodeComponent(redirectUri)}';

  /// Check stored token or URL authorization code and restore logged-in user
  Future<UserModel?> restoreSession() async {
    // 1. Check if browser URL has ?code=... from OIDC Authorization Code redirect
    try {
      final currentUri = Uri.base;
      String? code = currentUri.queryParameters['code'];
      if ((code == null || code.isEmpty) && currentUri.fragment.contains('code=')) {
        final frag = currentUri.fragment;
        final qIndex = frag.indexOf('?');
        if (qIndex != -1) {
          final fragQuery = Uri.splitQueryString(frag.substring(qIndex + 1));
          code = fragQuery['code'];
        }
      }
      if (code != null && code.isNotEmpty) {
        debugPrint('[OIDC] Found authorization code in URL: $code');
        final user = await exchangeCodeForToken(code);
        if (user != null) {
          return user;
        }
      }
    } catch (e) {
      debugPrint('[OIDC] Error checking URL query parameters: $e');
    }

    // 2. Check stored token in secure storage
    try {
      final token = await _storage.read(key: _keyAccessToken);
      if (token != null && token.isNotEmpty) {
        // Validate token live against OIDC userinfo endpoint
        final claims = await fetchUserInfo(token);
        if (claims != null) {
          final user = UserModel.fromJson(claims);
          await _storage.write(key: _keyUserJson, value: jsonEncode(user.toJson()));
          return user;
        }

        // Fallback to cached profile if server is temporarily unreachable
        final userJson = await _storage.read(key: _keyUserJson);
        if (userJson != null) {
          final Map<String, dynamic> data = jsonDecode(userJson);
          return UserModel.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('[OIDC] Error restoring OIDC session: $e');
    }
    return null;
  }

  /// Get active access token for API requests
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (_) {
      return null;
    }
  }

  /// Get ID token (JWT)
  Future<String?> getIdToken() async {
    try {
      return await _storage.read(key: _keyIdToken);
    } catch (_) {
      return null;
    }
  }

  /// Real OIDC Login via Token Endpoint (grant_type = password)
  Future<UserModel?> login({
    required String username,
    required String password,
    String? backendUrl,
  }) async {
    final issuer = backendUrl != null ? '$backendUrl/openid' : defaultIssuer;
    try {
      debugPrint('[OIDC] Requesting token from $issuer/token/ with grant_type=password...');
      final response = await http.post(
        Uri.parse('$issuer/token/'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'client_id': clientId,
          'client_secret': clientSecret,
          'scope': scopes.join(' '),
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final accessToken = tokenData['access_token']?.toString() ?? '';
        final idToken = tokenData['id_token']?.toString() ?? '';
        final refreshToken = tokenData['refresh_token']?.toString() ?? '';

        debugPrint('[OIDC] Access Token acquired: ${accessToken.substring(0, 8)}...');

        if (accessToken.isNotEmpty) {
          final claims = await fetchUserInfo(accessToken, issuer: issuer);
          final user = claims != null
              ? UserModel.fromJson(claims)
              : UserModel(
                  id: 1,
                  username: username,
                  email: '$username@ubu.ac.th',
                  displayName: username,
                );

          // Store tokens securely
          await _storage.write(key: _keyAccessToken, value: accessToken);
          if (idToken.isNotEmpty) await _storage.write(key: _keyIdToken, value: idToken);
          if (refreshToken.isNotEmpty) await _storage.write(key: _keyRefreshToken, value: refreshToken);
          await _storage.write(key: _keyUserJson, value: jsonEncode(user.toJson()));

          return user;
        }
      } else {
        debugPrint('[OIDC] Token error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('[OIDC] Login network error: $e');
    }
    return null;
  }

  /// Real OIDC Authorization Code exchange (grant_type = authorization_code)
  Future<UserModel?> exchangeCodeForToken(String code, {String? backendUrl}) async {
    final issuer = backendUrl != null ? '$backendUrl/openid' : defaultIssuer;
    try {
      debugPrint('[OIDC] Exchanging authorization code at $issuer/token/ ...');
      final response = await http.post(
        Uri.parse('$issuer/token/'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final accessToken = tokenData['access_token']?.toString() ?? '';
        final idToken = tokenData['id_token']?.toString() ?? '';
        final refreshToken = tokenData['refresh_token']?.toString() ?? '';

        if (accessToken.isNotEmpty) {
          final claims = await fetchUserInfo(accessToken, issuer: issuer);
          final user = claims != null ? UserModel.fromJson(claims) : null;
          if (user != null) {
            await _storage.write(key: _keyAccessToken, value: accessToken);
            if (idToken.isNotEmpty) await _storage.write(key: _keyIdToken, value: idToken);
            if (refreshToken.isNotEmpty) await _storage.write(key: _keyRefreshToken, value: refreshToken);
            await _storage.write(key: _keyUserJson, value: jsonEncode(user.toJson()));
            return user;
          }
        }
      } else {
        debugPrint('[OIDC] Code exchange failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('[OIDC] Code exchange error: $e');
    }
    return null;
  }

  /// Fetch userinfo from OIDC endpoint using access token
  Future<Map<String, dynamic>?> fetchUserInfo(String accessToken, {String? issuer}) async {
    final iss = issuer ?? defaultIssuer;
    try {
      final response = await http.get(
        Uri.parse('$iss/userinfo/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[OIDC] Error fetching OIDC userinfo: $e');
    }
    return null;
  }

  /// Clear tokens and end session
  Future<void> logout() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyIdToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUserJson);
      debugPrint('[OIDC] Session cleared.');
    } catch (e) {
      debugPrint('[OIDC] Error clearing OIDC session: $e');
    }
  }
}
