import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  static const _secureStorage = FlutterSecureStorage();

  static const String _auth0Domain = 'dev-fb7oqdb8wywh7mm6.eu.auth0.com';
  static const String _auth0ClientId = 'W5KMVcEuEUpdy9hK9isaE3tSszjuNbiD';
  static var auth0 = Auth0(_auth0Domain, _auth0ClientId);

  static Future<Map<String, String>?> login() async {
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

      final nickname = payload['nickname'] as String?; // GitHub field
      final email = payload['email'] as String?; // Google field
      final name = payload['name'] as String? ?? 'Unknown User';

      String firstName = 'Unknown';
      String lastName = 'Unknown';

      if (payload.containsKey('given_name') &&
          payload.containsKey('family_name')) {
        firstName = payload['given_name'] as String;
        lastName = payload['family_name'] as String;
      }
      // Fallback for GitHub: Split `name` into first and last names
      else if (name != 'Unknown User') {
        final nameParts = name.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : 'Unknown';
        lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Unknown';
      }

      // Determine the username: use email for Google, nickname for GitHub
      final username = email ?? nickname;

      if (username == null) {
        throw Exception(
            'User username (email or nickname) is required but not provided.');
      }

      return {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
      };
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
