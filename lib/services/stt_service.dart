import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'language_detector.dart';

class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final LanguageDetector _languageDetector = LanguageDetector();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => print("Speech init error: $error"),
        onStatus: (status) => print("Speech status: $status"),
      );
    }
    return _isInitialized;
  }

  Future<String?> listen({String? hintText, String? preferredLanguage}) async {
    bool available = await initialize();
    if (!available) return null;

    String? recognizedText;
    String langCode = preferredLanguage == 'sw' ? 'sw_TZ' : 'en_US';

    // Detect language from hint
    if (hintText != null && hintText.trim().isNotEmpty) {
      final lang = _languageDetector.detectLang(hintText);
      langCode = (lang == 'sw') ? 'sw_TZ' : 'en_US';
    }

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            recognizedText = result.recognizedWords;
          }
        },
        localeId: langCode,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: false,
      );

      await Future.delayed(const Duration(seconds: 12));
      await _speech.stop();
    } catch (e) {
      print("STT error: $e");
    }

    return recognizedText;
  }

  void stop() => _speech.stop();
  void cancel() => _speech.cancel();
}