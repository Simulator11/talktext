class User {
  final String username;
  final String phone;
  final String email;
  final String profilePictureUrl; // Optional, for user profile display

  // Constructor
  User({
    required this.username,
    required this.phone,
    required this.email,
    required this.profilePictureUrl,
  });

  // ✅ Convert from JSON (e.g., from backend response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
    );
  }

  // ✅ Convert to JSON (if needed for upload)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'phone': phone,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // ✅ Convert User object to a map (for SharedPreferences or SQLite)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phone': phone,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // ✅ Create User from map (e.g., from SharedPreferences or SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }

  // ✅ Optional: readable printout for debugging
  @override
  String toString() {
    return 'User(username: $username, phone: $phone, email: $email, profilePictureUrl: $profilePictureUrl)';
  }
}
