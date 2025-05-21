import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class VoiceCommandProcessor {
  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();
  bool isListening = false;
  String currentLanguage = 'en';
  DateTime? _lastPressTime;
  bool _isLongPressing = false;
  Function(String)? _onCommandCallback;

  // Command vocabulary
  final Map<String, List<String>> _commands = {
    'navigate': ['go to', 'navigate to', 'open', 'show'],
    'home': ['home', 'main', 'dashboard'],
    'chats': ['chats', 'messages', 'conversations'],
    'new chat': ['new chat', 'start chat', 'create chat'],
    'profile': ['profile', 'my account', 'account'],
    'settings': ['settings', 'preferences'],
    'logout': ['logout', 'sign out', 'exit'],
    'help': ['help', 'what can I say', 'commands'],
    'read': ['read screen', 'what\'s on screen', 'describe'],
    'magnify': ['magnify', 'zoom in', 'zoom out', 'bigger text', 'smaller text'],
    'send': ['send', 'send message'],
    'back': ['back', 'go back', 'return'],
  };

  // Initialize with a callback for command execution
  Future<void> initialize(String language, Function(String) onCommand) async {
    currentLanguage = language;
    _onCommandCallback = onCommand;
    await speech.initialize();
    await tts.setLanguage(language == 'sw' ? 'sw-TZ' : 'en-US');
    await tts.setSpeechRate(0.5);
  }

  void handlePressStart() {
    _lastPressTime = DateTime.now();
    _isLongPressing = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isLongPressing) {
        _startListening();
      }
    });
  }

  void handlePressEnd() {
    _isLongPressing = false;
    if (_lastPressTime != null &&
        DateTime.now().difference(_lastPressTime!) < const Duration(milliseconds: 1000)) {
      return;
    }
    if (isListening) {
      _stopListening();
    }
  }

  Future<void> _startListening() async {
    if (!speech.isAvailable) return;

    await Vibration.vibrate(duration: 100);
    isListening = true;
    await tts.speak(currentLanguage == 'sw' ? 'Kusikiliza...' : 'Listening...');

    await speech.listen(
      onResult: (result) => _processCommand(result.recognizedWords),
      listenFor: const Duration(minutes: 1),
      pauseFor: const Duration(seconds: 3),
      localeId: currentLanguage == 'sw' ? 'sw_TZ' : 'en_US',
      onSoundLevelChange: (level) {},
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> _stopListening() async {
    await speech.stop();
    isListening = false;
    await Vibration.vibrate(duration: 50);
  }

  void _processCommand(String command) {
    command = command.toLowerCase();
    debugPrint('Command recognized: $command');

    // Help command
    if (_commands['help']!.any((phrase) => command.contains(phrase))) {
      _showHelp();
      return;
    }

    // Navigation commands
    for (var entry in _commands.entries) {
      if (entry.key != 'navigate' &&
          _commands['navigate']!.any((navWord) => command.contains(navWord))) {
        if (entry.value.any((phrase) => command.contains(phrase))) {
          _executeCommand(entry.key);
          return;
        }
      }
    }

    // Direct commands
    for (var entry in _commands.entries) {
      if (entry.key != 'navigate' &&
          entry.value.any((phrase) => command.contains(phrase))) {
        _executeCommand(entry.key);
        return;
      }
    }

    tts.speak(currentLanguage == 'sw' ? 'Amri haijatambuliwa' : 'Command not recognized');
  }

  void _executeCommand(String command) {
    tts.speak(currentLanguage == 'sw' ? 'Inatekeleza $command' : 'Executing $command');
    if (_onCommandCallback != null) {
      _onCommandCallback!(command);
    }
  }

  void _showHelp() {
    String helpText = currentLanguage == 'sw'
        ? 'Amri zinazopatikana: Nenda kwenye: nyumbani, mazungumzo, mazungumzo mapya, wasifu, mipangilio. Amri zingine: ondoka, kuza, soma, msaada'
        : 'Available commands: Navigate to: home, chats, new chat, profile, settings. Other commands: logout, magnify, read, help';
    tts.speak(helpText);
  }

  Future<void> dispose() async {
    await speech.stop();
    await tts.stop();
  }
}