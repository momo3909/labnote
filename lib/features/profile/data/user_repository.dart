import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';

final userRepositoryProvider = Provider((_) => UserRepository());

class UserRepository {
  static const _col = 'users';
  final _db = FirebaseFirestore.instance;

  Future<UserProfile?> fetchProfile(String uid) async {
    final doc = await _db.collection(_col).doc(uid).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Future<List<UserProfile>> fetchRanking({int limit = 30}) async {
    final snap = await _db
        .collection(_col)
        .orderBy('totalLikes', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<void> createOrUpdate(UserProfile profile) async {
    await _db.collection(_col).doc(profile.uid).set(
          profile.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> updateDisplayName(String uid, String name) async {
    await _db.collection(_col).doc(uid).set(
      {'displayName': name},
      SetOptions(merge: true),
    );
  }

  Future<void> updateBio(String uid, String bio) async {
    await _db.collection(_col).doc(uid).set(
      {'bio': bio},
      SetOptions(merge: true),
    );
  }

  Future<void> updateAvatarBytes(String uid, Uint8List bytes) async {
    await _db.collection(_col).doc(uid).set(
      {'avatarBytes': bytes},
      SetOptions(merge: true),
    );
  }

  Future<void> incrementTemplateCount(String uid) async {
    await _db.collection(_col).doc(uid).set(
      {'templateCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  Future<void> decrementTemplateCount(String uid) async {
    await _db.collection(_col).doc(uid).set(
      {'templateCount': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
  }

  Future<void> incrementTotalLikes(String uid) async {
    await _db.collection(_col).doc(uid).set(
      {'totalLikes': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  Future<void> decrementTotalLikes(String uid) async {
    await _db.collection(_col).doc(uid).set(
      {'totalLikes': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
  }

  static Uint8List? _toBytes(dynamic value) {
    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is List) return Uint8List.fromList(value.cast<int>());
    return null;
  }

  UserProfile _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return UserProfile(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? '',
      bio: d['bio'] as String? ?? '',
      templateCount: (d['templateCount'] as num?)?.toInt() ?? 0,
      totalLikes: (d['totalLikes'] as num?)?.toInt() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avatarBytes: _toBytes(d['avatarBytes']),
      avatarUrl: d['avatarUrl'] as String?,
    );
  }
}
