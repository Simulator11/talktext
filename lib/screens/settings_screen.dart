import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final Function() onSettingsChanged;
  final bool isMagnified;

  const SettingsScreen({
    Key? key,
    required this.onSettingsChanged,
    required this.isMagnified,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  late bool _darkMode;
  late bool _soundEffects;

  // Light blue color scheme
  final Color _primaryColor = Colors.lightBlue.shade400;
  final Color _secondaryColor = Colors.lightBlue.shade200;
  final Color _accentColor = Colors.blueAccent;
  final Color _cardColor = Colors.white;
  final Color _textColor = Colors.blueGrey.shade800;
  final Color _backgroundColor = Colors.lightBlue.shade50; // Very light blue background

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      _darkMode = prefs.getBool('darkMode') ?? false;
      _soundEffects = prefs.getBool('soundEffects') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('soundEffects', _soundEffects);
    widget.onSettingsChanged();
  }

  String _translate(String key) {
    final translations = {
      'settings': {'en': 'Settings', 'sw': 'Mipangilio'},
      'languageSettings': {'en': 'Language Settings', 'sw': 'Mipangilio ya Lugha'},
      'appearance': {'en': 'Appearance', 'sw': 'Muonekano'},
      'sound': {'en': 'Sound', 'sw': 'Sauti'},
      'appLanguage': {'en': 'App Language', 'sw': 'Lugha ya Programu'},
      'english': {'en': 'English', 'sw': 'Kiingereza'},
      'swahili': {'en': 'Swahili', 'sw': 'Kiswahili'},
      'darkMode': {'en': 'Dark Mode', 'sw': 'Hali ya Giza'},
      'soundEffects': {'en': 'Sound Effects', 'sw': 'Athari za Sauti'},
      'saveSettings': {'en': 'Save Settings', 'sw': 'Hifadhi Mipangilio'},
    };

    return translations[key]?[_selectedLanguage] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Light blue background
      appBar: AppBar(
        title: Text(
          _translate('settings'),
          style: GoogleFonts.poppins(
            fontSize: widget.isMagnified ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSectionHeader(_translate('languageSettings')),
              _buildLanguageSetting(),
              const SizedBox(height: 16),
              _buildSectionHeader(_translate('appearance')),
              _buildDarkModeSetting(),
              const SizedBox(height: 16),
              _buildSectionHeader(_translate('sound')),
              _buildSoundEffectsSetting(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: widget.isMagnified ? 20 : 16,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _translate('appLanguage'),
              style: GoogleFonts.poppins(
                fontSize: widget.isMagnified ? 18 : 14,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text(
                    _translate('english'),
                    style: GoogleFonts.poppins(
                      fontSize: widget.isMagnified ? 16 : 14,
                      color: _textColor,
                    ),
                  ),
                  value: 'en',
                  groupValue: _selectedLanguage,
                  activeColor: _primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    _translate('swahili'),
                    style: GoogleFonts.poppins(
                      fontSize: widget.isMagnified ? 16 : 14,
                      color: _textColor,
                    ),
                  ),
                  value: 'sw',
                  groupValue: _selectedLanguage,
                  activeColor: _primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeSetting() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          _translate('darkMode'),
          style: GoogleFonts.poppins(
            fontSize: widget.isMagnified ? 18 : 14,
            fontWeight: FontWeight.w500,
            color: _textColor,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        value: _darkMode,
        activeColor: _primaryColor,
        activeTrackColor: _secondaryColor,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
        onChanged: (value) {
          setState(() {
            _darkMode = value;
          });
        },
      ),
    );
  }

  Widget _buildSoundEffectsSetting() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          _translate('soundEffects'),
          style: GoogleFonts.poppins(
            fontSize: widget.isMagnified ? 18 : 14,
            fontWeight: FontWeight.w500,
            color: _textColor,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        value: _soundEffects,
        activeColor: _primaryColor,
        activeTrackColor: _secondaryColor,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
        onChanged: (value) {
          setState(() {
            _soundEffects = value;
          });
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await _saveSettings();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: widget.isMagnified ? 18 : 14,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: _primaryColor.withOpacity(0.3),
        ),
        child: Text(
          _translate('saveSettings'),
          style: GoogleFonts.poppins(
            fontSize: widget.isMagnified ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}