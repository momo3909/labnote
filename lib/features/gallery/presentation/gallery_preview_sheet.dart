import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../shared/widgets/layer_stack_preview.dart';
import '../data/gallery_repository.dart';
import '../domain/gallery_notifier.dart';
import '../domain/gallery_template.dart';

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
    builder: (ctx) => _GalleryPreviewSheet(template: template, ref: ref),
  );
}

class _GalleryPreviewSheet extends StatelessWidget {
  const _GalleryPreviewSheet({required this.template, required this.ref});
  final GalleryTemplate template;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.88;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (template.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            template.description,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // 著者情報
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
                                if (template.authorAvatarUrl != null)
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(template.authorAvatarUrl!),
                                  )
                                else
                                  const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black12,
                                    child: Icon(Icons.person, size: 14, color: Colors.black45),
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  template.authorName.isNotEmpty
                                      ? template.authorName
                                      : '投稿者',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.indigo,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (ctx, r, _) {
                    final isLiked = r
                        .watch(galleryLikedIdsProvider)
                        .contains(template.id);
                    final currentUid =
                        FirebaseAuth.instance.currentUser?.uid;
                    final isOwner = currentUid != null &&
                        currentUid == template.authorId;
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => r
                              .read(galleryNotifierProvider.notifier)
                              .toggleLike(template.id),
                          child: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.black38,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('${template.likeCount}',
                            style: const TextStyle(color: Colors.black54)),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 22),
                            tooltip: '投稿を削除',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                _confirmDelete(ctx, r),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // プレビュー
          Flexible(
            child: LayerStackPreview(
              pageConfig: template.pageConfig,
              layers: template.layers,
            ),
          ),
          const Divider(height: 1),
          // アクションボタン
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _import(context);
                  },
                  child: const Text('このテンプレートを使う'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('投稿を削除'),
        content: Text('「${template.name}」をギャラリーから削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await r.read(galleryNotifierProvider.notifier).deleteTemplate(template.id);
    if (!context.mounted) return;
    Navigator.pop(context); // シートを閉じる
  }

  Future<void> _import(BuildContext context) async {
    await ref
        .read(galleryRepositoryProvider)
        .incrementDownload(template.id);

    final saved = await ref.read(templateRepositoryProvider).create(
          name: template.name,
          pageConfig: template.pageConfig,
          layers: template.layers,
          thumbnail: template.thumbnailBytes,
        );
    ref.invalidate(templatesProvider);

    if (!context.mounted) return;
    context.push('/editor/${saved.uuid}');
  }
}
