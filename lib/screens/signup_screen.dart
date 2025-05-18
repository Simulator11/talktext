import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isMagnified = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _speak("Welcome to the sign-up page. Please enter your details.");
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Widget _buildMagnifierButton() {
    return IconButton(
      icon: Icon(
        Icons.zoom_in,
        color: Colors.blue[800],
        size: _isMagnified ? 30 : 24,
      ),
      onPressed: () {
        setState(() => _isMagnified = !_isMagnified);
        _speak(_isMagnified ? "Magnified view enabled" : "Normal view enabled");
      },
      tooltip: 'Toggle magnification',
    );
  }

  TextStyle _getTextStyle(bool isTitle) {
    return GoogleFonts.poppins(
      fontSize: _isMagnified
          ? (isTitle ? 32 : 20)
          : (isTitle ? 28 : 16),
      fontWeight: _isMagnified ? FontWeight.bold : FontWeight.normal,
      color: Colors.blue[900],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    Function? togglePasswordVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _getTextStyle(false)),
        SizedBox(height: _isMagnified ? 12 : 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? !isPasswordVisible : false,
          style: _getTextStyle(false),
          decoration: InputDecoration(
            hintText: "Enter $label",
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                if (togglePasswordVisibility != null) {
                  setState(() => togglePasswordVisibility());
                }
              },
            )
                : null,
            filled: true,
            fillColor: Colors.blue[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: _isMagnified ? 20 : 16,
                horizontal: 16
            ),
          ),
          onTap: () => _speak("Enter your $label"),
        ),
        SizedBox(height: _isMagnified ? 20 : 16),
      ],
    );
  }

  Future<void> _signup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _speak("Please fill in all fields.");
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      _speak("Passwords do not match.");
      _showSnackBar("Passwords do not match");
      return;
    }

    try {
      final response = await AuthService.signup(username, email, phone, password);
      if (response["status"] == "success") {
        _speak("Signup successful. Please log in.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        final message = response["message"] as String? ?? "Registration failed";
        _speak(message);
        _showSnackBar(message);
      }
    } catch (e) {
      _speak("An error occurred during registration");
      _showSnackBar("An error occurred: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: _getTextStyle(false)),
        backgroundColor: Colors.blue[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isMagnified ? Colors.lightBlue[50] : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [_buildMagnifierButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(_isMagnified ? 32 : 24),
          child: Column(
            children: [
              SizedBox(height: _isMagnified ? 40 : 20),
              Container(
                padding: EdgeInsets.all(_isMagnified ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1,
                  size: _isMagnified ? 60 : 50,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: _isMagnified ? 30 : 20),
              Text(
                "Create Account",
                style: _getTextStyle(true),
              ),
              SizedBox(height: _isMagnified ? 16 : 8),
              Text(
                "Fill in your details to get started",
                style: _getTextStyle(false),
              ),
              SizedBox(height: _isMagnified ? 50 : 40),
              _buildTextField(
                controller: _usernameController,
                label: "Username",
                icon: Icons.person_outline,
              ),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_android_outlined,
              ),
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                togglePasswordVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              _buildTextField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isConfirmPasswordVisible,
                togglePasswordVisibility: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              SizedBox(height: _isMagnified ? 30 : 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(
                      vertical: _isMagnified ? 20 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Sign Up",
                    style: _getTextStyle(false).copyWith(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: _isMagnified ? 30 : 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: _getTextStyle(false),
                  ),
                  GestureDetector(
                    onTap: () {
                      _speak("Navigating to login page");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Login",
                      style: _getTextStyle(false).copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}