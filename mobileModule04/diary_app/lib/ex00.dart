import 'package:flutter/material.dart';
import 'package:diary_app/pages/diary_page.dart';
import 'package:diary_app/pages/initial_landing_page_00.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InitialLandingPage(),
        '/diary': (context) => DiaryPage(),
      },
    );
  }
}
