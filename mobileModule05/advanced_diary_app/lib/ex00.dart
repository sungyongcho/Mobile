import 'package:advanced_diary_app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'pages/initial_landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use generated options
  ); // Initialize Firebase
  runApp(AdvancedDiaryApp());
}

class AdvancedDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InitialLandingPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
