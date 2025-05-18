import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class CustomKeyboardScreen extends StatefulWidget {
  final Function(String) onKeyPressed;

  const CustomKeyboardScreen({Key? key, required this.onKeyPressed}) : super(key: key);

  @override
  _CustomKeyboardScreenState createState() => _CustomKeyboardScreenState();
}

class _CustomKeyboardScreenState extends State<CustomKeyboardScreen> {
  final TtsService _tts = TtsService();
  bool _uppercase = false;
  bool _shiftPressed = false;

  final List<List<String>> _keyboardLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    ['SPACE', 'DEL', 'DONE']
  ];

  final List<String> _specialKeys = ['SPACE', 'DEL', 'DONE', 'SHIFT'];

  void _handleKeyPress(String key) {
    _tts.speak(key == 'SPACE' ? 'Space' : key.toLowerCase());

    String output = key;
    if (key == 'SHIFT') {
      setState(() {
        _shiftPressed = !_shiftPressed;
        _uppercase = _shiftPressed;
      });
      return;
    } else if (key == 'SPACE') {
      output = ' ';
    } else if (key == 'DEL') {
      output = 'DELETE';
    } else if (key == 'DONE') {
      output = 'DONE';
    } else if (_uppercase) {
      output = key.toUpperCase();
      setState(() {
        _shiftPressed = false;
        _uppercase = false;
      });
    }

    widget.onKeyPressed(output);
  }

  Widget _buildKey(String key) {
    final bool isSpecialKey = _specialKeys.contains(key);
    final bool isShift = key == 'SHIFT';
    final bool isActiveShift = isShift && _shiftPressed;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: isSpecialKey
            ? Colors.blueGrey[800]
            : isActiveShift
            ? Colors.lightBlueAccent
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _handleKeyPress(key),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              _uppercase && !isSpecialKey ? key.toUpperCase() : key,
              style: TextStyle(
                fontSize: isSpecialKey ? 18 : 22,
                fontWeight: isSpecialKey ? FontWeight.bold : FontWeight.normal,
                color: isSpecialKey ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First row - numbers
          Row(
            children: _keyboardLayout[0].map((key) => Expanded(child: _buildKey(key))).toList(),
          ),
          // Second row - QWERTY...
          Row(
            children: _keyboardLayout[1].map((key) => Expanded(child: _buildKey(key))).toList(),
          ),
          // Third row - ASDF...
          Row(
            children: [
              ..._keyboardLayout[2].map((key) => Expanded(child: _buildKey(key))),
              Expanded(child: _buildKey('SHIFT')),
            ],
          ),
          // Fourth row - ZXCV...
          Row(
            children: [
              Spacer(flex: 1),
              ..._keyboardLayout[3].map((key) => Expanded(
                child: _buildKey(key),
                flex: 2, // This flex is now on the Expanded widget, not _buildKey
              )),
              Spacer(flex: 1),
            ],
          ),
          // Bottom row - Space, Delete, Done
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildKey(_keyboardLayout[4][0]),
              ),
              Expanded(
                flex: 2,
                child: _buildKey(_keyboardLayout[4][1]),
              ),
              Expanded(
                flex: 3,
                child: _buildKey(_keyboardLayout[4][2]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}