/// User profile model for storing IPTV credentials
class UserProfile {
  final String id;
  final String name;
  final String host;
  final String username;
  final String password;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const UserProfile({
    required this.id,
    required this.name,
    required this.host,
    required this.username,
    required this.password,
    this.isActive = false,
    required this.createdAt,
    this.lastUsed,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      host: json['host'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'host': host,
      'username': username,
      'password': password,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? host,
    String? username,
    String? password,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, host: $host, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}