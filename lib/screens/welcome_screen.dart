import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isMagnified = false;
  String _currentLanguage = 'en';
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _speakWelcomeMessage();
  }

  Future<void> _loadLanguagePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  String _translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'welcome': {'en': 'Welcome to TalkText', 'sw': 'Karibu kwenye TalkText'},
      'projectBy': {
        'en': 'A final year project by Japhet Onesmo Samwel',
        'sw': 'Mradi wa mwisho wa Japhet Onesmo Samwel'
      },
      'supervisedBy': {
        'en': 'Under the supervision of Mr. Jovine Camara',
        'sw': 'Chini ya usimamizi wa Bw. Jovine Camara'
      },
      'classOf': {'en': 'Class of 2025', 'sw': 'Daraja la 2025'},
      'getStarted': {'en': 'Get Started', 'sw': 'Anza'},
      'magnifiedView': {'en': 'Magnified view', 'sw': 'Mtazamo mkubwa'},
      'normalView': {'en': 'Normal view', 'sw': 'Mtazamo wa kawaida'},
      'welcomeMessage': {
        'en': 'Welcome to TalkText, a final year project for Japhet Onesmo Samwel, under the supervision of Mr. Jovine Camara, class of 2025.',
        'sw': 'Karibu kwenye TalkText, mradi wa mwisho wa Japhet Onesmo Samwel, chini ya usimamizi wa Bw. Jovine Camara, daraja la 2025.'
      },
    };

    return translations[key]?[_currentLanguage] ?? key;
  }

  Future<void> _speakWelcomeMessage() async {
    if (_isSpeaking) return;

    setState(() => _isSpeaking = true);
    await flutterTts.setLanguage(_currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(_translate('welcomeMessage'));
    setState(() => _isSpeaking = false);
  }

  Widget _buildMagnifierButton() {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          _isMagnified ? Icons.zoom_out_map : Icons.zoom_in,
          key: ValueKey<bool>(_isMagnified),
          color: Colors.white,
          size: _isMagnified ? 30 : 24,
        ),
      ),
      onPressed: () {
        setState(() => _isMagnified = !_isMagnified);
        flutterTts.setLanguage(_currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
        flutterTts.speak(_translate(_isMagnified ? 'magnifiedView' : 'normalView'));
      },
      tooltip: _translate(_isMagnified ? 'normalView' : 'magnifiedView'),
    );
  }

  TextStyle _getTextStyle(bool isTitle) {
    return GoogleFonts.poppins(
      fontSize: _isMagnified
          ? (isTitle ? 40 : 24)
          : (isTitle ? 32 : 18),
      fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
      color: Colors.white,
      height: 1.3,
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blueAccent,
                  Colors.lightBlueAccent,
                  Colors.lightBlue,
                ],
                stops: [0.1, 0.5, 0.9],
              ),
            ),
          ),

          // Floating bubbles decoration
          Positioned(
            top: 100,
            left: 30,
            child: _buildBubble(60),
          ),
          Positioned(
            bottom: 200,
            right: 40,
            child: _buildBubble(40),
          ),
          Positioned(
            top: 300,
            right: 80,
            child: _buildBubble(30),
          ),

          // App bar with magnifier button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: _buildMagnifierButton(),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo/icon with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_isMagnified ? 25 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: _isMagnified ? 40 : 30),

                  // App title with text shadow
                  Text(
                    _translate('welcome'),
                    textAlign: TextAlign.center,
                    style: _getTextStyle(true).copyWith(
                      shadows: const [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _isMagnified ? 30 : 20),

                  // Project description with glass morphism effect
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _translate('projectBy'),
                          textAlign: TextAlign.center,
                          style: _getTextStyle(false),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _translate('supervisedBy'),
                          textAlign: TextAlign.center,
                          style: _getTextStyle(false),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _translate('classOf'),
                          textAlign: TextAlign.center,
                          style: _getTextStyle(false),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _isMagnified ? 50 : 40),

                  // Get started button with pulse animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(
                          horizontal: _isMagnified ? 60 : 40,
                          vertical: _isMagnified ? 20 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      onPressed: () {
                        flutterTts.stop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        _translate('getStarted'),
                        style: _getTextStyle(false).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(double size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isMagnified ? size * 1.2 : size,
      height: _isMagnified ? size * 1.2 : size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    );
  }
}