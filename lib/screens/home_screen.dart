import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../screens/welcome_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/new_chat_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String phone;

  const HomeScreen({Key? key, required this.username, required this.phone})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  late FlutterTts flutterTts;
  final stt.SpeechToText _speech = stt.SpeechToText();
  DateTime? _lastTap;
  bool _isMagnified = false;
  String _currentLanguage = 'en';

  // Colors
  final Color _primaryColor = Colors.lightBlue.shade400;
  final Color _secondaryColor = Colors.lightBlue.shade200;
  final Color _accentColor = Colors.blueAccent;
  final Color _textColor = Colors.blueGrey.shade800;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initializeTts();
    _initializeSpeech();
    _loadLanguagePreference();

    _pages = [
      _buildHomeContent(),
      _buildChatsPlaceholder(),
      NewChatScreen(currentUserPhone: widget.phone),
      ProfileScreen(
        username: widget.username,
        phone: widget.phone,
        userId: '',
      ),
    ];

    _speakWelcomeMessage();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage(_currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }

  String _translate(String key) {
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
        'en': 'Swipe right for menu or use bottom navigation',
        'sw': 'Sogeza kulia kwa menyu au tumia navigesheni ya chini'
      },
      'chatWith': {'en': 'Chat with @username@', 'sw': 'Mazungumzo na @username@'},
      'youAreTalkingWith': {
        'en': 'You are talking with @username@',
        'sw': 'Unaongea na @username@'
      },
      'messageSent': {'en': 'Message sent', 'sw': 'Ujumbe umetumwa'},
      'writeOrSpeak': {
        'en': 'Write or speak a message',
        'sw': 'Andika au sema ujumbe'
      },
      'youSaid': {'en': 'You said', 'sw': 'Ulisema'},
      'said': {'en': 'said', 'sw': 'alisema'},
      'speechNotAvailable': {
        'en': 'Speech recognition not available',
        'sw': 'Utambuzi wa sauti haupatikani'
      },
      'noRecentChats': {'en': 'No recent chats', 'sw': 'Hakuna mazungumzo ya hivi karibuni'},
      'yourChatsWillAppearHere': {
        'en': 'Your chats will appear here',
        'sw': 'Mazungumzo yataonekana hapa'
      },
    };

    return translations[key]?[_currentLanguage] ?? key;
  }

  String _translateWithUsername(String key) {
    return _translate(key).replaceAll('@username@', widget.username);
  }

  Future<void> _speakWelcomeMessage() async {
    String welcomeMessage = _translateWithUsername('welcomeMessage');
    String doubleTapInstruction = _translate('doubleTapInstruction');
    String swipeInstruction = _translate('swipeInstruction');

    await flutterTts.speak('$welcomeMessage. $doubleTapInstruction. $swipeInstruction');
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _handleDoubleTap(BuildContext context, String description, [GestureTapCallback? action]) {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < Duration(milliseconds: 300)) {
      _lastTap = null;
      if (action != null) action();
    } else {
      _lastTap = now;
      _speak(description);
    }
  }

  void _handleSettingsChanged() async {
    await _loadLanguagePreference();
    await _initializeTts();
    _speakWelcomeMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('talkText'),
          style: GoogleFonts.poppins(
            fontSize: _isMagnified ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        actions: [_buildMagnifierButton()],
      ),
      drawer: _buildAccessibleDrawer(context),
      body: GestureDetector(
        onTap: () => _speak(_translate('home')),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  Widget _buildMagnifierButton() {
    return IconButton(
      icon: Icon(
        _isMagnified ? Icons.zoom_out_map : Icons.zoom_in,
        color: Colors.white,
        size: _isMagnified ? 28 : 24,
      ),
      onPressed: () {
        setState(() => _isMagnified = !_isMagnified);
        _speak(_isMagnified ? _translate('magnifiedView') : _translate('normalView'));
      },
      tooltip: 'Toggle text size',
    );
  }

  Widget _buildAccessibleDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: _primaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: _accentColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _handleDoubleTap(context, _translate('profile')),
                    child: CircleAvatar(
                      radius: _isMagnified ? 40 : 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.account_circle_rounded,
                        size: _isMagnified ? 50 : 40,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _handleDoubleTap(context, _translate('welcome')),
                    child: Text(
                      _translate('welcome'),
                      style: GoogleFonts.poppins(
                        fontSize: _isMagnified ? 24 : 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: _secondaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _handleDoubleTap(context, "${_translate('profile')} ${widget.username}"),
                    child: Text(
                      widget.username,
                      style: GoogleFonts.poppins(
                        fontSize: _isMagnified ? 20 : 16,
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => _handleDoubleTap(context, "Phone number ${widget.phone}"),
                    child: Text(
                      widget.phone,
                      style: GoogleFonts.poppins(
                        fontSize: _isMagnified ? 18 : 14,
                        color: _textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.home_rounded,
              text: _translate('home'),
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.forum_rounded,
              text: _translate('chats'),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.add_comment_rounded,
              text: _translate('newChat'),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.edit_rounded,
              text: _translate('editProfile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings_rounded,
              text: _translate('settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      onSettingsChanged: _handleSettingsChanged,
                      isMagnified: _isMagnified,
                    ),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.logout_rounded,
              text: _translate('logout'),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _textColor),
      title: Text(text,
        style: GoogleFonts.poppins(
          fontSize: _isMagnified ? 18 : 14,
          color: _textColor,
        ),
      ),
      onTap: () {
        _speak("Opening $text");
        onTap();
      },
      tileColor: Colors.white.withOpacity(0.8),
    );
  }

  Widget _buildModernBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        _speak(_getNavItemName(index));
      },
      backgroundColor: _primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.7),
      selectedFontSize: _isMagnified ? 14 : 12,
      unselectedFontSize: _isMagnified ? 12 : 10,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      unselectedLabelStyle: GoogleFonts.poppins(),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          activeIcon: Icon(Icons.home_filled),
          label: _translate('home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum_rounded),
          activeIcon: Icon(Icons.forum),
          label: _translate('chats'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_comment_rounded),
          activeIcon: Icon(Icons.add_comment),
          label: _translate('newChat'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          activeIcon: Icon(Icons.person),
          label: _translate('profile'),
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _speakWelcomeMessage,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(_isMagnified ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _handleDoubleTap(
                    context,
                    _translateWithUsername('welcomeMessage')
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(_isMagnified ? 20 : 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle_rounded,
                          size: _isMagnified ? 60 : 50,
                          color: _primaryColor,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _translateWithUsername('welcomeMessage'),
                                style: GoogleFonts.poppins(
                                  fontSize: _isMagnified ? 20 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${_translate('phone')}: ${widget.phone}',
                                style: GoogleFonts.poppins(
                                  fontSize: _isMagnified ? 16 : 14,
                                  color: _textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: _isMagnified ? 30 : 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _translate('recentChats'),
                  style: GoogleFonts.poppins(
                    fontSize: _isMagnified ? 20 : 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
              SizedBox(height: _isMagnified ? 20 : 12),
              _buildRecentChatsPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_rounded,
            size: _isMagnified ? 80 : 60,
            color: _primaryColor.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            _translate('yourChatsWillAppearHere'),
            style: GoogleFonts.poppins(
              fontSize: _isMagnified ? 18 : 14,
              color: _textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChatsPlaceholder() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: _isMagnified ? 80 : 60,
            color: _primaryColor.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            _translate('noRecentChats'),
            style: GoogleFonts.poppins(
              fontSize: _isMagnified ? 18 : 14,
              color: _textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _getNavItemName(int index) {
    switch (index) {
      case 0: return _translate('home');
      case 1: return _translate('chats');
      case 2: return _translate('newChat');
      case 3: return _translate('profile');
      default: return "";
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}