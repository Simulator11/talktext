import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isMagnified = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _speak("Welcome to the login page. Please enter your email and password.");
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

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _speak("Please enter both email and password");
      _showSnackBar("Please enter both email and password");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final result = await AuthService.login(email, password);
      if (result["status"] == "success") {
        final username = result["username"] as String? ?? 'User';
        final phone = result["phone"] as String? ?? '';

        _speak("Login successful. Welcome $username");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              username: username,
              phone: phone,
            ),
          ),
        );
      } else {
        final message = result["message"] as String? ?? 'Login failed';
        _speak(message);
        _showSnackBar(message);
      }
    } catch (e) {
      _speak("An error occurred during login");
      _showSnackBar("An error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _getTextStyle(false)),
        SizedBox(height: _isMagnified ? 12 : 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          style: _getTextStyle(false),
          decoration: InputDecoration(
            hintText: "Enter your $label",
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
                _speak(_isPasswordVisible ? "Password visible" : "Password hidden");
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
                  Icons.chat_bubble_outline,
                  size: _isMagnified ? 60 : 50,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: _isMagnified ? 30 : 20),
              Text(
                "Welcome Back",
                style: _getTextStyle(true),
              ),
              SizedBox(height: _isMagnified ? 16 : 8),
              Text(
                "Login to continue your conversation",
                style: _getTextStyle(false),
              ),
              SizedBox(height: _isMagnified ? 50 : 40),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outlined,
                isPassword: true,
              ),
              SizedBox(height: _isMagnified ? 16 : 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _speak("Forgot password feature coming soon");
                    _showSnackBar("Forgot password feature coming soon");
                  },
                  child: Text(
                    "Forgot Password?",
                    style: _getTextStyle(false).copyWith(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: _isMagnified ? 30 : 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    "Login",
                    style: _getTextStyle(false).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: _isMagnified ? 30 : 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: _getTextStyle(false),
                  ),
                  GestureDetector(
                    onTap: () {
                      _speak("Navigating to signup page");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      "Sign Up",
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}