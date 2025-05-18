import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _signupUrl = "http://192.168.1.188/TALKTEXT/auth/signup.php";
  static const String _loginUrl = "http://192.168.1.188/TALKTEXT/auth/login.php";

  static Future<Map<String, dynamic>> signup(
      String username, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_signupUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "username": username,
          "email": email,
          "phone": phone,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"status": "error", "message": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"status": "error", "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"email": email, "password": password},
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("username", data["username"]);
        await prefs.setString("phone", data["phone"]);
      }

      return data;
    } catch (e) {
      return {"status": "error", "message": "Network error: $e"};
    }
  }
}
