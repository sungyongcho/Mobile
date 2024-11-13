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
      body: Center(
          // child: Icon(
          //   Icons.airport_shuttle,
          //   color: Colors.lightBlue,
          //   size: 50.0,
          // ),
          // child: TextButton(
          //     onPressed: () {
          //       print('you clicked me');
          //     },
          //     child: Text('Click me'),
          //     style: TextButton.styleFrom(backgroundColor: Colors.blue)),
          // child: ElevatedButton.icon(
          //     onPressed: () {}, label: Text("mail me"), icon: Icon(Icons.mail)),
          child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.alternate_email),
              color: Colors.amber)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('hi'),
        backgroundColor: Colors.red[500],
      ),
    );
  }
}
