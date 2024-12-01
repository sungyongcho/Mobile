import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();

const String AUTH0_DOMAIN = 'dev-fb7oqdb8wywh7mm6.eu.auth0.com';
const String AUTH0_CLIENT_ID = 'DiZbX3AyOUmYDLkr4SKKBLiP0YlLG5ns';

const String AUTH0_REDIRECT_URI = 'com.auth0.flutter:/callback';
const String AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

class InitialLandingPage extends StatelessWidget {
  Future<void> _login(BuildContext context) async {
    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          scopes: ['openid', 'profile', 'email'],
        ),
      );

      if (result != null) {
        print('Navigating to diary Page...');
        // Navigate to the diary Page with user information
        Navigator.pushNamed(context, '/diary', arguments: {
          'accessToken': result.accessToken,
        });
      }
    } catch (e) {
      print('Login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diary App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to your Diary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
