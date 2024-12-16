import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: Ex02App()));
}

class ButtonData {
  final String label;
  final Color color;

  ButtonData(this.label, this.color);
}

class Ex02App extends StatelessWidget {
  const Ex02App({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isPortrait = screenSize.height > screenSize.width;

    final double buttonPadding = (isPortrait ? 10.0 : 10.0);
    final double buttonFontSize = (isPortrait ? 20.0 : 22.0);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 101, 125, 139),
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 101, 125, 139),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              color: const Color.fromARGB(255, 60, 73, 81),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: TextEditingController(text: '0'),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  TextField(
                    controller: TextEditingController(text: '0'),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color.fromARGB(255, 101, 125, 139),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildButtonRow([
                      ButtonData('7', Colors.black),
                      ButtonData('8', Colors.black),
                      ButtonData('9', Colors.black),
                      ButtonData('C', Colors.red),
                      ButtonData('AC', Colors.red),
                    ], buttonPadding, buttonFontSize),
                    buildButtonRow([
                      ButtonData('4', Colors.black),
                      ButtonData('5', Colors.black),
                      ButtonData('6', Colors.black),
                      ButtonData('+', Colors.white),
                      ButtonData('.', Colors.white),
                    ], buttonPadding, buttonFontSize),
                    buildButtonRow([
                      ButtonData('1', Colors.black),
                      ButtonData('2', Colors.black),
                      ButtonData('3', Colors.black),
                      ButtonData('x', Colors.white),
                      ButtonData('=', Colors.white),
                    ], buttonPadding, buttonFontSize),
                    buildButtonRow([
                      ButtonData('0', Colors.black),
                      ButtonData('-', Colors.black),
                      ButtonData('00', Colors.black),
                      ButtonData('=', Colors.white),
                      ButtonData(' ', Colors.white),
                    ], buttonPadding, buttonFontSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildButtonRow(
      List<ButtonData> buttonDataList, double padding, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttonDataList.map((buttonData) {
        return TextButton(
          onPressed: () {
            debugPrint('Button pressed: ${buttonData.label}');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove padding to align text properly
            minimumSize:
                Size(padding, padding), // Ensure consistent button size
            alignment: Alignment.center, // Center-align text
          ),
          child: Text(
            buttonData.label,
            style: TextStyle(
              fontSize: fontSize,
              color: buttonData.color,
            ),
          ),
        );
      }).toList(),
    );
  }
}
