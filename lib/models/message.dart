class Message {
  final String message;
  final String senderPhone;
  final String receiverPhone;
  final String timestamp;

  Message({
    required this.message,
    required this.senderPhone,
    required this.receiverPhone,
    required this.timestamp,
  });

  // Convert from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      senderPhone: json['sender_phone'],
      receiverPhone: json['receiver_phone'],
      timestamp: json['timestamp'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender_phone': senderPhone,
      'receiver_phone': receiverPhone,
      'timestamp': timestamp,
    };
  }
}
