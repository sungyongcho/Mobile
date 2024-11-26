import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MaterialApp(home: CalculatorApp()));
}

class ButtonData {
  final String label;
  final Color color;

  ButtonData(this.label, this.color);
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  String _expression = '0';
  String _result = '0';

  final TextEditingController _expressionController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  @override
  void dispose() {
    _expressionController.dispose();
    _resultController.dispose();
    super.dispose();
  }

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
                    controller: _expressionController,
                    readOnly: true,
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
                    controller: _resultController,
                    readOnly: true,
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
                      ButtonData('-', Colors.white),
                    ], buttonPadding, buttonFontSize),
                    buildButtonRow([
                      ButtonData('1', Colors.black),
                      ButtonData('2', Colors.black),
                      ButtonData('3', Colors.black),
                      ButtonData('x', Colors.white),
                      ButtonData('÷', Colors.white),
                    ], buttonPadding, buttonFontSize),
                    buildButtonRow([
                      ButtonData('0', Colors.black),
                      ButtonData('.', Colors.black),
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

  void onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        // Delete the last character
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          if (_expression.isEmpty) {
            _expression = '0';
          }
        }
      } else if (buttonText == 'AC') {
        // Clear the expression and result
        _expression = '0';
        _result = '0';
      } else if (buttonText == '=') {
        // Evaluate the expression
        try {
          Parser p = Parser();
          String expString =
              _expression.replaceAll('x', '*').replaceAll('÷', '/');
          Expression exp = p.parse(expString);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result = eval.toString();
        } catch (e) {
          _result = 'Error';
        }
      } else {
        if (_expression == '0') {
          if (buttonText == '.' || '+-x÷'.contains(buttonText)) {
            _expression += buttonText;
          } else if ('0123456789'.contains(buttonText)) {
            _expression = buttonText;
          } else {
            _expression = buttonText;
          }
        } else {
          _expression += buttonText;
        }
      }

      _expressionController.text = _expression;
      _resultController.text = _result;
    });
  }

  Row buildButtonRow(
      List<ButtonData> buttonDataList, double padding, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttonDataList.map((buttonData) {
        return TextButton(
          onPressed: () {
            onButtonPressed(buttonData.label);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(padding, padding),
            alignment: Alignment.center,
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
