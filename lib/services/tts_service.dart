import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  Future<void> setLanguage(String langCode) async {
    // Use the full locale code for better TTS support
    String ttsLangCode = langCode == 'sw' ? 'sw-TZ' : 'en-US';
    await _flutterTts.setLanguage(ttsLangCode);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    return await _flutterTts.getLanguages;
  }
}