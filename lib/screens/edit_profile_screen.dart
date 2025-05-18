import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../services/tts_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TtsService _tts = TtsService();
  File? _image;
  bool _isMagnified = false;

  // Color scheme matching ProfileScreen
  final Color _primaryColor = Colors.lightBlueAccent;
  final Color _cardColor = Colors.white;
  final Color _textColor = Colors.blueGrey.shade800;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _emailController.text = prefs.getString('email') ?? '';

      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null && File(imagePath).existsSync()) {
        _image = File(imagePath);
      }
    });
    await _tts.speak("Profile loaded");
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('email', _emailController.text);

    if (_image != null) {
      await prefs.setString('profile_image', _image!.path);
    }

    await _tts.speak("Profile saved");
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    await _tts.speak("Profile picture selected");
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
      tooltip: 'Toggle text size',
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
      backgroundColor: Colors.lightBlueAccent.shade100, // Fallback color
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlueAccent.shade400,
              Colors.lightBlueAccent.shade200,
              Colors.lightBlueAccent.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text('Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: _isMagnified ? 22 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                _buildMagnifierButton(),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(_isMagnified ? 25 : 20),
                child: Column(
                  children: [
                    // Profile picture with edit option
                    GestureDetector(
                      onTap: _pickImage,
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              width: _isMagnified ? 160 : 140,
                              height: _isMagnified ? 160 : 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: _isMagnified ? 24 : 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: _isMagnified ? 30 : 25),

                    // Edit form fields
                    _buildEditField(
                      controller: _usernameController,
                      label: "Username",
                      icon: Icons.person,
                    ),
                    SizedBox(height: _isMagnified ? 20 : 15),
                    _buildEditField(
                      controller: _phoneController,
                      label: "Phone",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: _isMagnified ? 20 : 15),
                    _buildEditField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: _isMagnified ? 30 : 25),

                    // Save button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: _isMagnified ? 16 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: Colors.lightBlueAccent.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save,
                              size: _isMagnified ? 24 : 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Save Profile",
                              style: GoogleFonts.poppins(
                                fontSize: _isMagnified ? 18 : 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: _getTextStyle(false),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.blueGrey.shade600,
            fontSize: _isMagnified ? 16 : 14,
          ),
          prefixIcon: Icon(
            icon,
            color: _primaryColor,
            size: _isMagnified ? 26 : 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: _isMagnified ? 18 : 16,
          ),
          filled: true,
          fillColor: _cardColor,
        ),
      ),
    );
  }
}