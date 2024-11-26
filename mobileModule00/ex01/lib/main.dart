import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: Ex01App()));
}

class Ex01App extends StatefulWidget {
  const Ex01App({super.key});

  @override
  State<Ex01App> createState() => _Ex01AppState();
}

class _Ex01AppState extends State<Ex01App> {
  String displayedText = 'A Simple text';
  bool isOriginalText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if the device is in portrait or landscape mode
          final bool isPortrait = constraints.maxHeight > constraints.maxWidth;

          // Calculate scaling factors based on orientation
          final double fontSize = isPortrait
              ? constraints.maxWidth * 0.05
              : constraints.maxHeight * 0.05;
          final double padding = isPortrait
              ? constraints.maxWidth * 0.015
              : constraints.maxHeight * 0.015;

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: padding, vertical: padding),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 98, 98, 0), // Background color
                    borderRadius:
                        BorderRadius.all(Radius.circular(8)), // Rounded corners
                  ),
                  child: Text(
                    displayedText,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                    height: isPortrait ? constraints.maxHeight * 0.02 : 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding * 2,
                      vertical: padding, // Dynamic padding
                    ),
                  ),
                  onPressed: () {
                    // Update the state to toggle text
                    setState(() {
                      if (isOriginalText) {
                        displayedText = 'Hello World';
                      } else {
                        displayedText = 'A Simple text';
                      }
                      isOriginalText = !isOriginalText;
                    });
                  },
                  child: Text(
                    'click me',
                    style: TextStyle(fontSize: fontSize * 0.6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
