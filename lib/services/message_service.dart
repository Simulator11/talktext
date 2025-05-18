import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessageService {
  final String baseUrl = 'http://192.168.1.188/TALKTEXT';

  // Fetch messages from the database or API
  Future<List<Message>> fetchMessages(String currentUserPhone, String otherUserPhone) async {
    final url = '$baseUrl/get_messages.php?sender_phone=$currentUserPhone&receiver_phone=$otherUserPhone';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Send a message to the server
  Future<void> sendMessage(Message message) async {
    final url = '$baseUrl/send_message.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'message': message.message,
        'sender_phone': message.senderPhone,
        'receiver_phone': message.receiverPhone,
        'timestamp': message.timestamp,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }
}
