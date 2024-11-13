import 'package:flutter/material.dart';
import 'quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              quote.text,
              style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
            ),
            SizedBox(height: 6.0),
            Text(
              quote.author,
              style: TextStyle(fontSize: 14.0, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
