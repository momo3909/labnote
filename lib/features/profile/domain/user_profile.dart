import 'dart:typed_data';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.bio,
    required this.templateCount,
    required this.totalLikes,
    required this.createdAt,
    this.avatarBytes,
    this.avatarUrl,
  });

  final String uid;
  final String displayName;
  final String bio;
  final int templateCount;
  final int totalLikes;
  final DateTime createdAt;
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  UserProfile copyWith({
    String? displayName,
    String? bio,
    int? templateCount,
    int? totalLikes,
    Uint8List? avatarBytes,
    String? avatarUrl,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      templateCount: templateCount ?? this.templateCount,
      totalLikes: totalLikes ?? this.totalLikes,
      createdAt: createdAt,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'bio': bio,
      'templateCount': templateCount,
      'totalLikes': totalLikes,
      'createdAt': createdAt,
      if (avatarBytes != null) 'avatarBytes': avatarBytes,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}
