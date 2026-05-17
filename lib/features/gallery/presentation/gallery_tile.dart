import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/layer_stack_preview.dart';
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

class GalleryTile extends ConsumerWidget {
  const GalleryTile({
    super.key,
    required this.template,
    required this.onPreview,
    required this.onImport,
  });

  final GalleryTemplate template;
  final VoidCallback onPreview;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(galleryLikedIdsProvider);
    final isLiked = likedIds.contains(template.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onPreview,
      leading: _Thumbnail(template: template),
      title: Text(template.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (template.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                template.description,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              ...template.layerTypes.take(3).map((t) => _layerChip(_layerLabel(t))),
              ...template.tags.map((tag) => _tagChip(tag)),
              _statBadge(icon: Icons.download_outlined, value: template.downloadCount),
            ],
          ),
        ],
      ),
      trailing: Row(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked ? Colors.red : Colors.black38,
                ),
                Text(
                  '${template.likeCount}',
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 20),
            tooltip: '読み込む',
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null || user.isAnonymous) {
                _showLoginRequired(context);
                return;
              }
              onImport();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class GalleryGridCard extends ConsumerWidget {
  const GalleryGridCard({
    super.key,
    required this.template,
    required this.onPreview,
    required this.onImport,
    this.compact = false,
  });

  final GalleryTemplate template;
  final VoidCallback onPreview;
  final VoidCallback onImport;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(galleryLikedIdsProvider).contains(template.id);

    return GestureDetector(
      onTap: onPreview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: _thumbnailWidget(template, BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 3, 2, 0),
            child: Text(
              template.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 1, 2, 2),
            child: Row(
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
                    size: compact ? 11 : 12,
                    color: isLiked ? Colors.red : Colors.black38,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '${template.likeCount}',
                  style: TextStyle(
                    fontSize: compact ? 9 : 10,
                    color: Colors.black45,
                  ),
                ),
                if (!compact) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null || user.isAnonymous) {
                        _showLoginRequired(context);
                        return;
                      }
                      onImport();
                    },
                    child: const Icon(
                      Icons.download_rounded,
                      size: 13,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.template});
  final GalleryTemplate template;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 36,
        height: 50,
        child: _thumbnailWidget(template, BoxFit.cover),
      ),
    );
  }
}

Widget _thumbnailWidget(GalleryTemplate t, BoxFit fit) {
  if (t.thumbnailUrl != null) {
    return Image.network(t.thumbnailUrl!, fit: fit,
        errorBuilder: (_, __, ___) => _previewFallback(t));
  }
  if (t.thumbnailBytes != null) {
    return Image.memory(t.thumbnailBytes!, fit: fit);
  }
  return _previewFallback(t);
}

Widget _previewFallback(GalleryTemplate t) => ColoredBox(
      color: Colors.white,
      child: LayerStackPreview(
        pageConfig: t.pageConfig,
        layers: t.layers,
        padding: EdgeInsets.zero,
      ),
    );

// ── ヘルパー ─────────────────────────────────────────────────────────────────

String _layerLabel(String type) => const {
      'grid': '方眼',
      'line': '罫線',
      'dot': 'ドット',
      'cornell': 'コーネル',
      'log_grid': '対数',
      'hex': '六角',
      'isometric': '等角',
      'polar': '極座標',
      'manuscript': '原稿用紙',
      'timetable': '時間割',
      'region': '領域分割',
      'guide': 'ガイド',
      'staff': '五線譜',
      'ruledGrid': '方眼+罫線',
      'stamp': 'スタンプ',
      'graphAxis': '座標軸',
      'table': '表',
      'customLine': 'カスタム線',

      'header': 'ヘッダー',
    }[type] ??
    type;

Widget _layerChip(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
    );

Widget _tagChip(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border.all(color: Colors.indigo.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: Colors.indigo.shade700)),
    );

Widget _statBadge({required IconData icon, required int value}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.black38),
        const SizedBox(width: 2),
        Text('$value', style: const TextStyle(fontSize: 10, color: Colors.black38)),
      ],
    );
