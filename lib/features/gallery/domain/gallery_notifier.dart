import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gallery_repository.dart';
import 'gallery_template.dart';

part 'gallery_notifier.g.dart';

enum GallerySortMode { newest, popular }

final galleryLikedIdsProvider =
    StateProvider<Set<String>>((_) => const {});

final gallerySearchQueryProvider = StateProvider<String>((_) => '');

final gallerySelectedTagsProvider =
    StateProvider<Set<String>>((_) => const {});

@riverpod
class GalleryNotifier extends _$GalleryNotifier {
  GallerySortMode _sortMode = GallerySortMode.newest;

  GallerySortMode get sortMode => _sortMode;

  @override
  Future<List<GalleryTemplate>> build() => _fetch();

  Future<List<GalleryTemplate>> _fetch() {
    final repo = ref.read(galleryRepositoryProvider);
    return _sortMode == GallerySortMode.newest
        ? repo.fetchLatest()
        : repo.fetchTopRanked();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> setSortMode(GallerySortMode mode) async {
    if (_sortMode == mode) return;
    _sortMode = mode;
    await refresh();
  }

  Future<void> deleteTemplate(String docId) async {
    await ref.read(galleryRepositoryProvider).deleteTemplate(docId);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.where((t) => t.id != docId).toList());
  }

  Future<void> toggleLike(String docId) async {
    final liked = ref.read(galleryLikedIdsProvider);
    final isLiked = liked.contains(docId);
    final repo = ref.read(galleryRepositoryProvider);

    final template = state.valueOrNull?.where((t) => t.id == docId).firstOrNull;
    final authorId = template?.authorId;

    // 楽観的更新（await前に即時反映）
    ref.read(galleryLikedIdsProvider.notifier).state = isLiked
        ? (Set.from(liked)..remove(docId))
        : {...liked, docId};

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current
          .map((t) => t.id == docId
              ? t.copyWith(likeCount: t.likeCount + (isLiked ? -1 : 1))
              : t)
          .toList());
    }

    if (isLiked) {
      await repo.unlikeTemplate(docId, authorId: authorId);
    } else {
      await repo.likeTemplate(docId, authorId: authorId);
    }
  }
}

// 全テンプレートから一意のタグ一覧を返す
final allGalleryTagsProvider = Provider<List<String>>((ref) {
  final templates = ref.watch(galleryNotifierProvider).valueOrNull ?? [];
  final tags = <String>{};
  for (final t in templates) {
    tags.addAll(t.tags);
  }
  final sorted = tags.toList()..sort();
  return sorted;
});

// 検索・タグフィルタ適用済みリスト
final filteredGalleryProvider = Provider<List<GalleryTemplate>>((ref) {
  final templates = ref.watch(galleryNotifierProvider).valueOrNull ?? [];
  final query = ref.watch(gallerySearchQueryProvider).toLowerCase();
  final selectedTags = ref.watch(gallerySelectedTagsProvider);

  return templates.where((t) {
    final matchSearch = query.isEmpty ||
        t.name.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query) ||
        t.tags.any((tag) => tag.toLowerCase().contains(query));
    final matchTags = selectedTags.isEmpty ||
        selectedTags.any((tag) => t.tags.contains(tag));
    return matchSearch && matchTags;
  }).toList();
});
