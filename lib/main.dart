import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'IOS Calculator',
      debugShowCheckedModeBanner: false,
      home: CalculatorIOS(),
    );
  }
}

class CalculatorIOS extends StatefulWidget {
  const CalculatorIOS({super.key});

  @override
  _CalculatorIOS createState() => _CalculatorIOS();
}

class CalcButtons extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color fontColor;
  final VoidCallback onPressed;
  final FontWeight fontWeight;

  const CalcButtons({super.key, 
    required this.text,
    required this.bgColor,
    required this.fontColor,
    required this.onPressed,
    required this.fontWeight
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = (screenWidth - 30.0) / 4; // Adjust padding and spacing

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 5.0,
        ),
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: CupertinoButton(
              onPressed: () => onPressed(),
              padding: EdgeInsets.zero,
              color: bgColor,
              borderRadius: BorderRadius.circular(buttonSize / 2),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'SFNSDisplay',
                    fontSize: buttonSize * 0.45,
                    fontWeight: fontWeight,
                    color: fontColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ZeroButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color fontColor;
  final VoidCallback onPressed;
  final FontWeight fontWeight;

  const ZeroButton(
      {super.key, required this.text,
      required this.bgColor,
      required this.fontColor,
      required this.onPressed,
      required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = (screenWidth - 30.0) / 4; // Adjust padding and spacing

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: SizedBox(
        width: buttonSize * 2 + 5.0, // Double the width of a CalcButtons
        height: buttonSize, // Match the height of a CalcButtons
        child: CupertinoButton(
          onPressed: () => onPressed(),
          padding: EdgeInsets.zero,
          color: bgColor,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Align(
            alignment: Alignment.centerLeft, // Align text to the left
            child: Padding(
              padding: const EdgeInsets.only(left: 35.0), // Adjust left padding
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'SFNSDisplay',
                  fontSize: buttonSize * 0.5,
                  fontWeight: fontWeight,
                  color: fontColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorIOS extends State<CalculatorIOS> {
  String _displayText = '0';
  String _expression = '';
  bool _isNegative = false; // Track whether the number is negative

  int _plusMinusCount = 0;

void _onPressed(String buttonText) {
  setState(() {
    if (buttonText == 'AC') {
      // Clear the entire expression and reset display to 0
      _expression = '0';
      _displayText = '0';
    } else if (buttonText == 'C') {
      // Clear the last entered digit when 'C' button is pressed
      if (_expression != '0' && _expression != 'Error') {
        if (_expression.length > 1) {
          _expression = _expression.substring(0, _expression.length - 1);
          _displayText = _expression;
        } else {
          _expression = '0';
          _displayText = '0';
        }
      }
    } else if (buttonText == '=') {
      _evaluateExpression();
    } else if (buttonText == '±') {
      // Toggle the sign of the number displayed
      if (_expression != '0' && _expression != 'Error') {
        if (_expression.isNotEmpty &&
            !_expression.endsWith('+') &&
            !_expression.endsWith('-') &&
            !_expression.endsWith('*') &&
            !_expression.endsWith('/')) {
          // If the expression is not empty and does not end with an operator,
          // toggle the sign of the number that was entered before the operation
          int lastIndex = _expression.length - 1;
          int lastOperatorIndex = _expression.lastIndexOf(RegExp(r'[+\-*/]'));
          String currentNumber = _expression.substring(lastOperatorIndex + 1);
          if (currentNumber.startsWith('-')) {
            currentNumber = currentNumber.substring(1); // Remove the negative sign
          } else {
            currentNumber = '-' + currentNumber; // Add the negative sign
          }
          _expression = _expression.replaceRange(
              lastOperatorIndex + 1, lastIndex + 1, currentNumber);
          _displayText = currentNumber; // Update display with the current number
        } else {
          // If the expression ends with an operator, toggle the sign of the whole expression
          if (_displayText.startsWith('-')) {
            _displayText = _displayText.substring(1); // Remove the negative sign
          } else {
            _displayText = '-' + _displayText; // Add the negative sign
          }
        }
      }
    } else {
      if (_displayText == 'Error') {
        // Reset the display text if there was an error previously
        _displayText = '';
      }
      if ('0123456789.'.contains(buttonText)) {
        // Reset display if it's currently showing an operator or '0'
        if (_expression == '0' ||
            _expression.endsWith('+') ||
            _expression.endsWith('-') ||
            _expression.endsWith('*') ||
            _expression.endsWith('/')) {
          _displayText = buttonText;
        } else {
          // Append the new digit to the display text
          _displayText += buttonText;
        }
        // Append the button's text to the expression
        if (_expression == '0' || _expression == 'Error') {
          _expression = buttonText;
        } else {
          _expression += buttonText;
        }
      } else {
        // Append the operator to the expression
        _expression += buttonText;
      }
    }
  });

  // Ensure display text reflects changes after each button press
  setState(() {
    _displayText = _displayText;
  });
}

  void _evaluateExpression() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      // Check if the result is a whole number
      if (result % 1 == 0) {
        _displayText =
            result.toInt().toString(); // Convert to integer and then to string
      } else {
        _displayText = result
            .toStringAsFixed(2); // Convert to string with 2 decimal places
      }

      _expression =
          _displayText; // Store the result in _expression for further operations
    } catch (e) {
      _displayText = 'Error';
      _expression = ''; // Clear the expression on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        double availableHeight =
            constraints.maxHeight; // Total available height
        double topPadding = 16.0; // Assuming top padding of 16.0
        double bottomPadding = 0.0; // Assuming bottom padding of 16.0
        double displayTextHeight =
            (availableHeight - topPadding - bottomPadding) * 0.11;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 8.0), // Add right padding
                  child: Text(
                    _displayText,
                    style: TextStyle(
                        fontSize: displayTextHeight,
                        color: Colors.white,
                        fontFamily: 'SFNSDisplay',
                        fontWeight: FontWeight.w200),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CalcButtons(
                          text: 'AC',
                          fontColor: Colors.black,
                          bgColor: const Color(0xFFA5A5A5),
                          onPressed: () => _onPressed('AC'),
                          fontWeight: FontWeight.w500),
                      CalcButtons(
                          text: '±',
                          fontColor: Colors.black,
                          bgColor: const Color(0xFFA5A5A5),
                          onPressed: () => _onPressed('±'),
                          fontWeight: FontWeight.w500,),
                      // Add onPressed handlers similarly for other buttons

                      CalcButtons(
                          text: "%",
                          fontColor: Colors.black,
                          bgColor: const Color(0xFFA5A5A5),
                          onPressed: () => _onPressed('%'),
                          fontWeight: FontWeight.w500,),
                      CalcButtons(
                          text: '÷',
                          bgColor: const Color(0xFFFF9F0C),
                          fontColor: const Color(0xFFFEFEFE),
                          onPressed: () => _onPressed('/'),
                          fontWeight: FontWeight.w300,)
                    ],
                  ),
                  const SizedBox(height: 16), // Adding space between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CalcButtons(
                        text: '7',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('7'),
                        fontWeight: FontWeight.w400,
                      ),
                      CalcButtons(
                        text: '8',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('8'),
                        fontWeight: FontWeight.w400,
                      ),
                      CalcButtons(
                        text: '9',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('9'),
                        fontWeight: FontWeight.w400,
                      ),
                      CalcButtons(
                        text: '×',
                        bgColor: const Color(0xFFFF9F0C),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('*'),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Adding space between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CalcButtons(
                        text: '6',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('6'),
                        fontWeight: FontWeight.w300,
                      ),
                      CalcButtons(
                        text: '5',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('5'),
                        fontWeight: FontWeight.w300,
                      ),
                      CalcButtons(
                        text: '4',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('4'),
                        fontWeight: FontWeight.w300,
                      ),
                      CalcButtons(
                        text: '-',
                        bgColor: const Color(0xFFFF9F0C),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('-'),
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Adding space between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CalcButtons(
                        text: '1',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('1'),
                        fontWeight: FontWeight.w300,
                      ),
                      CalcButtons(
                        text: '2',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('2'),
                        fontWeight: FontWeight.w300,
                      ),
                      CalcButtons(
                        text: '3',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('3'),
                        fontWeight: FontWeight.w300,
                      ),
                      CalcButtons(
                        text: '+',
                        bgColor: const Color(0xFFFF9F0C),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('+'),
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Adding space between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ZeroButton(
                        text: '0',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('0'),
                        fontWeight: FontWeight.w300,
                      ),
                      CalcButtons(
                        text: '.',
                        bgColor: const Color(0xFF333333),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('.'),
                        fontWeight: FontWeight.w400,
                      ),
                      CalcButtons(
                        text: '=',
                        bgColor: const Color(0xFFFF9F0C),
                        fontColor: const Color(0xFFFEFEFE),
                        onPressed: () => _onPressed('='),
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
