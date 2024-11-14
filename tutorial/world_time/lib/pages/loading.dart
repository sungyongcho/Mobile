import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void getTime() async {
    Response response = await get(Uri.parse(
        'https://timeapi.io/api/time/current/zone?timeZone=Europe%2FParis'));
    Map data = jsonDecode(response.body);

    // get properties from data
    String datetime = data['dateTime'];
    // no need as using diff. api - String offset = data['offset'].substring(1, 3);
    // print(datetime);

    // create DateTime object
    DateTime now = DateTime.parse(datetime);
    // no need as using diff. api - now.add(Duration(hours: int.parse(offset)));
    print(now);
  }

  @override
  void initState() {
    super.initState();
    getTime();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('loading screen'),
    );
  }
}
