import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome',
      'home': 'Home',
      'chats': 'Chats',
      'newChat': 'New Chat',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'editProfile': 'Edit Profile',
      'talkText': 'TalkText',
      'magnifiedView': 'Magnified view',
      'normalView': 'Normal view',
      'welcomeMessage': 'Welcome to TalkText, @username@',
      'doubleTapInstruction': 'Double tap any item to select it',
      'swipeInstruction': 'Swipe right for menu or use bottom navigation',
      'chatWith': 'Chat with @username@',
      'youAreTalkingWith': 'You are talking with @username@',
      'messageSent': 'Message sent',
      'writeOrSpeak': 'Write or speak a message',
      'youSaid': 'You said',
      'said': 'said',
      'speechNotAvailable': 'Speech recognition not available',
    },
    'sw': {
      'welcome': 'Karibu',
      'home': 'Nyumbani',
      'chats': 'Mazungumzo',
      'newChat': 'Mazungumzo Mapya',
      'profile': 'Wasifu',
      'settings': 'Mipangilio',
      'logout': 'Ondoka',
      'editProfile': 'Hariri Wasifu',
      'talkText': 'TalkText',
      'magnifiedView': 'Mtazamo mkubwa',
      'normalView': 'Mtazamo wa kawaida',
      'welcomeMessage': 'Karibu kwenye TalkText, @username@',
      'doubleTapInstruction': 'Gonga mara mbili kuchagua kitu',
      'swipeInstruction': 'Sogeza kulia kwa menyu au tumia navigesheni ya chini',
      'chatWith': 'Mazungumzo na @username@',
      'youAreTalkingWith': 'Unaongea na @username@',
      'messageSent': 'Ujumbe umetumwa',
      'writeOrSpeak': 'Andika au sema ujumbe',
      'youSaid': 'Ulisema',
      'said': 'alisema',
      'speechNotAvailable': 'Utambuzi wa sauti haupatikani',
    },
  };

  String translate(String key, {String? username}) {
    String value = _localizedValues[locale.languageCode]?[key] ?? key;
    if (username != null) {
      value = value.replaceAll('@username@', username);
    }
    return value;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}