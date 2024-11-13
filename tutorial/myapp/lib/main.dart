import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my first app'),
        centerTitle: true,
        backgroundColor: Colors.red[600],
      ),
      // body: Center(child: Image.asset('assets/image2.png')),
      // body: Container(
      //   padding: EdgeInsets.all(90.0),
      //   margin: EdgeInsets.all(30.0),
      //   color: Colors.grey[400],
      //   child: Text('hello'),
      // ),
      body: Padding(
          padding: EdgeInsets.all(90.0),
          // cannot do margin:
          child: Text('hello')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('hi'),
        backgroundColor: Colors.red[500],
      ),
    );
  }
}
