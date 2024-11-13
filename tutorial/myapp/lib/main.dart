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
          child: Image.network(
              'https://i.ebayimg.com/images/g/w0sAAOSwBnFkn370/s-l1200.jpg')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('hi'),
        backgroundColor: Colors.red[500],
      ),
    );
  }
}
