import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gallery/presentation/gallery_preview_sheet.dart';
import '../data/user_repository.dart';
import '../domain/profile_notifier.dart';
import '../domain/user_profile.dart';
import 'profile_screen.dart' show galleryThumbnailWidget;

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileNotifierProvider(uid));
    final templatesAsync = ref.watch(ownTemplatesProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (profile) => ListView(
          children: [
            const SizedBox(height: 24),
            Center(child: _AvatarWidget(profile: profile, radius: 44)),
            const SizedBox(height: 12),
            Center(
              child: Text(
                profile?.displayName.isNotEmpty == true
                    ? profile!.displayName
                    : '(名前なし)',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            if (profile?.bio.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Text(
                  profile!.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 12),
            // フォローボタン
            if (profile != null)
              _FollowButton(targetUid: profile.uid),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(child: _StatTile(label: 'テンプレート', value: '${profile?.templateCount ?? 0}')),
                  Expanded(child: _StatTile(label: 'いいね', value: '${profile?.totalLikes ?? 0}')),
                  Expanded(child: _StatTile(label: 'フォロワー', value: '${profile?.followerCount ?? 0}')),
                  Expanded(child: _StatTile(label: 'フォロー中', value: '${profile?.followingCount ?? 0}')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '投稿したテンプレート',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ),
            templatesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('エラー: $e', style: const TextStyle(color: Colors.red)),
              ),
              data: (templates) {
                if (templates.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('まだ投稿がありません', style: TextStyle(color: Colors.black38)),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: templates.length,
                  separatorBuilder: (context, _) => const Divider(height: 1, indent: 16),
                  itemBuilder: (ctx, i) {
                    final t = templates[i];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(width: 40, height: 40, child: galleryThumbnailWidget(t)),
                      ),
                      title: Text(t.name),
                      subtitle: Text('いいね ${t.likeCount}'),
                      onTap: () => showGalleryPreview(ctx, ref, t),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _FollowButton extends ConsumerStatefulWidget {
  const _FollowButton({required this.targetUid});
  final String targetUid;

  @override
  ConsumerState<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<_FollowButton> {
  bool? _optimisticFollowing;
  bool _loading = false;

  Future<void> _toggle(String currentUid, bool isFollowing) async {
    setState(() {
      _optimisticFollowing = !isFollowing;
      _loading = true;
    });
    try {
      final repo = ref.read(userRepositoryProvider);
      if (isFollowing) {
        await repo.unfollowUser(currentUid, widget.targetUid);
      } else {
        await repo.followUser(currentUid, widget.targetUid);
      }
      ref.invalidate(isFollowingProvider(widget.targetUid));
      ref.invalidate(userProfileNotifierProvider(widget.targetUid));
      ref.invalidate(followingFeedProvider);
      // フォロー中/フォロワー一覧を更新
      ref.invalidate(followingProfilesProvider(currentUid));
      ref.invalidate(followerProfilesProvider(widget.targetUid));
    } catch (_) {
      if (mounted) setState(() => _optimisticFollowing = isFollowing);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isAnon = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
    if (currentUid == null || isAnon || currentUid == widget.targetUid) {
      return const SizedBox.shrink();
    }

    final followAsync = ref.watch(isFollowingProvider(widget.targetUid));
    final isFollowing = _optimisticFollowing ?? followAsync.valueOrNull;

    if (isFollowing == null) {
      return const SizedBox(height: 36);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        child: isFollowing
            ? OutlinedButton(
                onPressed: _loading ? null : () => _toggle(currentUid, isFollowing),
                child: const Text('フォロー中'),
              )
            : FilledButton(
                onPressed: _loading ? null : () => _toggle(currentUid, isFollowing),
                child: const Text('フォローする'),
              ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({required this.profile, required this.radius});
  final UserProfile? profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (profile?.avatarBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(profile!.avatarBytes!),
      );
    }
    if (profile?.avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(profile!.avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.indigo.shade100,
      child: Icon(Icons.person, size: radius, color: Colors.indigo),
    );
  }
}
