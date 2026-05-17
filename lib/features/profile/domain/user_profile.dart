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
    this.followerCount = 0,
    this.followingCount = 0,
  });

  final String uid;
  final String displayName;
  final String bio;
  final int templateCount;
  final int totalLikes;
  final DateTime createdAt;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final int followerCount;
  final int followingCount;

  UserProfile copyWith({
    String? displayName,
    String? bio,
    int? templateCount,
    int? totalLikes,
    Uint8List? avatarBytes,
    String? avatarUrl,
    int? followerCount,
    int? followingCount,
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
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
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
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      // avatarBytes は Storage 移行済みのため書き込まない
    };
  }
}
