import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(
      title: Text('my first app'),
      centerTitle: true,
      backgroundColor: Colors.red[600],
    ),
    body: const Center(
      child: Text(
        'hello world',
        style: TextStyle(
			fontSize: 20.0,
			fontWeight: FontWeight.bold,
			letterSpacing: 2.0,
			color: Color.fromARGB(255, 158, 158, 158),
			fontFamily: 'Doto'
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: Text('btn'),
      backgroundColor: Colors.red[500],
    ),
  ),
));
