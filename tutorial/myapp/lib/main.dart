import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(
      title: Text('my first app'),
      centerTitle: true,
    ),
    body: Center(
      child: Text('hello world')
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => (),
      child: Text('btn')
    ),
  ),
));
