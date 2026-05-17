import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../gallery/domain/gallery_notifier.dart' show likedTemplatesProvider;
import '../../gallery/domain/gallery_template.dart';
import '../../gallery/presentation/gallery_preview_sheet.dart';
import '../../../shared/widgets/layer_stack_preview.dart';
import '../domain/profile_notifier.dart';
import '../domain/user_profile.dart';

// フォロー中 / フォロワー一覧シート
class _UserListSheet extends ConsumerWidget {
  const _UserListSheet({required this.title, required this.provider});
  final String title;
  final ProviderListenable<AsyncValue<List<UserProfile>>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);
    final sheetH = MediaQuery.of(context).size.height * 0.65;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // 固定高さにすることでロード前後でシートがジャンプしない
    return SizedBox(
      height: sheetH,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('エラー: $e', style: const TextStyle(color: Colors.red)),
              ),
              data: (users) => users.isEmpty
                  ? Center(
                      child: Text('まだ$titleがいません',
                          style: const TextStyle(color: Colors.black38)),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(
                          top: 8, bottom: bottomPad + 8),
                      itemCount: users.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (ctx, i) =>
                          _UserTile(profile: users[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (profile.avatarBytes != null) {
      avatar = CircleAvatar(radius: 20, backgroundImage: MemoryImage(profile.avatarBytes!));
    } else if (profile.avatarUrl != null) {
      avatar = CircleAvatar(radius: 20, backgroundImage: NetworkImage(profile.avatarUrl!));
    } else {
      avatar = CircleAvatar(
        radius: 20,
        backgroundColor: Colors.indigo.shade100,
        child: const Icon(Icons.person, size: 20, color: Colors.indigo),
      );
    }

    return ListTile(
      leading: avatar,
      title: Text(
        profile.displayName.isNotEmpty ? profile.displayName : '(名前なし)',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: profile.bio.isNotEmpty
          ? Text(profile.bio,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12))
          : null,
      onTap: () {
        Navigator.pop(context);
        context.push('/profile/${profile.uid}');
      },
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('エラー: $e')),
      ),
      data: (user) {
        if (user == null || user.isAnonymous) {
          return Scaffold(
            appBar: AppBar(title: const Text('マイプロフィール')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline,
                      size: 64, color: Colors.black26),
                  const SizedBox(height: 16),
                  const Text(
                    'ログインしてプロフィールを作成',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('ログイン / アカウント作成'),
                  ),
                ],
              ),
            ),
          );
        }

        final profileAsync =
            ref.watch(userProfileNotifierProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: const Text('マイプロフィール'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          body: profileAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
            data: (profile) =>
                _ProfileBody(uid: user.uid, profile: profile),
          ),
        );
      },
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.uid, required this.profile});
  final String uid;
  final UserProfile? profile;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  bool _editingName = false;
  bool _editingBio = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile?.displayName ?? '');
    _bioCtrl = TextEditingController(text: widget.profile?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 256,
      maxHeight: 256,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    await ref.read(userProfileNotifierProvider(widget.uid).notifier).updateAvatarBytes(bytes);
  }

  void _showLikedTemplates(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _LikedTemplatesSheet(uid: widget.uid),
    );
  }

  void _showUserList(
    BuildContext context,
    String title,
    ProviderListenable<AsyncValue<List<UserProfile>>> provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _UserListSheet(title: title, provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return ListView(
      children: [
        const SizedBox(height: 24),
        // アバター
        Center(
          child: GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                _AvatarWidget(profile: profile, radius: 48),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 表示名
        Center(
          child: _editingName
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: '表示名を入力',
                      border: UnderlineInputBorder(),
                    ),
                    onSubmitted: (val) async {
                      setState(() => _editingName = false);
                      if (val.trim().isEmpty) return;
                      await ref
                          .read(userProfileNotifierProvider(widget.uid).notifier)
                          .updateDisplayName(val.trim());
                    },
                  ),
                )
              : GestureDetector(
                  onTap: () => setState(() => _editingName = true),
                  child: Text(
                    profile?.displayName.isNotEmpty == true
                        ? profile!.displayName
                        : '表示名未設定',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        // Bio
        if (_editingBio)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                TextField(
                  controller: _bioCtrl,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '自己紹介を入力',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _bioCtrl.text = widget.profile?.bio ?? '';
                        setState(() => _editingBio = false);
                      },
                      child: const Text('キャンセル'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        setState(() => _editingBio = false);
                        await ref
                            .read(userProfileNotifierProvider(widget.uid).notifier)
                            .updateBio(_bioCtrl.text.trim());
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _editingBio = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                profile?.bio.isNotEmpty == true ? profile!.bio : '自己紹介を追加...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: profile?.bio.isNotEmpty == true
                      ? Colors.black87
                      : Colors.black38,
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        // 統計行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'テンプレート',
                  value: '${profile?.templateCount ?? 0}',
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLikedTemplates(context),
                  child: _StatTile(
                    label: 'いいね',
                    value: '${profile?.totalLikes ?? 0}',
                    tappable: true,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showUserList(
                    context, 'フォロー中', followingProfilesProvider(widget.uid)),
                  child: _StatTile(
                    label: 'フォロー中',
                    value: '${profile?.followingCount ?? 0}',
                    tappable: true,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showUserList(
                    context, 'フォロワー', followerProfilesProvider(widget.uid)),
                  child: _StatTile(
                    label: 'フォロワー',
                    value: '${profile?.followerCount ?? 0}',
                    tappable: true,
                  ),
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
        _OwnTemplatesList(uid: widget.uid),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _OwnTemplatesList extends ConsumerWidget {
  const _OwnTemplatesList({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownTemplatesProvider(uid));
    return async.when(
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
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: galleryThumbnailWidget(t),
                ),
              ),
              title: Text(t.name),
              subtitle: Text('いいね ${t.likeCount}'),
              onTap: () => showGalleryPreview(ctx, ref, t),
            );
          },
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.tappable = false});
  final String label;
  final String value;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            if (tappable)
              const Icon(Icons.chevron_right, size: 12, color: Colors.black38),
          ],
        ),
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

Widget galleryThumbnailWidget(GalleryTemplate t) {
  if (t.thumbnailUrl != null) {
    return Image.network(t.thumbnailUrl!, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => galleryPreviewFallback(t));
  }
  if (t.thumbnailBytes != null) {
    return Image.memory(t.thumbnailBytes!, fit: BoxFit.cover);
  }
  return galleryPreviewFallback(t);
}

Widget galleryPreviewFallback(GalleryTemplate t) => ColoredBox(
      color: Colors.white,
      child: LayerStackPreview(
        pageConfig: t.pageConfig,
        layers: t.layers,
        padding: EdgeInsets.zero,
      ),
    );

class _LikedTemplatesSheet extends ConsumerWidget {
  const _LikedTemplatesSheet({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(likedTemplatesProvider(uid));
    final sheetH = MediaQuery.of(context).size.height * 0.65;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: sheetH,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('いいねしたテンプレート',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('エラー: $e', style: const TextStyle(color: Colors.red)),
              ),
              data: (templates) => templates.isEmpty
                  ? const Center(
                      child: Text('まだいいねしたテンプレートがありません',
                          style: TextStyle(color: Colors.black38)),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(top: 8, bottom: bottomPad + 8),
                      itemCount: templates.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 56),
                      itemBuilder: (ctx, i) {
                        final t = templates[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: 40, height: 40,
                              child: galleryThumbnailWidget(t),
                            ),
                          ),
                          title: Text(t.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(t.authorName,
                              style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            showGalleryPreview(ctx, ref, t);
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
