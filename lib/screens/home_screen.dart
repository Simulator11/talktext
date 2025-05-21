import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talktext/screens/navigation_components.dart';
import 'package:talktext/screens/welcome_screen.dart';
import 'package:talktext/screens/edit_profile_screen.dart';
import 'package:talktext/screens/profile_screen.dart';
import 'package:talktext/screens/new_chat_screen.dart';
import 'package:talktext/screens/settings_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String phone;

  const HomeScreen({Key? key, required this.username, required this.phone})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(username: widget.username, phone: widget.phone);
    _controller.initialize();
    _controller.loadLanguagePreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.speakWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _controller.voiceProcessor.handlePressStart(),
      onLongPressEnd: (_) => _controller.voiceProcessor.handlePressEnd(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _controller.translate('talkText'),
            style: GoogleFonts.poppins(
              fontSize: _controller.isMagnified ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: _controller.primaryColor,
          actions: [
            IconButton(
              icon: Icon(
                _controller.isMagnified ? Icons.zoom_out_map : Icons.zoom_in,
                color: Colors.white,
                size: _controller.isMagnified ? 28 : 24,
              ),
              onPressed: () {
                setState(() => _controller.isMagnified = !_controller.isMagnified);
                _controller.speak(_controller.isMagnified
                    ? _controller.translate('magnifiedView')
                    : _controller.translate('normalView'));
              },
              tooltip: 'Toggle text size',
            ),
            IconButton(
              icon: Icon(_controller.isListening ? Icons.mic_off : Icons.mic),
              onPressed: _controller.toggleListening,
              tooltip: _controller.isListening
                  ? _controller.translate('stopListening')
                  : _controller.translate('startListening'),
            ),
          ],
        ),
        drawer: NavigationComponents.buildAccessibleDrawer(
          context: context,
          username: widget.username,
          phone: widget.phone,
          isMagnified: _controller.isMagnified,
          primaryColor: _controller.primaryColor,
          secondaryColor: _controller.secondaryColor,
          accentColor: _controller.accentColor,
          textColor: _controller.textColor,
          translate: _controller.translate,
          translateWithUsername: _controller.translateWithUsername,
          handleDoubleTap: _controller.handleDoubleTap,
          onNavItemSelected: (index) {
            setState(() => _controller.currentIndex = index);
            _controller.pageController.jumpToPage(index);
          },
          logout: (context) => _controller.logout().then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          }),
        ),
        body: PageView(
          controller: _controller.pageController,
          onPageChanged: (index) {
            setState(() => _controller.currentIndex = index);
            _controller.speak(_controller.getNavItemName(index));
          },
          children: [
            _buildHomeContent(),
            _buildChatsPlaceholder(),
            NewChatScreen(currentUserPhone: widget.phone),
            ProfileScreen(
              username: widget.username,
              phone: widget.phone,
              userId: '',
            ),
          ],
        ),
        bottomNavigationBar: NavigationComponents.buildModernBottomNavBar(
          context: context,
          currentIndex: _controller.currentIndex,
          onTap: (index) => setState(() => _controller.currentIndex = index),
          translate: _controller.translate,
          isMagnified: _controller.isMagnified,
          primaryColor: _controller.primaryColor,
          textColor: _controller.textColor,
          pageController: _controller.pageController,
          speak: _controller.speak,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _controller.toggleListening,
          backgroundColor: _controller.primaryColor,
          child: Icon(
            _controller.isListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
          ),
          tooltip: _controller.isListening
              ? _controller.translate('stopListening')
              : _controller.translate('startListening'),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _controller.speakWelcomeMessage,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(_controller.isMagnified ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _controller.handleDoubleTap(
                  context,
                  _controller.translateWithUsername('welcomeMessage'),
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(_controller.isMagnified ? 20 : 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle_rounded,
                          size: _controller.isMagnified ? 60 : 50,
                          color: _controller.primaryColor,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _controller.translateWithUsername('welcomeMessage'),
                                style: GoogleFonts.poppins(
                                  fontSize: _controller.isMagnified ? 20 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: _controller.textColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${_controller.translate('phone')}: ${widget.phone}',
                                style: GoogleFonts.poppins(
                                  fontSize: _controller.isMagnified ? 16 : 14,
                                  color: Color.alphaBlend(
                                    _controller.textColor.withOpacity(0.7),
                                    Colors.white,
                                  ),
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
              SizedBox(height: _controller.isMagnified ? 30 : 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _controller.translate('recentChats'),
                  style: GoogleFonts.poppins(
                    fontSize: _controller.isMagnified ? 20 : 16,
                    fontWeight: FontWeight.w600,
                    color: _controller.textColor,
                  ),
                ),
              ),
              SizedBox(height: _controller.isMagnified ? 20 : 12),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: _controller.isMagnified ? 80 : 60,
                      color: Color.alphaBlend(
                        _controller.primaryColor.withOpacity(0.3),
                        Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _controller.translate('noRecentChats'),
                      style: GoogleFonts.poppins(
                        fontSize: _controller.isMagnified ? 18 : 14,
                        color: Color.alphaBlend(
                          _controller.textColor.withOpacity(0.5),
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            size: _controller.isMagnified ? 80 : 60,
            color: Color.alphaBlend(
              _controller.primaryColor.withOpacity(0.3),
              Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _controller.translate('yourChatsWillAppearHere'),
            style: GoogleFonts.poppins(
              fontSize: _controller.isMagnified ? 18 : 14,
              color: Color.alphaBlend(
                _controller.textColor.withOpacity(0.5),
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}