import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert';

class AuthService {
  static final FlutterAppAuth _appAuth = FlutterAppAuth();

  static const String _auth0Domain = 'dev-fb7oqdb8wywh7mm6.eu.auth0.com';
  static const String _auth0ClientId = 'DiZbX3AyOUmYDLkr4SKKBLiP0YlLG5ns';
  static const String _auth0RedirectUri = 'com.auth0.flutter:/callback';
  static const String _auth0Issuer = 'https://$_auth0Domain';

  static Future<String?> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _auth0ClientId,
          _auth0RedirectUri,
          issuer: _auth0Issuer,
          scopes: ['openid', 'profile', 'email'],
        ),
      );

      // Extract email from ID token
      final idToken = result.idToken!;
      final payload = _parseJwt(idToken);
      return payload['email'];
    } catch (e) {
      print('Login failed: $e');
    }
    return null;
  }

  static Future<void> logout() async {
    try {
      // Construct the Auth0 logout URL
      final logoutUrl = Uri.parse(
          'https://$_auth0Domain/v2/logout?client_id=$_auth0ClientId&returnTo=$_auth0RedirectUri');

      // Make an HTTP GET request to log out
      final response = await http.get(logoutUrl);

      if (response.statusCode == 200) {
        print('Logged out successfully.');
        // Clear locally stored tokens if necessary
      } else {
        print('Logout failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  static Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    final payload = base64Url.normalize(parts[1]); // Normalize Base64
    final decoded = utf8.decode(base64Url.decode(payload)); // Decode
    return json.decode(decoded); // Convert to Map
  }
}
