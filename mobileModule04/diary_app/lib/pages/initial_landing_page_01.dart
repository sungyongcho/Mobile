import 'package:diary_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class InitialLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your Diary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userEmail = await AuthService.login();
                if (userEmail != null) {
                  // Navigate to the Profile Page
                  Navigator.pushNamed(context, '/profile', arguments: {
                    'email': userEmail,
                  });
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
