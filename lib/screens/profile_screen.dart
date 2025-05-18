import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String phone;
  final String userId;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.phone,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String phone = '';
  String email = '';
  File? _image;
  bool _isMagnified = false;
  String _currentLanguage = 'en';

  // Modern color scheme with light blue as primary
  final Color _primaryColor = Colors.lightBlue.shade400;
  final Color _secondaryColor = Colors.lightBlue.shade200;
  final Color _accentColor = Colors.blueAccent;
  final Color _textColor = Colors.blueGrey.shade800;
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? _translate('noName');
      phone = prefs.getString('phone') ?? _translate('noPhone');
      email = prefs.getString('email') ?? _translate('noEmail');

      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null && File(imagePath).existsSync()) {
        _image = File(imagePath);
      }
    });
  }

  String _translate(String key) {
    final translations = {
      'myProfile': {'en': 'My Profile', 'sw': 'Wasifu Wangu'},
      'noName': {'en': 'No Name', 'sw': 'Hakuna Jina'},
      'noPhone': {'en': 'No Phone', 'sw': 'Hakuna Simu'},
      'noEmail': {'en': 'No Email', 'sw': 'Hakuna Barua Pepe'},
      'username': {'en': 'Username', 'sw': 'Jina la Mtumiaji'},
      'phone': {'en': 'Phone', 'sw': 'Nambari ya Simu'},
      'email': {'en': 'Email', 'sw': 'Barua Pepe'},
      'editProfile': {'en': 'Edit Profile', 'sw': 'Hariri Wasifu'},
      'magnifiedView': {'en': 'Magnified view', 'sw': 'Mtazamo mkubwa'},
      'normalView': {'en': 'Normal view', 'sw': 'Mtazamo wa kawaida'},
    };

    return translations[key]?[_currentLanguage] ?? key;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryColor.withOpacity(0.05),
      appBar: AppBar(
        title: Text(_translate('myProfile'),
          style: GoogleFonts.poppins(
            fontSize: _isMagnified ? 22 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          _buildMagnifierButton(),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              ).then((_) {
                _loadProfile();
                _loadLanguagePreference();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient header with profile picture
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : Image.asset(
                          'assets/default_profile_pic.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile information cards
            Padding(
              padding: EdgeInsets.all(_isMagnified ? 25 : 20),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.person_outline_rounded,
                    title: _translate('username'),
                    value: username,
                  ),
                  SizedBox(height: _isMagnified ? 20 : 15),
                  _buildInfoCard(
                    icon: Icons.phone_iphone_rounded,
                    title: _translate('phone'),
                    value: phone,
                  ),
                  SizedBox(height: _isMagnified ? 20 : 15),
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    title: _translate('email'),
                    value: email,
                  ),
                  SizedBox(height: _isMagnified ? 30 : 25),

                  // Edit profile button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfileScreen()),
                        ).then((_) {
                          _loadProfile();
                          _loadLanguagePreference();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: _isMagnified ? 16 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: _primaryColor.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_rounded, size: _isMagnified ? 24 : 20),
                          SizedBox(width: 10),
                          Text(
                            _translate('editProfile'),
                            style: GoogleFonts.poppins(
                              fontSize: _isMagnified ? 18 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(_isMagnified ? 20 : 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: _isMagnified ? 50 : 44,
            height: _isMagnified ? 50 : 44,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: _isMagnified ? 26 : 22,
            ),
          ),
          SizedBox(width: _isMagnified ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: _isMagnified ? 16 : 14,
                    color: _textColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: _isMagnified ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}