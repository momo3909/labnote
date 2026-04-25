import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gallery/presentation/gallery_preview_sheet.dart';
import '../domain/profile_notifier.dart';
import '../domain/user_profile.dart';

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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'テンプレート数',
                      value: '${profile?.templateCount ?? 0}',
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'いいね数',
                      value: '${profile?.totalLikes ?? 0}',
                    ),
                  ),
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
                      leading: t.thumbnailBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                t.thumbnailBytes!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.description_outlined),
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
