import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../features/profile/domain/profile_notifier.dart';
import '../data/gallery_repository.dart';
import '../domain/gallery_notifier.dart';
import '../domain/gallery_template.dart';
import 'gallery_preview_sheet.dart';
import 'gallery_tag_filter.dart';
import 'gallery_tile.dart';

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
    final viewMode = ref.watch(galleryViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('テンプレートギャラリー'),
        actions: [
          IconButton(
            icon: Icon(switch (viewMode) {
              GalleryViewMode.list  => Icons.view_list,
              GalleryViewMode.grid2 => Icons.grid_view,
              GalleryViewMode.grid4 => Icons.apps,
            }),
            tooltip: '表示切替',
            onPressed: () {
              ref.read(galleryViewModeProvider.notifier).state = switch (viewMode) {
                GalleryViewMode.list  => GalleryViewMode.grid2,
                GalleryViewMode.grid2 => GalleryViewMode.grid4,
                GalleryViewMode.grid4 => GalleryViewMode.list,
              };
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: 'ランキング',
            onPressed: () => context.push('/ranking'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              ref.read(gallerySearchQueryProvider.notifier).state = '';
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
                      onTap: () => notifier.setSortMode(GallerySortMode.popular),
                    ),
                    const SizedBox(width: 6),
                    _sortChip(
                      label: 'DL数',
                      selected: sortMode == GallerySortMode.downloads,
                      onTap: () => notifier.setSortMode(GallerySortMode.downloads),
                    ),
                    const SizedBox(width: 6),
                    _sortChip(
                      label: 'フォロー中',
                      selected: sortMode == GallerySortMode.following,
                      onTap: () => notifier.setSortMode(GallerySortMode.following),
                    ),
                    if (allTags.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Container(width: 1, height: 18, color: Colors.black12),
                      const SizedBox(width: 10),
                      ...selectedTags.map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _tagFilterChip(
                              label: tag,
                              selected: true,
                              onTap: () {
                                final current = ref.read(gallerySelectedTagsProvider);
                                ref
                                    .read(gallerySelectedTagsProvider.notifier)
                                    .state = Set.from(current)..remove(tag);
                              },
                            ),
                          )),
                      GalleryTagPickerButton(
                        allTags: allTags,
                        selectedTags: selectedTags,
                        onChanged: (tags) => ref
                            .read(gallerySelectedTagsProvider.notifier)
                            .state = tags,
                      ),
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
      body: sortMode == GallerySortMode.following
          ? _FollowingFeedBody(onImport: (t) => _importTemplate(context, ref, t))
          : galleryAsync.when(
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
                              ref.read(gallerySearchQueryProvider.notifier).state = '';
                              ref.read(gallerySelectedTagsProvider.notifier).state = {};
                            },
                            child: const Text('フィルタをリセット'),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return _buildGalleryList(context, ref, filtered, notifier, viewMode);
              },
            ),
    );
  }

  Widget _buildGalleryList(
    BuildContext context,
    WidgetRef ref,
    List<GalleryTemplate> templates,
    GalleryNotifier notifier,
    GalleryViewMode viewMode,
  ) {
    final hasMore = notifier.hasMore;

    if (viewMode == GalleryViewMode.list) {
      return RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: templates.length + (hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
          itemBuilder: (context, i) {
            if (i == templates.length) return _LoadMoreButton(onTap: () => notifier.loadMore());
            return GalleryTile(
              template: templates[i],
              onPreview: () => showGalleryPreview(context, ref, templates[i]),
              onImport: () => _importTemplate(context, ref, templates[i]),
            );
          },
        ),
      );
    }
    final crossCount = viewMode == GalleryViewMode.grid2 ? 2 : 4;
    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => GalleryGridCard(
                  template: templates[i],
                  compact: viewMode == GalleryViewMode.grid4,
                  onPreview: () => showGalleryPreview(context, ref, templates[i]),
                  onImport: () => _importTemplate(context, ref, templates[i]),
                ),
                childCount: templates.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.58,
              ),
            ),
          ),
          if (hasMore)
            SliverToBoxAdapter(child: _LoadMoreButton(onTap: () => notifier.loadMore())),
        ],
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
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('テンプレートを使うにはログインが必要です'),
          action: SnackBarAction(
            label: 'ログインする',
            onPressed: () => context.push('/login'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
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

// ── フォロー中フィード ────────────────────────────────────────────────────────

class _FollowingFeedBody extends ConsumerWidget {
  const _FollowingFeedBody({required this.onImport});
  final void Function(GalleryTemplate) onImport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnon = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
    if (isAnon) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            const Text('フォロー中の投稿を見るにはログインが必要です',
                style: TextStyle(color: Colors.black45)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: const Text('ログイン'),
            ),
          ],
        ),
      );
    }

    final feedAsync = ref.watch(followingFeedProvider);
    final viewMode = ref.watch(galleryViewModeProvider);
    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('読み込みエラー: $e', style: const TextStyle(color: Colors.red))),
      data: (templates) {
        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline, size: 48, color: Colors.black26),
                const SizedBox(height: 12),
                const Text('フォロー中のユーザーの投稿がありません',
                    style: TextStyle(color: Colors.black45)),
                const SizedBox(height: 8),
                const Text('他のユーザーのプロフィールからフォローできます',
                    style: TextStyle(fontSize: 12, color: Colors.black38)),
              ],
            ),
          );
        }
        if (viewMode == GalleryViewMode.list) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(followingFeedProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: templates.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
              itemBuilder: (ctx, i) => GalleryTile(
                template: templates[i],
                onPreview: () => showGalleryPreview(ctx, ref, templates[i]),
                onImport: () => onImport(templates[i]),
              ),
            ),
          );
        }
        final crossCount = viewMode == GalleryViewMode.grid2 ? 2 : 4;
        return RefreshIndicator(
          onRefresh: () => ref.refresh(followingFeedProvider.future),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.58,
            ),
            itemCount: templates.length,
            itemBuilder: (ctx, i) => GalleryGridCard(
              template: templates[i],
              compact: viewMode == GalleryViewMode.grid4,
              onPreview: () => showGalleryPreview(ctx, ref, templates[i]),
              onImport: () => onImport(templates[i]),
            ),
          ),
        );
      },
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton(
            onPressed: onTap,
            child: const Text('もっと見る'),
          ),
        ),
      );
}
