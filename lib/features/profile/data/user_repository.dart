import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    // Storage にアップロードして URL を Firestore に保存
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_avatars')
        .child(uid);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _db.collection(_col).doc(uid).set(
      {'avatarUrl': url, 'avatarBytes': null},
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

  // ── フォロー ──────────────────────────────────────────────────────────────

  Future<void> followUser(String uid, String targetUid) async {
    final batch = _db.batch();
    batch.set(
      _db.collection(_col).doc(uid).collection('following').doc(targetUid),
      {'createdAt': FieldValue.serverTimestamp()},
    );
    // フォロワー一覧用サブコレクション
    batch.set(
      _db.collection(_col).doc(targetUid).collection('followers').doc(uid),
      {'createdAt': FieldValue.serverTimestamp()},
    );
    batch.set(
      _db.collection(_col).doc(uid),
      {'followingCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
    batch.set(
      _db.collection(_col).doc(targetUid),
      {'followerCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> unfollowUser(String uid, String targetUid) async {
    final batch = _db.batch();
    batch.delete(
      _db.collection(_col).doc(uid).collection('following').doc(targetUid),
    );
    batch.delete(
      _db.collection(_col).doc(targetUid).collection('followers').doc(uid),
    );
    batch.set(
      _db.collection(_col).doc(uid),
      {'followingCount': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
    batch.set(
      _db.collection(_col).doc(targetUid),
      {'followerCount': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<List<UserProfile>> fetchFollowingProfiles(String uid) async {
    final uids = await fetchFollowingUids(uid);
    if (uids.isEmpty) return [];
    final profiles = await Future.wait(
      uids.map((id) => fetchProfile(id)),
    );
    return profiles.whereType<UserProfile>().toList();
  }

  Future<List<UserProfile>> fetchFollowerProfiles(String uid) async {
    final snap = await _db
        .collection(_col)
        .doc(uid)
        .collection('followers')
        .get();
    if (snap.docs.isEmpty) return [];
    final profiles = await Future.wait(
      snap.docs.map((d) => fetchProfile(d.id)),
    );
    return profiles.whereType<UserProfile>().toList();
  }

  Future<bool> isFollowing(String uid, String targetUid) async {
    final doc = await _db
        .collection(_col)
        .doc(uid)
        .collection('following')
        .doc(targetUid)
        .get();
    return doc.exists;
  }

  Future<List<String>> fetchFollowingUids(String uid) async {
    final snap =
        await _db.collection(_col).doc(uid).collection('following').get();
    return snap.docs.map((d) => d.id).toList();
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
      followerCount: (d['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (d['followingCount'] as num?)?.toInt() ?? 0,
    );
  }
}
