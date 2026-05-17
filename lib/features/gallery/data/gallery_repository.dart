import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/gallery_comment.dart';
import '../domain/gallery_notifier.dart' show GallerySortMode;
import '../domain/gallery_template.dart';
import '../../../shared/models/notebook_template.dart';
import '../../profile/data/user_repository.dart';

final galleryRepositoryProvider = Provider((_) => GalleryRepository());

class GalleryRepository {
  static const _col = 'gallery_templates';
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<List<GalleryTemplate>> fetchLatest({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var q = _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<GalleryTemplate>> fetchTopRanked({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var q = _db
        .collection(_col)
        .orderBy('likeCount', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<GalleryTemplate>> fetchTopDownloaded({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var q = _db
        .collection(_col)
        .orderBy('downloadCount', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap.docs.map(_fromDoc).toList();
  }

  // カーソル付き fetch（ページネーション用）
  Future<(List<GalleryTemplate>, DocumentSnapshot?)> fetchPage({
    required GallerySortMode sortMode,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final String orderField = switch (sortMode) {
      GallerySortMode.newest    => 'createdAt',
      GallerySortMode.popular   => 'likeCount',
      GallerySortMode.downloads => 'downloadCount',
      GallerySortMode.following => 'createdAt',
    };
    var q = _db
        .collection(_col)
        .orderBy(orderField, descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    final docs = snap.docs;
    final cursor = docs.isNotEmpty ? docs.last : null;
    return (docs.map(_fromDoc).toList(), cursor);
  }

  Future<GalleryTemplate?> fetchById(String docId) async {
    final doc = await _db.collection(_col).doc(docId).get();
    if (!doc.exists || doc.data() == null) return null;
    return _fromData(doc.id, doc.data()!);
  }

  Future<List<GalleryTemplate>> fetchByAuthor(String uid) async {
    final snap = await _db
        .collection(_col)
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  // ── コメント ─────────────────────────────────────────────────────────────

  Future<List<GalleryComment>> fetchComments(String docId) async {
    final snap = await _db
        .collection(_col)
        .doc(docId)
        .collection('comments')
        .orderBy('createdAt')
        .get();
    return snap.docs.map(_commentFromDoc).toList();
  }

  Future<void> addComment(
    String docId,
    String text, {
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
  }) async {
    await _db.collection(_col).doc(docId).collection('comments').add({
      'authorId': authorId,
      'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(String docId, String commentId) async {
    await _db
        .collection(_col)
        .doc(docId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // ── フォロー中フィード ─────────────────────────────────────────────────────

  Future<List<GalleryTemplate>> fetchByFollowing(
    List<String> authorUids, {
    int limit = 40,
  }) async {
    if (authorUids.isEmpty) return [];
    // whereIn は最大 30 件
    final chunk = authorUids.take(30).toList();
    final snap = await _db
        .collection(_col)
        .where('authorId', whereIn: chunk)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  // ── 公開 ─────────────────────────────────────────────────────────────────

  Future<String> publish(
    NotebookTemplate template, {
    String description = '',
    String authorName = '',
    String? authorAvatarUrl,
    List<String> tags = const [],
    String? originalId,
    String? originalName,
    String? originalAuthorName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonymous';
    final layerTypes =
        template.layers.map((l) => l.layerType).toSet().toList();

    // 先に Firestore doc を作成して ID を確定させる
    final ref = _db.collection(_col).doc();

    // サムネイルを Storage にアップロード（失敗してもサムネなしで続行）
    String? thumbnailUrl;
    if (template.thumbnailPng != null) {
      try {
        thumbnailUrl = await _uploadThumbnail(ref.id, template.thumbnailPng!);
      } catch (_) {}
    }

    final data = {
      'name': template.name,
      'authorId': uid,
      'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      'description': description,
      'pageConfigJson': template.pageConfigJson,
      'layersJson': template.layersJson,
      'layerTypes': layerTypes,
      'tags': tags,
      'downloadCount': 0,
      'likeCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (originalId != null) 'originalId': originalId,
      if (originalName != null) 'originalName': originalName,
      if (originalAuthorName != null) 'originalAuthorName': originalAuthorName,
    };
    await ref.set(data);

    if (uid != 'anonymous') {
      await UserRepository().incrementTemplateCount(uid);
    }

    return ref.id;
  }

  Future<void> updatePublished(
    String docId,
    NotebookTemplate template, {
    String description = '',
    List<String> tags = const [],
  }) async {
    final layerTypes = template.layers.map((l) => l.layerType).toSet().toList();

    String? thumbnailUrl;
    if (template.thumbnailPng != null) {
      try {
        thumbnailUrl = await _uploadThumbnail(docId, template.thumbnailPng!);
      } catch (_) {}
    }

    final data = <String, dynamic>{
      'name': template.name,
      'description': description,
      'tags': tags,
      'layerTypes': layerTypes,
      'layersJson': template.layersJson,
      'pageConfigJson': template.pageConfigJson,
      'updatedAt': FieldValue.serverTimestamp(),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
    await _db.collection(_col).doc(docId).update(data);
  }

  Future<String?> _uploadThumbnail(String docId, Uint8List bytes) async {
    if (bytes.length > 4 * 1024 * 1024) return null; // 4MB超はスキップ
    final ref = _storage
        .ref()
        .child('gallery_thumbnails')
        .child('$docId.png');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
    return await ref.getDownloadURL();
  }

  Future<void> incrementDownload(String docId) async {
    await _db.collection(_col).doc(docId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteTemplate(String docId) async {
    // authorId を取得してテンプレート数をデクリメント
    final doc = await _db.collection(_col).doc(docId).get();
    final authorId = doc.data()?['authorId'] as String?;
    await _db.collection(_col).doc(docId).delete();
    if (authorId != null && authorId != 'anonymous') {
      await UserRepository().decrementTemplateCount(authorId);
    }
  }

  Future<void> likeTemplate(String docId, {String? authorId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final batch = _db.batch();
    batch.update(_db.collection(_col).doc(docId), {'likeCount': FieldValue.increment(1)});
    if (uid != null) {
      batch.set(
        _db.collection('users').doc(uid).collection('liked').doc(docId),
        {'createdAt': FieldValue.serverTimestamp()},
      );
    }
    await batch.commit();
    if (authorId != null && authorId != 'anonymous') {
      await UserRepository().incrementTotalLikes(authorId);
    }
  }

  Future<void> unlikeTemplate(String docId, {String? authorId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final batch = _db.batch();
    batch.update(_db.collection(_col).doc(docId), {'likeCount': FieldValue.increment(-1)});
    if (uid != null) {
      batch.delete(
        _db.collection('users').doc(uid).collection('liked').doc(docId),
      );
    }
    await batch.commit();
    if (authorId != null && authorId != 'anonymous') {
      await UserRepository().decrementTotalLikes(authorId);
    }
  }

  /// いいねしたテンプレートID一覧（セッション復元用）
  Future<Set<String>> fetchLikedIds(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('liked').get();
    return snap.docs.map((d) => d.id).toSet();
  }

  /// いいねしたテンプレート一覧
  Future<List<GalleryTemplate>> fetchLikedTemplates(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('liked')
        .orderBy('createdAt', descending: true)
        .get();
    if (snap.docs.isEmpty) return [];
    final ids = snap.docs.map((d) => d.id).toList();
    // whereIn は 30 件上限のためチャンク処理
    final results = <GalleryTemplate>[];
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, (i + 30).clamp(0, ids.length));
      final tSnap = await _db
          .collection(_col)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(tSnap.docs.map(_fromDoc));
    }
    return results;
  }

  static Uint8List? _toBytes(dynamic value) {
    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is List) return Uint8List.fromList(value.cast<int>());
    return null;
  }

  GalleryTemplate _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _fromData(doc.id, doc.data());

  GalleryTemplate _fromData(String id, Map<String, dynamic> d) {
    return GalleryTemplate(
      id: id,
      name: d['name'] as String? ?? '(無題)',
      authorId: d['authorId'] as String? ?? '',
      authorName: d['authorName'] as String? ?? '',
      authorAvatarUrl: d['authorAvatarUrl'] as String?,
      description: d['description'] as String? ?? '',
      layerTypes: (d['layerTypes'] as List?)?.cast<String>() ?? [],
      downloadCount: (d['downloadCount'] as num?)?.toInt() ?? 0,
      likeCount: (d['likeCount'] as num?)?.toInt() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pageConfigJson: d['pageConfigJson'] as String,
      layersJson: (d['layersJson'] as List).cast<String>(),
      thumbnailUrl: d['thumbnailUrl'] as String?,
      thumbnailBytes: _toBytes(d['thumbnailBytes']), // 旧ドキュメント後方互換
      tags: (d['tags'] as List?)?.cast<String>() ?? [],
      originalId: d['originalId'] as String?,
      originalName: d['originalName'] as String?,
      originalAuthorName: d['originalAuthorName'] as String?,
    );
  }

  GalleryComment _commentFromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return GalleryComment(
      id: doc.id,
      authorId: d['authorId'] as String? ?? '',
      authorName: d['authorName'] as String? ?? '',
      authorAvatarUrl: d['authorAvatarUrl'] as String?,
      text: d['text'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
