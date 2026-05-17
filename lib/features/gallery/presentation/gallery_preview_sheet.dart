import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../shared/widgets/layer_stack_preview.dart';
import '../../profile/domain/profile_notifier.dart';
import '../data/gallery_repository.dart';
import '../domain/gallery_comment.dart';
import '../domain/gallery_notifier.dart';
import '../domain/gallery_template.dart';

void _showLoginRequired(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('この操作にはログインが必要です'),
      action: SnackBarAction(
        label: 'ログインする',
        onPressed: () => context.push('/login'),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> showGalleryPreview(
  BuildContext context,
  WidgetRef ref,
  GalleryTemplate template,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _GalleryPreviewSheet(template: template, outerRef: ref),
  );
}

class _GalleryPreviewSheet extends ConsumerStatefulWidget {
  const _GalleryPreviewSheet({required this.template, required this.outerRef});
  final GalleryTemplate template;
  final WidgetRef outerRef;

  @override
  ConsumerState<_GalleryPreviewSheet> createState() =>
      _GalleryPreviewSheetState();
}

class _GalleryPreviewSheetState extends ConsumerState<_GalleryPreviewSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<GalleryComment>? _comments;
  bool _commentsLoading = false;
  final _commentController = TextEditingController();
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _comments == null) _loadComments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    final list = await ref
        .read(galleryRepositoryProvider)
        .fetchComments(widget.template.id);
    if (mounted) setState(() { _comments = list; _commentsLoading = false; });
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コメントするにはログインが必要です')),
      );
      return;
    }
    setState(() => _posting = true);
    final profile = await ref.read(userProfileNotifierProvider(user.uid).future);
    await ref.read(galleryRepositoryProvider).addComment(
      widget.template.id,
      text,
      authorId: user.uid,
      authorName: profile?.displayName ?? user.displayName ?? '匿名',
      authorAvatarUrl: profile?.avatarUrl ?? user.photoURL,
    );
    _commentController.clear();
    await _loadComments();
    setState(() => _posting = false);
  }

  Future<void> _deleteComment(String commentId) async {
    await ref
        .read(galleryRepositoryProvider)
        .deleteComment(widget.template.id, commentId);
    await _loadComments();
  }

  Future<void> _confirmDelete(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('投稿を削除'),
        content: Text('「${widget.template.name}」をギャラリーから削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('キャンセル')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !ctx.mounted) return;
    await ref.read(galleryNotifierProvider.notifier).deleteTemplate(widget.template.id);
    if (!ctx.mounted) return;
    Navigator.pop(ctx);
  }

  Future<void> _import() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      _showLoginRequired(context);
      return;
    }
    final repo = widget.outerRef.read(galleryRepositoryProvider);
    await repo.incrementDownload(widget.template.id);
    final saved = await widget.outerRef.read(templateRepositoryProvider).create(
      name: widget.template.name,
      pageConfig: widget.template.pageConfig,
      layers: widget.template.layers,
      thumbnail: widget.template.thumbnailBytes,
    );
    widget.outerRef.invalidate(templatesProvider);
    if (!mounted) return;
    Navigator.pop(context);
    context.push('/editor/${saved.uuid}');
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.92;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ヘッダー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Header(template: widget.template)),
                _LikeDeleteRow(template: widget.template, onDelete: () => _confirmDelete(context)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // タブバー
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'プレビュー'), Tab(text: 'コメント')],
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
          ),
          const Divider(height: 1),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PreviewTab(template: widget.template),
                _CommentsTab(
                  comments: _comments,
                  loading: _commentsLoading,
                  posting: _posting,
                  controller: _commentController,
                  currentUid: FirebaseAuth.instance.currentUser?.uid,
                  onPost: _postComment,
                  onDelete: _deleteComment,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // アクションボタン
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: FilledButton(
                onPressed: _import,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                child: const Text('このテンプレートを使う'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ヘッダー ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.template});
  final GalleryTemplate template;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(template.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        if (template.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(template.description,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        if (template.authorId.isNotEmpty)
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.push('/profile/${template.authorId}');
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  _AuthorAvatar(authorId: template.authorId, fallbackUrl: template.authorAvatarUrl),
                  const SizedBox(width: 6),
                  Text(
                    template.authorName.isNotEmpty ? template.authorName : '投稿者',
                    style: const TextStyle(
                      fontSize: 12, color: Colors.indigo,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── いいね・削除 ─────────────────────────────────────────────────────────────

class _LikeDeleteRow extends ConsumerWidget {
  const _LikeDeleteRow({required this.template, required this.onDelete});
  final GalleryTemplate template;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(galleryLikedIdsProvider).contains(template.id);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUid != null && currentUid == template.authorId;
    final likeCount = ref
            .watch(galleryNotifierProvider)
            .valueOrNull
            ?.firstWhere((t) => t.id == template.id, orElse: () => template)
            .likeCount ??
        template.likeCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null || user.isAnonymous) {
              _showLoginRequired(context);
              return;
            }
            ref.read(galleryNotifierProvider.notifier).toggleLike(template.id);
          },
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.black38,
          ),
        ),
        const SizedBox(width: 4),
        Text('$likeCount',
            style: const TextStyle(color: Colors.black54)),
        if (isOwner) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            tooltip: '投稿を削除',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}

// ── プレビュータブ ────────────────────────────────────────────────────────────

class _PreviewTab extends StatelessWidget {
  const _PreviewTab({required this.template});
  final GalleryTemplate template;

  @override
  Widget build(BuildContext context) {
    return LayerStackPreview(
      pageConfig: template.pageConfig,
      layers: template.layers,
    );
  }
}

// ── コメントタブ ─────────────────────────────────────────────────────────────

class _CommentsTab extends StatelessWidget {
  const _CommentsTab({
    required this.comments,
    required this.loading,
    required this.posting,
    required this.controller,
    required this.currentUid,
    required this.onPost,
    required this.onDelete,
  });

  final List<GalleryComment>? comments;
  final bool loading;
  final bool posting;
  final TextEditingController controller;
  final String? currentUid;
  final VoidCallback onPost;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : comments == null
                  ? const Center(
                      child: Text('コメントを読み込んでいます…',
                          style: TextStyle(color: Colors.black38)))
                  : comments!.isEmpty
                      ? const Center(
                          child: Text('まだコメントがありません',
                              style: TextStyle(color: Colors.black38)))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: comments!.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 56),
                          itemBuilder: (_, i) => _CommentTile(
                            comment: comments![i],
                            currentUid: currentUid,
                            onDelete: () => onDelete(comments![i].id),
                          ),
                        ),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(
            12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'コメントを入力…',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onPost(),
                ),
              ),
              const SizedBox(width: 8),
              posting
                  ? const SizedBox(
                      width: 36, height: 36,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: onPost,
                      color: Colors.indigo,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({
    required this.comment,
    required this.currentUid,
    required this.onDelete,
  });

  final GalleryComment comment;
  final String? currentUid;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn = currentUid != null && currentUid == comment.authorId;
    final profile =
        ref.watch(userProfileNotifierProvider(comment.authorId)).valueOrNull;

    final Widget avatar;
    if (profile?.avatarBytes != null) {
      avatar = CircleAvatar(
        radius: 16,
        backgroundImage: MemoryImage(profile!.avatarBytes!),
      );
    } else if (profile?.avatarUrl != null) {
      avatar = CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(profile!.avatarUrl!),
      );
    } else {
      avatar = const CircleAvatar(
        radius: 16,
        backgroundColor: Colors.black12,
        child: Icon(Icons.person, size: 16, color: Colors.black45),
      );
    }

    return ListTile(
      dense: true,
      leading: avatar,
      title: Row(
        children: [
          Text(
            comment.authorName.isNotEmpty ? comment.authorName : '匿名',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(comment.createdAt),
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ),
      subtitle: Text(comment.text, style: const TextStyle(fontSize: 13)),
      trailing: isOwn
          ? IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.black38),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : null,
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inDays < 1) return '${diff.inHours}時間前';
    if (diff.inDays < 30) return '${diff.inDays}日前';
    return '${dt.month}/${dt.day}';
  }
}

/// 投稿者アバター: avatarBytes（LabNote画像）→ avatarUrl → デフォルトアイコンの優先順で表示。
class _AuthorAvatar extends ConsumerWidget {
  const _AuthorAvatar({required this.authorId, this.fallbackUrl});
  final String authorId;
  final String? fallbackUrl;
  static const double _r = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileNotifierProvider(authorId)).valueOrNull;

    if (profile?.avatarBytes != null) {
      return CircleAvatar(radius: _r, backgroundImage: MemoryImage(profile!.avatarBytes!));
    }
    if (profile?.avatarUrl != null) {
      return CircleAvatar(radius: _r, backgroundImage: NetworkImage(profile!.avatarUrl!));
    }
    if (fallbackUrl != null) {
      return CircleAvatar(radius: _r, backgroundImage: NetworkImage(fallbackUrl!));
    }
    return const CircleAvatar(
      radius: _r,
      backgroundColor: Colors.black12,
      child: Icon(Icons.person, size: _r, color: Colors.black45),
    );
  }
}
