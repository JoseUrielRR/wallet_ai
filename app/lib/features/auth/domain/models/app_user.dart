class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.isAnonymous = false,
    this.photoUrl,
    required this.createdAt,
  });

  bool get isAuthenticated => id.isNotEmpty;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isAnonymous,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      isAnonymous: map['isAnonymous'] ?? false,
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  String toString() =>
      'AppUser(id: $id, email: $email, isAnonymous: $isAnonymous, name: $displayName)';
}
