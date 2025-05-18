import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../screens/chat_screen.dart';
import '../services/tts_service.dart';

class NewChatScreen extends StatefulWidget {
  final String currentUserPhone;

  const NewChatScreen({Key? key, required this.currentUserPhone})
      : super(key: key);

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final ChatService _chatService = ChatService(
      baseUrl: 'http://192.168.1.188/TALKTEXT');
  final TtsService _tts = TtsService();
  late Future<List<User>> _userFuture;
  bool _isMagnified = false;
  DateTime? _lastTap;
  String _currentLanguage = 'en';

  // Consistent color scheme with HomeScreen
  final Color _primaryColor = Colors.lightBlue.shade400;
  final Color _secondaryColor = Colors.lightBlue.shade200;
  final Color _accentColor = Colors.blueAccent;
  final Color _textColor = Colors.blueGrey.shade800;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference().then((_) {
      _userFuture = _loadAndAnnounceUsers();
    });
  }

  Future<void> _loadLanguagePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
    await _tts.setLanguage(_currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
  }

  String _translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'newChat': {'en': 'Start New Chat', 'sw': 'Anzisha Mazungumzo Mapya'},
      'loading': {'en': 'Loading...', 'sw': 'Inapakia...'},
      'errorLoading': {'en': 'Error loading users', 'sw': 'Hitilafu ya kupakia watumiaji'},
      'noUsers': {'en': 'No users available', 'sw': 'Hakuna watumiaji'},
      'allUsersWillAppear': {
        'en': 'All registered users will appear here',
        'sw': 'Watumiaji wote waliosajiliwa wataonekana hapa'
      },
      'usersAvailable': {
        'en': 'Users available to chat:',
        'sw': 'Watumiaji wanaoweza kuzungumza:'
      },
      'noUsersAvailable': {
        'en': 'No users available to chat at the moment',
        'sw': 'Hakuna watumiaji wa kuzungumza kwa sasa'
      },
      'openingChat': {'en': 'Opening chat with', 'sw': 'Inafungua mazungumzo na'},
      'phone': {'en': 'Phone', 'sw': 'Simu'},
      'doubleTapToOpen': {
        'en': 'Double tap to open chat',
        'sw': 'Gonga mara mbili kufungua mazungumzo'
      },
      'magnifiedView': {'en': 'Magnified view', 'sw': 'Mtazamo mkubwa'},
      'normalView': {'en': 'Normal view', 'sw': 'Mtazamo wa kawaida'},
    };

    return translations[key]?[_currentLanguage] ?? key;
  }

  Future<List<User>> _loadAndAnnounceUsers() async {
    List<User> users = await _chatService.fetchUsers(widget.currentUserPhone);
    if (users.isNotEmpty) {
      String names = users.map((u) => u.username).join(', ');
      await _tts.speak("${_translate('usersAvailable')} $names");
    } else {
      await _tts.speak(_translate('noUsersAvailable'));
    }
    return users;
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
        _tts.speak(_translate(_isMagnified ? 'magnifiedView' : 'normalView'));
      },
      tooltip: _translate(_isMagnified ? 'normalView' : 'magnifiedView'),
    );
  }

  TextStyle _getTextStyle(bool isTitle) {
    return GoogleFonts.poppins(
      fontSize: _isMagnified
          ? (isTitle ? 22 : 18)
          : (isTitle ? 18 : 14),
      fontWeight: isTitle ? FontWeight.w600 : FontWeight.normal,
      color: _textColor,
    );
  }

  Future<void> _handleTap(User user) async {
    final now = DateTime.now();
    final isDoubleTap = _lastTap != null &&
        now.difference(_lastTap!) < const Duration(milliseconds: 300);

    if (isDoubleTap) {
      await _tts.speak("${_translate('openingChat')} ${user.username}");
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUserPhone: widget.currentUserPhone,
              otherUser: user,
            ),
          ),
        );
      }
    } else {
      // Single tap - announce contact name
      await _tts.speak(
          "${user.username}, ${_translate('phone')}: ${user.phone}. ${_translate('doubleTapToOpen')}");
    }
    _lastTap = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('newChat'),
          style: GoogleFonts.poppins(
            fontSize: _isMagnified ? 22 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        actions: [_buildMagnifierButton()],
      ),
      body: Container(
        color: _secondaryColor.withOpacity(0.1),
        child: FutureBuilder<List<User>>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _translate('loading'),
                      style: _getTextStyle(false),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _translate('errorLoading'),
                    style: _getTextStyle(true),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final users = snapshot.data!;
            if (users.isEmpty) {
              return GestureDetector(
                onTap: () => _tts.speak(_translate('noUsers')),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_rounded,
                        size: _isMagnified ? 80 : 60,
                        color: _primaryColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _translate('noUsers'),
                        style: _getTextStyle(true),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _translate('allUsersWillAppear'),
                        style: _getTextStyle(false),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(_isMagnified ? 16 : 12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () => _handleTap(user),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(
                      vertical: _isMagnified ? 10 : 8,
                      horizontal: _isMagnified ? 8 : 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: _isMagnified ? 16 : 12,
                        horizontal: _isMagnified ? 20 : 16,
                      ),
                      leading: CircleAvatar(
                        radius: _isMagnified ? 28 : 24,
                        backgroundColor: _primaryColor,
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: _isMagnified ? 20 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        user.username,
                        style: _getTextStyle(true),
                      ),
                      subtitle: Text(
                        user.phone,
                        style: _getTextStyle(false).copyWith(
                          color: _textColor.withOpacity(0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chat_rounded,
                        color: _primaryColor,
                        size: _isMagnified ? 32 : 28,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}