import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';
import 'package:talktext/services/voice_command_processor.dart';
import 'package:talktext/screens/welcome_screen.dart';

class HomeController {
  // State variables
  int currentIndex = 0;
  bool isMagnified = false;
  String currentLanguage = 'en';
  bool isListening = false;
  final PageController pageController = PageController();
  DateTime? lastTap;

  // Services
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  late VoiceCommandProcessor voiceProcessor;

  // User data
  final String username;
  final String phone;

  // Colors
  final Color primaryColor = Colors.lightBlue.shade400;
  final Color secondaryColor = Colors.lightBlue.shade200;
  final Color accentColor = Colors.blueAccent;
  final Color textColor = Colors.blueGrey.shade800;

  HomeController({required this.username, required this.phone}) {
    voiceProcessor = VoiceCommandProcessor();
  }

  Future<void> initialize() async {
    await flutterTts.setLanguage(currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await speech.initialize();
    await voiceProcessor.initialize(currentLanguage, handleVoiceCommand);
    await Vibration.hasVibrator();
  }

  Future<void> loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage = prefs.getString('language') ?? 'en';
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  Future<void> speakWelcomeMessage() async {
    String welcomeMessage = translateWithUsername('welcomeMessage');
    String doubleTapInstruction = translate('doubleTapInstruction');
    String swipeInstruction = translate('swipeInstruction');
    String commandsHelp = translate('commandsHelp');
    String longPressInstruction = translate('longPressInstruction');

    await speak('''
      $welcomeMessage. 
      $doubleTapInstruction. 
      $swipeInstruction. 
      $longPressInstruction.
      $commandsHelp
    ''');
  }

  Future<void> toggleListening() async {
    if (!speech.isAvailable) {
      await speak(translate('speechNotAvailable'));
      return;
    }

    if (isListening) {
      await speech.stop();
      isListening = false;
      await speak(translate('micOff'));
    } else {
      await speak(translate('listening'));
      isListening = true;
      await speech.listen(
        onResult: (result) => handleCommand(result.recognizedWords),
        listenFor: Duration(minutes: 1),
        pauseFor: Duration(seconds: 3),
        localeId: currentLanguage == 'sw' ? 'sw_TZ' : 'en_US',
      );
    }
  }

  void handleCommand(String command) {
    command = command.toLowerCase();
    debugPrint('Command recognized: $command');

    // Help command
    if (command.contains('help') || command.contains('msaada')) {
      speak(translate('commandsHelp'));
      return;
    }

    // Read screen command
    if (command.contains('read') || command.contains('soma')) {
      readScreenContent();
      return;
    }

    // Magnify command
    if (command.contains('magnify') || command.contains('zoom') ||
        command.contains('kuza') || command.contains('kubwa')) {
      toggleMagnify();
      return;
    }

    // Navigation commands
    if (command.contains('home') || command.contains('nyumbani')) {
      navigateToPage(0);
    } else if (command.contains('chat') || command.contains('mazungumzo')) {
      if (command.contains('new') || command.contains('mpya')) {
        navigateToPage(2);
      } else {
        navigateToPage(1);
      }
    } else if (command.contains('profile') || command.contains('wasifu')) {
      navigateToPage(3);
    } else if (command.contains('settings') || command.contains('mipangilio')) {
      openSettings();
    } else if (command.contains('logout') || command.contains('ondoka')) {
      logout();
    } else {
      speak(translate('commandNotRecognized'));
    }
  }

  void handleVoiceCommand(String command) {
    switch (command) {
      case 'home':
        navigateToPage(0);
        break;
      case 'chats':
        navigateToPage(1);
        break;
      case 'new chat':
        navigateToPage(2);
        break;
      case 'profile':
        navigateToPage(3);
        break;
      case 'settings':
        openSettings();
        break;
      case 'logout':
        logout();
        break;
      case 'magnify':
        toggleMagnify();
        break;
      case 'read':
        readScreenContent();
        break;
      default:
        speak(translate('commandNotRecognized'));
    }
  }

  void navigateToPage(int index) {
    currentIndex = index;
    pageController.jumpToPage(index);
    speak(getNavItemName(index));
  }

  String getNavItemName(int index) {
    switch (index) {
      case 0: return translate('home');
      case 1: return translate('chats');
      case 2: return translate('newChat');
      case 3: return translate('profile');
      default: return "";
    }
  }

  void openSettings() {
    // Note: Navigation is handled in the UI layer
  }

  void readScreenContent() {
    String content = '${translate('home')} screen. ';
    content += '${translate('currentlyOn')} ${getNavItemName(currentIndex)}. ';
    content += translate('swipeInstruction');
    speak(content);
  }

  void toggleMagnify() {
    isMagnified = !isMagnified;
    speak(isMagnified ? translate('magnifiedView') : translate('normalView'));
  }

  void handleDoubleTap(BuildContext context, String description, [GestureTapCallback? action]) {
    final now = DateTime.now();
    if (lastTap != null && now.difference(lastTap!) < Duration(milliseconds: 300)) {
      lastTap = null;
      if (action != null) action();
    } else {
      lastTap = now;
      speak(description);
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Note: Navigation is handled in the UI layer
  }

  String translate(String key) {
    final translations = {
      'welcome': {'en': 'Welcome', 'sw': 'Karibu'},
      'home': {'en': 'Home', 'sw': 'Nyumbani'},
      'chats': {'en': 'Chats', 'sw': 'Mazungumzo'},
      'newChat': {'en': 'New Chat', 'sw': 'Mazungumzo Mapya'},
      'profile': {'en': 'Profile', 'sw': 'Wasifu'},
      'settings': {'en': 'Settings', 'sw': 'Mipangilio'},
      'logout': {'en': 'Logout', 'sw': 'Ondoka'},
      'editProfile': {'en': 'Edit Profile', 'sw': 'Hariri Wasifu'},
      'talkText': {'en': 'TalkText', 'sw': 'TalkText'},
      'magnifiedView': {'en': 'Magnified view', 'sw': 'Mtazamo mkubwa'},
      'normalView': {'en': 'Normal view', 'sw': 'Mtazamo wa kawaida'},
      'welcomeMessage': {
        'en': 'Welcome to TalkText, @username@',
        'sw': 'Karibu kwenye TalkText, @username@'
      },
      'doubleTapInstruction': {
        'en': 'Double tap any item to select it',
        'sw': 'Gonga mara mbili kuchagua kitu'
      },
      'swipeInstruction': {
        'en': 'Swipe left or right to navigate between tabs',
        'sw': 'Sogeza kushoto au kulia kwa kuvinjari kwenye tabo'
      },
      'longPressInstruction': {
        'en': 'Long press anywhere to activate voice commands',
        'sw': 'Shika kwa muda kwa kutumia amri za sauti'
      },
      'speechNotAvailable': {
        'en': 'Speech recognition not available',
        'sw': 'Utambuzi wa sauti haupatikani'
      },
      'listening': {
        'en': 'Listening... Say your command',
        'sw': 'Kusikiliza... Sema amri yako'
      },
      'micOff': {'en': 'Microphone off', 'sw': 'Kizushi cha sauti kimezimwa'},
      'commandsHelp': {
        'en': 'Available commands: Navigate to: home, chats, new chat, profile, settings. Other commands: logout, magnify, read, help',
        'sw': 'Amri zinazopatikana: Nenda kwenye: nyumbani, mazungumzo, mazungumzo mapya, wasifu, mipangilio. Amri zingine: ondoka, kuza, soma, msaada'
      },
      'commandNotRecognized': {
        'en': 'Command not recognized',
        'sw': 'Amri haijatambuliwa'
      },
      'currentlyOn': {'en': 'Currently on', 'sw': 'Kwa sasa kwenye'},
      'phone': {'en': 'Phone', 'sw': 'Simu'},
      'recentChats': {'en': 'Recent chats', 'sw': 'Mazungumzo ya hivi karibuni'},
      'noRecentChats': {
        'en': 'No recent chats',
        'sw': 'Hakuna mazungumzo ya hivi karibuni'
      },
      'yourChatsWillAppearHere': {
        'en': 'Your chats will appear here',
        'sw': 'Mazungumzo yataonekana hapa'
      },
    };

    return translations[key]?[currentLanguage] ?? key;
  }

  String translateWithUsername(String key) {
    return translate(key).replaceAll('@username@', username);
  }

  void dispose() {
    speech.stop();
    flutterTts.stop();
    pageController.dispose();
    voiceProcessor.dispose();
  }
}