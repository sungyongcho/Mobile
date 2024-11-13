import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Home()));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('my first app'),
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
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Image.asset('assets/image.png'),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.cyan,
                child: const Text('1'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.pinkAccent,
                child: const Text('2'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.amber,
                child: const Text('3'),
              ),
            ),
          ],
        ));
  }
}
