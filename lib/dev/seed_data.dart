import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

/// 開発用テストデータ投入
/// 設定画面の「テストデータを作成」ボタンから呼び出す
class SeedData {
  static final _db = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  static Future<void> run() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('ログインが必要です');
    await _seedTemplates(uid);
  }

  static Future<void> clean() async {
    final snap = await _db
        .collection('gallery_templates')
        .where('_isSeed', isEqualTo: true)
        .get();
    final batch = _db.batch();
    for (final d in snap.docs) batch.delete(d.reference);
    await batch.commit();
  }

  // --------------------------------------------------------------- templates
  static Future<void> _seedTemplates(String uid) async {
    final templates = [
      _template(
        authorId: uid,
        authorName: '田中 理学',
        name: '方眼 5mm（物理ノート用）',
        description: '物理の計算・図示に最適な5mm方眼。罫線は薄いグレーで見やすい。',
        tags: ['物理', '方眼'],
        layerType: 'grid',
        configJson: jsonEncode({'runtimeType': 'grid', 'cellWidthMm': 5.0, 'cellHeightMm': 5.0, 'lineStyle': 'solid', 'showHorizontal': true, 'showVertical': true}),
        likeCount: 12,
        downloadCount: 34,
      ),
      _template(
        authorId: 'seed_uid_1',
        authorName: '田中 理学',
        name: '極座標グラフ用紙',
        description: '波動関数・ベクトルの角度依存性を描くのに便利。',
        tags: ['物理', '数学', '極座標'],
        layerType: 'polar',
        configJson: jsonEncode({'runtimeType': 'polar', 'rings': 8, 'sectors': 12}),
        likeCount: 8,
        downloadCount: 19,
      ),
      _template(
        authorId: uid,
        authorName: 'Yuki Chem',
        name: '原稿用紙 400字（化学反応式)',
        description: '化学反応式・構造式の記述に。20×20マスで書きやすい。',
        tags: ['化学', '原稿用紙'],
        layerType: 'manuscript',
        configJson: jsonEncode({'runtimeType': 'manuscript', 'columns': 20, 'rows': 20}),
        likeCount: 5,
        downloadCount: 11,
      ),
      _template(
        authorId: uid,
        authorName: 'Yuki Chem',
        name: '六角形グリッド（分子モデル用）',
        description: '有機化学の構造式を書くときに便利。',
        tags: ['化学', '六角形'],
        layerType: 'hex',
        configJson: jsonEncode({'runtimeType': 'hex', 'hexSizeMm': 8.0, 'orientation': 'flat'}),
        likeCount: 7,
        downloadCount: 15,
      ),
      _template(
        authorId: uid,
        authorName: '数学好き',
        name: '両対数グラフ用紙',
        description: 'べき乗則・スケーリング則の解析に。x/y両軸対数スケール。',
        tags: ['数学', '対数', 'グラフ'],
        layerType: 'logGrid',
        configJson: jsonEncode({'runtimeType': 'logGrid', 'xScale': 'log', 'yScale': 'log', 'xDecades': 3, 'yDecades': 3}),
        likeCount: 15,
        downloadCount: 42,
      ),
      _template(
        authorId: uid,
        authorName: '数学好き',
        name: 'コーネル式ノート（数学演習）',
        description: '左に公式・右に計算・下にまとめ。数学演習に最適。',
        tags: ['数学', 'コーネル', '演習'],
        layerType: 'cornell',
        configJson: jsonEncode({'runtimeType': 'cornell', 'leftColMm': 45.0, 'bottomRowMm': 30.0, 'lineSpacingMm': 7.0}),
        likeCount: 11,
        downloadCount: 28,
      ),
      _template(
        authorId: uid,
        authorName: '数学好き',
        name: '等角投影グリッド（立体図示）',
        description: '立方体・結晶構造などの3D図示に。',
        tags: ['数学', '物理', '等角'],
        layerType: 'isometric',
        configJson: jsonEncode({'runtimeType': 'isometric', 'spacingMm': 6.0}),
        likeCount: 9,
        downloadCount: 21,
      ),
      _template(
        authorId: uid,
        authorName: 'Bio_Notes',
        name: '週間実験タイムテーブル',
        description: '実験スケジュール管理用。月〜金の時間割形式。',
        tags: ['生物', '時間割', '実験'],
        layerType: 'timetable',
        configJson: jsonEncode({'runtimeType': 'timetable', 'startHour': 8, 'endHour': 20, 'daysCount': 5}),
        likeCount: 4,
        downloadCount: 8,
      ),
      _template(
        authorId: uid,
        authorName: 'Bio_Notes',
        name: 'ドットグリッド（汎用ノート）',
        description: 'すっきりしたドットグリッド。図・文字どちらも書きやすい。',
        tags: ['汎用', 'ドット'],
        layerType: 'dot',
        configJson: jsonEncode({'runtimeType': 'dot', 'spacingMm': 5.0, 'dotRadiusMm': 0.5}),
        likeCount: 18,
        downloadCount: 55,
      ),
      _template(
        authorId: 'seed_uid_1',
        authorName: '田中 理学',
        name: '片対数グラフ（時定数解析）',
        description: 'RC回路・放射性崩壊など指数関数的変化の解析に。',
        tags: ['物理', '対数', 'グラフ'],
        layerType: 'logGrid',
        configJson: jsonEncode({'runtimeType': 'logGrid', 'xScale': 'linear', 'yScale': 'log', 'xDecades': 3, 'yDecades': 3}),
        likeCount: 6,
        downloadCount: 17,
      ),
    ];

    final batch = _db.batch();
    for (final t in templates) {
      final ref = _db.collection('gallery_templates').doc();
      batch.set(ref, t);
    }
    await batch.commit();
  }

  static Map<String, dynamic> _template({
    required String authorId,
    required String authorName,
    required String name,
    required String description,
    required List<String> tags,
    required String layerType,
    required String configJson,
    required int likeCount,
    required int downloadCount,
  }) {
    final layerEntity = jsonEncode({
      'uuid': _uuid.v4(),
      'sortOrder': 0,
      'isVisible': true,
      'opacity': 1.0,
      'colorHex': '#CCCCCC',
      'layerType': layerType,
      'configJson': configJson,
      'xRatio': 0.0,
      'yRatio': 0.0,
      'widthRatio': 1.0,
      'heightRatio': 1.0,
    });

    final pageConfig = jsonEncode({
      'paperSize': 'a4',
      'orientation': 'portrait',
      'marginTopMm': 10.0,
      'marginBottomMm': 10.0,
      'marginLeftMm': 10.0,
      'marginRightMm': 10.0,
      'holeConfig': 'none',
      'showPageNumber': false,
      'showLineNumbers': false,
    });

    return {
      'name': name,
      'authorId': authorId,
      'authorName': authorName,
      'description': description,
      'tags': tags,
      'layerTypes': [layerType],
      'layersJson': [layerEntity],
      'pageConfigJson': pageConfig,
      'likeCount': likeCount,
      'downloadCount': downloadCount,
      'createdAt': FieldValue.serverTimestamp(),
      '_isSeed': true,
    };
  }
}
