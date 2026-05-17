import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gallery_repository.dart';
import 'gallery_template.dart';

part 'gallery_notifier.g.dart';

enum GallerySortMode { newest, popular, downloads, following }
enum GalleryViewMode { list, grid2, grid4 }

final galleryLikedIdsProvider =
    StateProvider<Set<String>>((_) => const {});

final galleryViewModeProvider =
    StateProvider<GalleryViewMode>((_) => GalleryViewMode.list);

final gallerySearchQueryProvider = StateProvider<String>((_) => '');

final gallerySelectedTagsProvider =
    StateProvider<Set<String>>((_) => const {});

@riverpod
class GalleryNotifier extends _$GalleryNotifier {
  GallerySortMode _sortMode = GallerySortMode.newest;
  DocumentSnapshot? _lastDoc;   // ページネーションカーソル
  bool _hasMore = true;

  GallerySortMode get sortMode => _sortMode;
  bool get hasMore => _hasMore;

  @override
  Future<List<GalleryTemplate>> build() async {
    // ログイン済みならいいね状態を Firestore から復元
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      final ids = await ref.read(galleryRepositoryProvider).fetchLikedIds(user.uid);
      ref.read(galleryLikedIdsProvider.notifier).state = ids;
    }
    return _fetchFirst();
  }

  Future<List<GalleryTemplate>> _fetchFirst() async {
    _lastDoc = null;
    _hasMore = true;
    final repo = ref.read(galleryRepositoryProvider);
    final (items, cursor) = await repo.fetchPage(sortMode: _sortMode);
    _lastDoc = cursor;
    _hasMore = items.length >= 20;
    return items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchFirst);
  }

  /// 次ページを追加ロード
  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = state.valueOrNull;
    if (current == null) return;
    final repo = ref.read(galleryRepositoryProvider);
    final (items, cursor) = await repo.fetchPage(
      sortMode: _sortMode,
      startAfter: _lastDoc,
    );
    _lastDoc = cursor;
    _hasMore = items.length >= 20;
    state = AsyncData([...current, ...items]);
  }

  Future<void> setSortMode(GallerySortMode mode) async {
    if (_sortMode == mode) return;
    _sortMode = mode;
    if (mode != GallerySortMode.following) {
      await refresh();
    } else {
      state = state;
    }
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

// いいねしたテンプレート一覧
final likedTemplatesProvider =
    FutureProvider.family<List<GalleryTemplate>, String>((ref, uid) {
  return ref.read(galleryRepositoryProvider).fetchLikedTemplates(uid);
});

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
