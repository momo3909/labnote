import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../shared/widgets/layer_stack_preview.dart';
import '../domain/gallery_notifier.dart';
import '../domain/gallery_template.dart';
import '../data/gallery_repository.dart';
import 'gallery_preview_sheet.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(galleryNotifierProvider.notifier);
    final sortMode = notifier.sortMode;
    final galleryAsync = ref.watch(galleryNotifierProvider);
    final filtered = ref.watch(filteredGalleryProvider);
    final allTags = ref.watch(allGalleryTagsProvider);
    final selectedTags = ref.watch(gallerySelectedTagsProvider);
    final query = ref.watch(gallerySearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('テンプレートギャラリー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: 'ランキング',
            onPressed: () => context.push('/ranking'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(allTags.isEmpty ? 96 : 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 検索バー
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'テンプレートを検索...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(gallerySearchQueryProvider.notifier)
                                  .state = '';
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.black.withAlpha(13),
                  ),
                  onChanged: (v) =>
                      ref.read(gallerySearchQueryProvider.notifier).state = v,
                ),
              ),
              // ソート + タグフィルタ
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  children: [
                    _sortChip(
                      label: '最新',
                      selected: sortMode == GallerySortMode.newest,
                      onTap: () => notifier.setSortMode(GallerySortMode.newest),
                    ),
                    const SizedBox(width: 6),
                    _sortChip(
                      label: '人気',
                      selected: sortMode == GallerySortMode.popular,
                      onTap: () =>
                          notifier.setSortMode(GallerySortMode.popular),
                    ),
                    if (allTags.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Container(
                          width: 1, height: 18, color: Colors.black12),
                      const SizedBox(width: 10),
                      ...allTags.map((tag) {
                        final isSelected = selectedTags.contains(tag);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _tagFilterChip(
                            label: tag,
                            selected: isSelected,
                            onTap: () {
                              final current =
                                  ref.read(gallerySelectedTagsProvider);
                              ref
                                  .read(gallerySelectedTagsProvider.notifier)
                                  .state = isSelected
                                  ? (Set.from(current)..remove(tag))
                                  : {...current, tag};
                            },
                          ),
                        );
                      }),
                    ],
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: () => notifier.refresh(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: galleryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('読み込みエラー: $e',
              style: const TextStyle(color: Colors.red)),
        ),
        data: (_) {
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.black26),
                  const SizedBox(height: 8),
                  Text(
                    query.isNotEmpty || selectedTags.isNotEmpty
                        ? '条件に一致するテンプレートがありません'
                        : 'テンプレートはまだありません',
                    style: const TextStyle(color: Colors.black38),
                  ),
                  if (query.isNotEmpty || selectedTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(gallerySearchQueryProvider.notifier).state =
                            '';
                        ref
                            .read(gallerySelectedTagsProvider.notifier)
                            .state = {};
                      },
                      child: const Text('フィルタをリセット'),
                    ),
                  ],
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => notifier.refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (context, i) => _GalleryTile(
                template: filtered[i],
                onPreview: () =>
                    showGalleryPreview(context, ref, filtered[i]),
                onImport: () =>
                    _importTemplate(context, ref, filtered[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sortChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1A1A2E) : Colors.black26,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.black54,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _tagFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.indigo : Colors.black26,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.label, size: 11, color: Colors.indigo),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.indigo : Colors.black54,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importTemplate(
    BuildContext context,
    WidgetRef ref,
    GalleryTemplate template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('テンプレートを読み込む'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('「${template.name}」をローカルに保存して開きますか？'),
            if (template.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(template.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('開く'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(galleryRepositoryProvider).incrementDownload(template.id);

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

class _GalleryTile extends ConsumerWidget {
  const _GalleryTile({
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                style:
                    const TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              ...template.layerTypes.take(3).map((t) => _chip(_label(t))),
              ...template.tags.map((tag) => _tagChip(tag)),
              _statBadge(
                icon: Icons.download_outlined,
                value: template.downloadCount,
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => ref
                .read(galleryNotifierProvider.notifier)
                .toggleLike(template.id),
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
                  style:
                      const TextStyle(fontSize: 10, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 20),
            tooltip: '読み込む',
            onPressed: onImport,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
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
          Text('$value',
              style:
                  const TextStyle(fontSize: 10, color: Colors.black38)),
        ],
      );

  String _label(String type) => const {
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
      }[type] ??
      type;
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
        child: template.thumbnailBytes != null
            ? Image.memory(
                template.thumbnailBytes!,
                fit: BoxFit.cover,
              )
            : _liveMiniPreview(),
      ),
    );
  }

  Widget _liveMiniPreview() {
    return ColoredBox(
      color: Colors.white,
      child: LayerStackPreview(
        pageConfig: template.pageConfig,
        layers: template.layers,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
