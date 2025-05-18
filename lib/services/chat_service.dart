import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/message.dart';
import '../models/user_model.dart';

class ChatService {
  final String baseUrl;

  ChatService({required this.baseUrl});

  // Function to get messages
  Future<List<Message>> getMessages({
    required String senderPhone,
    required String receiverPhone,
  }) async {
    final url = '$baseUrl/get_messages.php?sender_phone=$senderPhone&receiver_phone=$receiverPhone';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
  Future<void> sendMessage({
    required String senderPhone,
    required String receiverPhone,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_phone': senderPhone,
          'receiver_phone': receiverPhone,
          'message': message,
        }),
      );

      // Debugging response
      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        print('Message sent successfully');
      } else {
        print('Failed to send message: ${responseData['message']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Fetch users function (added modification)
  Future<List<User>> fetchUsers(String currentUserPhone) async {
    final url = '$baseUrl/get_users.php?exclude_phone=$currentUserPhone';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> usersJson = responseData['users'];

      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
