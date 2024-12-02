import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String AUTH0_DOMAIN = 'dev-fb7oqdb8wywh7mm6.eu.auth0.com';

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  Map<String, dynamic>? _userInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve the access token passed from the login page
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final accessToken = args['accessToken'];

    // Fetch user information
    _getUserDetails(accessToken);
  }

  Future<void> _getUserDetails(String accessToken) async {
    try {
      final url = 'https://$AUTH0_DOMAIN/userinfo';
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        setState(() {
          _userInfo = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to fetch user info');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  void _logout() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary page'),
      ),
      body: Center(
        child: _userInfo != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${_userInfo!['name']}!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
