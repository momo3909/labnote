import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/gallery_template.dart';
import '../../../shared/models/notebook_template.dart';
import '../../profile/data/user_repository.dart';

final galleryRepositoryProvider = Provider((_) => GalleryRepository());

class GalleryRepository {
  static const _col = 'gallery_templates';
  final _db = FirebaseFirestore.instance;

  Future<List<GalleryTemplate>> fetchLatest({int limit = 30}) async {
    final snap = await _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<GalleryTemplate>> fetchTopRanked({int limit = 30}) async {
    final snap = await _db
        .collection(_col)
        .orderBy('likeCount', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<GalleryTemplate>> fetchByAuthor(String uid) async {
    final snap = await _db
        .collection(_col)
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<String> publish(
    NotebookTemplate template, {
    String description = '',
    String authorName = '',
    String? authorAvatarUrl,
    List<String> tags = const [],
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonymous';
    final layerTypes =
        template.layers.map((l) => l.layerType).toSet().toList();
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
    };
    if (template.thumbnailPng != null) {
      data['thumbnailBytes'] = template.thumbnailPng!;
    }
    final ref = await _db.collection(_col).add(data);

    // テンプレート数をインクリメント
    if (uid != 'anonymous') {
      await UserRepository().incrementTemplateCount(uid);
    }

    return ref.id;
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
    await _db.collection(_col).doc(docId).update({
      'likeCount': FieldValue.increment(1),
    });
    if (authorId != null && authorId != 'anonymous') {
      await UserRepository().incrementTotalLikes(authorId);
    }
  }

  Future<void> unlikeTemplate(String docId, {String? authorId}) async {
    await _db.collection(_col).doc(docId).update({
      'likeCount': FieldValue.increment(-1),
    });
    if (authorId != null && authorId != 'anonymous') {
      await UserRepository().decrementTotalLikes(authorId);
    }
  }

  static Uint8List? _toBytes(dynamic value) {
    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is List) return Uint8List.fromList(value.cast<int>());
    return null;
  }

  GalleryTemplate _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return GalleryTemplate(
      id: doc.id,
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
      thumbnailBytes: _toBytes(d['thumbnailBytes']),
      tags: (d['tags'] as List?)?.cast<String>() ?? [],
    );
  }
}
