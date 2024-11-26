import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: Ex00App()));
}

class Ex00App extends StatelessWidget {
  const Ex00App({super.key});

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
                    'A Simple text',
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
                    debugPrint('Button pressed');
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
