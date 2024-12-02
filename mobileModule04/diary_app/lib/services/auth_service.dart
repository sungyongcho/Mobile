import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  static final _secureStorage = FlutterSecureStorage();

  static const String _auth0Domain = 'dev-fb7oqdb8wywh7mm6.eu.auth0.com';
  static const String _auth0ClientId = 'DiZbX3AyOUmYDLkr4SKKBLiP0YlLG5ns';
  static var auth0 = Auth0(_auth0Domain, _auth0ClientId);

  static Future<String?> login() async {
    try {
      final result = await auth0
          .webAuthentication()
          .login(parameters: {'prompt': 'login'});

      // Save tokens securely
      await _secureStorage.write(key: 'id_token', value: result.idToken);
      await _secureStorage.write(
          key: 'access_token', value: result.accessToken);

      // Extract email from ID token
      final idToken = result.idToken!;
      final payload = _parseJwt(idToken);

      final email = payload['email'] as String?; // Google field
      final nickname = payload['nickname'] as String?; // GitHub field
      final username = email ?? nickname;

      return username;
    } catch (e) {
      print('Login failed: $e');
    }
    return null;
  }

  /// Logout method that performs server-side logout and clears tokens locally
  static Future<void> logout() async {
    try {
      // await logoutTwo();
      // await logoutWithPrompt();
      await _secureStorage.deleteAll();
      print('Logged out successfully.');
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  /// Retrieve the ID token from secure storage
  static Future<String?> getIdToken() async {
    return await _secureStorage.read(key: 'id_token');
  }

  /// Retrieve the Access token from secure storage
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// Helper function to decode the JWT payload
  static Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }

    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return json.decode(decoded);
  }
}
