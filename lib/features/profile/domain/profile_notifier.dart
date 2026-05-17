import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../gallery/data/gallery_repository.dart';
import '../../gallery/domain/gallery_template.dart';
import '../data/user_repository.dart';
import 'user_profile.dart';

part 'profile_notifier.g.dart';

/// Firebase認証状態をストリームで監視するプロバイダー
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 現在ログイン中ユーザーのプロフィールを監視する
@riverpod
Future<UserProfile?> currentProfile(CurrentProfileRef ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return null;
  final repo = ref.read(userRepositoryProvider);
  return repo.fetchProfile(user.uid);
}

/// 自分のプロフィール編集用 Notifier
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfile?> build(String uid) async {
    final repo = ref.read(userRepositoryProvider);
    return repo.fetchProfile(uid);
  }

  Future<void> updateDisplayName(String name) async {
    // 楽観的更新
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(displayName: name));
    }
    await ref.read(userRepositoryProvider).updateDisplayName(uid, name);
    ref.invalidate(currentProfileProvider);
  }

  Future<void> updateBio(String bio) async {
    // 楽観的更新
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(bio: bio));
    }
    await ref.read(userRepositoryProvider).updateBio(uid, bio);
    ref.invalidate(currentProfileProvider);
  }

  Future<void> updateAvatarBytes(Uint8List bytes) async {
    // Storage アップロード → URL をプロフィールに反映
    await ref.read(userRepositoryProvider).updateAvatarBytes(uid, bytes);
    ref.invalidate(currentProfileProvider);
  }

  Future<void> ensureProfileExists({
    required String displayName,
    String? avatarUrl,
  }) async {
    final repo = ref.read(userRepositoryProvider);
    final existing = await repo.fetchProfile(uid);
    if (existing != null) return;
    final profile = UserProfile(
      uid: uid,
      displayName: displayName,
      bio: '',
      templateCount: 0,
      totalLikes: 0,
      createdAt: DateTime.now(),
      avatarUrl: avatarUrl,
    );
    await repo.createOrUpdate(profile);
    state = AsyncData(profile);
    ref.invalidate(currentProfileProvider);
  }
}

/// ユーザーランキング（いいね数降順）
@riverpod
Future<List<UserProfile>> userRanking(UserRankingRef ref) async {
  final repo = ref.read(userRepositoryProvider);
  return repo.fetchRanking();
}

/// 特定ユーザーが投稿したギャラリーテンプレート一覧
@riverpod
Future<List<GalleryTemplate>> ownTemplates(OwnTemplatesRef ref, String uid) async {
  final repo = ref.read(galleryRepositoryProvider);
  return repo.fetchByAuthor(uid);
}

@riverpod
Future<List<UserProfile>> followingProfiles(FollowingProfilesRef ref, String uid) =>
    ref.read(userRepositoryProvider).fetchFollowingProfiles(uid);

@riverpod
Future<List<UserProfile>> followerProfiles(FollowerProfilesRef ref, String uid) =>
    ref.read(userRepositoryProvider).fetchFollowerProfiles(uid);

/// 現在ユーザーが targetUid をフォローしているか
@riverpod
Future<bool> isFollowing(IsFollowingRef ref, String targetUid) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return false;
  return ref.read(userRepositoryProvider).isFollowing(user.uid, targetUid);
}

/// フォロー中ユーザーの投稿テンプレート一覧
@riverpod
Future<List<GalleryTemplate>> followingFeed(FollowingFeedRef ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return [];
  final uids = await ref.read(userRepositoryProvider).fetchFollowingUids(user.uid);
  if (uids.isEmpty) return [];
  return ref.read(galleryRepositoryProvider).fetchByFollowing(uids);
}
