// lib/data/models/user.dart

class User {
  final String id;
  final String name;
  final String status;
  final String? profilePic; // Nullable

  User({
    required this.id,
    required this.name,
    required this.status,
    this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      profilePic: json['profilePic'],
    );
  }

  // Helper to get initials if no profile picture exists
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}