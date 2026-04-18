# LabNote — 理系大学生向けノート設計アプリ 開発計画

## Context

理系大学生〜大学院生（化学・生命科学・電気電子・数学・製図など）向けに、
紙ノートのレイアウトを設計してPDFで印刷できるiPhone/iPadアプリ。
既存のノートでは実現できない「用途最適化されたレイアウト」を提供する。
競合（GoodNotes等）が対応しない理系特化テンプレートで差別化する。
個人開発・3ヶ月以内・Flutter・オフライン完結でMVPをリリースする。

---

## 技術スタック

| 項目 | 採用技術 | 理由 |
|------|----------|------|
| フレームワーク | Flutter 3.x | iOS/Android両対応、個人開発に向く |
| PDF生成 | `pdf` パッケージ (dart-pdf) | Flutter向け最有力、高精度 |
| ローカル保存 | `hive` または `isar` | 軽量・高速なローカルDB |
| 状態管理 | `riverpod` | 個人開発でのベストプラクティス |
| キャンバス描画 | Flutter CustomPainter | グリッド・図形のカスタム描画 |
| バックエンド | なし（端末内完結） | MVP期間内に現実的 |
| 課金管理 | `purchases_flutter`（RevenueCat） | Apple/Google両対応・レシート検証不要 |

---

## MVP スコープ（3ヶ月以内）

### 含める機能

1. **グリッド設計**
   - 1mm単位でのグリッド幅調整（縦横独立設定）
   - 実線・点線の切替
   - プレビュー表示（実寸スケール）

2. **プリセットテンプレート（5種）**
   - 方眼ノート（数学・物理用）
   - 化学ノート（ベンゼン環テンプレ含む六角形グリッド）
   - 計算用紙（広い余白＋行番号）
   - 製図用紙（アイソメトリックグリッド）
   - 実験ノート（日付・条件・結果欄）

3. **PDF出力**
   - 用紙サイズ：A4 / B5
   - 余白調整（穴位置対応：26穴 / 30穴）
   - 1ページ or 複数ページ出力
   - iOS共有シート経由で印刷・保存

4. **カスタム保存・再利用**
   - 作成したデザインをローカル保存
   - テンプレート一覧から再編集・再出力

5. **化学特化（MVP簡易版）**
   - 六角形グリッドプリセット
   - 結合角ガイド（60° / 109.5° / 120°）表示

### 含めない機能（v2以降）

- コミュニティ・テンプレート共有
- クラウド保存・同期
- 両面印刷ズレ補正の自動計算
- レイヤー機能の高度なUI

---

## 課金設計

### プラン構成

| 機能 | 無料 | Pro |
|------|------|-----|
| テンプレート | 方眼・横罫・ドット（3種） | 全5種＋化学特化 |
| PDF出力 | 1ページのみ | 複数ページ・冊子化 |
| カスタム保存 | 3件まで | 無制限 |
| グリッド細かさ | 5mm / 10mm のみ | 1mm単位自由設定 |
| 化学ガイド | なし | 六角形・結合角ガイド |

### 価格

| プラン | 価格 | 備考 |
|--------|------|------|
| 月額 | ¥200/月 | コンビニ1回分。迷わず払える水準 |
| 年額 | ¥1,200/年 | 月換算¥100。「2ヶ月無料」として訴求 |
| 無料トライアル | 7日間 | 全機能開放 → 終了後に制限復活が最強の購入動機 |

### ペイウォール発火ロジック

```
【ハードブロック】制限に当たった瞬間に表示
  - 保存4件目を作成しようとしたとき
  - 2ページ目のPDF出力を押したとき
  - グリッドを1mm単位に変更しようとしたとき

【ソフトプロンプト】成功体験の直後に柔らかく訴求
  - PDF出力完了直後 → 「複数ページも一括出力できます」バナー
  - アプリ3回目起動時にホームにバナー表示

【絶対にやらないこと】
  - 起動時の強制表示
  - 短期間での連続ポップアップ（学生は即アンインストール）
```

### 実装方針

- **パッケージ**: `purchases_flutter`（RevenueCat）
  - Apple / Google 両対応を1ライブラリで管理
  - レシート検証・サブスク状態管理をサーバーレスで処理
  - 無料枠内（月間売上 $2,500 未満）で運用可能

```dart
// 制限チェックの例
final customerInfo = await Purchases.getCustomerInfo();
final isPro = customerInfo.entitlements.active.containsKey('pro');
if (!isPro && savedCount >= 3) {
  showPaywallModal(context);
  return;
}
```

- `EntitlementProvider`（Riverpod）でPro状態をグローバル管理
- 各制限箇所は `ref.watch(entitlementProvider)` で判定し、UIに直接反映

---

## 画面設計

### ナビゲーション構造（TabBar）

```
TabBar（下部）
├── [ホーム]     → テンプレート選択・新規作成
├── [保存済み]   → カスタムテンプレート一覧
└── [設定]       → 用紙デフォルト・プラン管理
```

### 1. ホーム画面

```
┌─────────────────────────────┐
│  NotePrint                  │
│                             │
│  ── テンプレート ──          │
│  ┌───────┐┌───────┐┌──────┐ │
│  │ ▦    ││  ⬡   ││  /  │ │
│  │ 方眼 ││ 化学 ││ 製図 │ │
│  └───────┘└──🔒──┘└──🔒──┘ │
│  ┌───────┐┌───────┐         │
│  │ ≡    ││ ⊞    │         │
│  │ 計算 ││ 実験 │         │
│  └───────┘└──🔒──┘         │
│                             │
│  ── 保存済み ──              │
│  ┌─────────────────────────┐│
│  │ ▦  有機化学ノート   › ││
│  │ ⬡  反応式レイアウト › ││
│  │ ▦  線形代数用紙  🔒 › ││
│  └─────────────────────────┘│
│                             │
│         [ + 新規作成 ]      │
└─────────────────────────────┘
```

- 🔒 = Pro限定。タップするとペイウォールモーダル
- 保存済み3件超えはグレーアウト＋🔒表示

### 2. エディタ画面

```
┌─────────────────────────────┐
│ ←  方眼ノート        [保存] │
├─────────────────────────────┤
│                             │
│   ┌─────────────────────┐   │
│   │ · · · · · · · · · │   │
│   │ · · · · · · · · · │   │
│   │ · · · · · · · · · │   │
│   │ · · · · · · · · · │   │
│   │ · · · · · · · · · │   │
│   └─────────────────────┘   │
│       A4・5mm・実線          │
│                             │
├─────────────────────────────┤
│  グリッド幅   ●──────  5mm  │
│  縦 / 横     [連動 ▼]      │
│  線種        [実線 ▼]      │
│  用紙        [A4   ▼]      │
│  余白        [26穴 ▼]      │
│  [レイヤー編集]             │
│        [  PDF 出力  ]       │
└─────────────────────────────┘
```

- スライダー操作でリアルタイムプレビュー更新
- 「レイヤー編集」からレイヤー追加・表示切替

### 3. レイヤー編集パネル（拡張機能）

```
┌─────────────────────────────┐
│  レイヤー                   │
├─────────────────────────────┤
│  👁 ▦  方眼グリッド  5mm    │
│  👁 ⬡  化学ガイド  [🔒Pro]  │
│  👁 ─  罫線スペース         │
│                             │
│       [ + レイヤー追加 ]    │
└─────────────────────────────┘
```

- 複数レイヤーを重ねて「方眼＋化学式スペース」など組み合わせ可能
- 表示/非表示トグル（👁）
- ドラッグで重ね順変更

### 4. ペイウォールモーダル

```
┌─────────────────────────────┐
│                          ✕  │
│                             │
│     ⬡ ▦ /                  │
│                             │
│  この機能は Pro プランです   │
│                             │
│  ✓ 全テンプレート           │
│  ✓ 複数ページ PDF 出力      │
│  ✓ グリッド 1mm 単位調整    │
│  ✓ レイヤー組み合わせ       │
│  ✓ カスタム保存 無制限      │
│                             │
│  ┌─────────────────────────┐│
│  │   7日間 無料で試す      ││
│  └─────────────────────────┘│
│  ┌───────────────┐┌────────┐│
│  │  ¥200 / 月   ││¥1,200 ││
│  │              ││ / 年  ││
│  └───────────────┘└────────┘│
│    利用規約  ・  復元       │
└─────────────────────────────┘
```

### 5. 保存済みテンプレート一覧

```
┌─────────────────────────────┐
│  保存済みテンプレート        │
├─────────────────────────────┤
│  ▦  有機化学ノート           │
│     A4・5mm×10mm・実線      │
│     2026/04/15          [›] │
├─────────────────────────────┤
│  ⬡  反応式レイアウト         │
│     A4・六角形＋罫線         │
│     2026/04/10          [›] │
├─────────────────────────────┤
│  ▦  線形代数用紙  🔒         │
│     B5・1mm・実線            │
│     2026/04/08          [›] │
└─────────────────────────────┘
│  ⚠ 無料: 3件まで             │
│  [  Pro にアップグレード  ]  │
└─────────────────────────────┘
```

---

## 開発スケジュール（3ヶ月）

| 週 | 作業内容 |
|----|----------|
| 1-2週 | プロジェクト構成・freezed/isar/riverpod_generator導入・LayerConfigモデル定義 |
| 3-4週 | GridLayerPainter（CustomPainter）＋GridLayerPdfRenderer実装・プレビュー確認 |
| 5-6週 | PageConfig・Isarスキーマ確定・保存/読み込みRepository実装 |
| 7-8週 | HexLayer / IsometricLayer / RegionLayer 実装（Painter＋PdfRendererセット） |
| 9-10週 | ホーム・エディタ・保存一覧画面UI・go_routerルーティング |
| 11週 | RevenueCat連携・EntitlementNotifier・ペイウォールモーダル |
| 12週 | UI磨き・レイヤーパネル・バグ修正・TestFlight提出 |

---

## アーキテクチャ方針（Flutter ベストプラクティス）

### フォルダ構成（Feature-first + Clean Architecture）

```
lib/
├── main.dart
├── core/
│   ├── constants/         # 用紙サイズ定数、mmPx変換
│   ├── extensions/        # BuildContext, Color拡張
│   ├── router/            # go_router ルーティング定義
│   └── theme/             # AppTheme（ミニマル・グレー系）
├── features/
│   ├── editor/
│   │   ├── data/          # EditorRepository（Isar読み書き）
│   │   ├── domain/        # TemplateNotifier, LayerNotifier
│   │   └── presentation/  # EditorScreen, BottomSheet, LayerPanel
│   ├── templates/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # HomeScreen, SavedListScreen
│   ├── export/
│   │   ├── domain/        # PdfRenderer（dart-pdf）
│   │   └── presentation/  # ExportButton, PageCountPicker
│   └── paywall/
│       ├── domain/        # EntitlementNotifier（RevenueCat）
│       └── presentation/  # PaywallModal, ProBadge
└── shared/
    ├── models/            # sealed class Layer, PageConfig, etc.
    ├── painters/          # CustomPainter実装（レイヤー別）
    └── widgets/           # 共通ウィジェット
```

### 採用するFlutterベストプラクティス

| 項目 | 採用 | 理由 |
|------|------|------|
| 状態管理 | `riverpod` + `AsyncNotifier` | テスト可能・DI容易 |
| イミュータブルモデル | `freezed` | コピー・比較・シリアライズを自動生成 |
| ローカルDB | `isar` | 高速・型安全・スキーマ管理がHiveより優秀 |
| ルーティング | `go_router` | 宣言的・Deep Link対応 |
| PDF生成 | `pdf` + `printing` | プレビューと印刷を同一APIで処理 |
| コード生成 | `build_runner` | freezed/isar/riverpod_generatorと連携 |
| 課金 | `purchases_flutter` | RevenueCat iOS/Android統合 |

---

## データモデル（DB構造）

### 設計思想：レイヤーの合成でテンプレートを表現

テンプレートは「ページ設定」＋「複数レイヤーのスタック」で構成する。
新しい領域（製図・工学・生物など）はレイヤー型を追加するだけで拡張できる。
将来の掲示板共有に備え、UUIDとDTO層を最初から分離する。

```
NotebookTemplate（Isar ローカル）
│
├── PageConfig（用紙・余白・穴位置）
│
└── List<Layer>（重ね合わせ）
     ├── GridLayer      ← 方眼・罫線・ドット
     ├── HexLayer       ← 化学（ベンゼン環）
     ├── IsometricLayer ← 製図（アイソ）
     ├── RegionLayer    ← ページを領域分割（方眼＋式スペースなど）
     └── GuideLayer     ← 結合角・座標軸など補助線

共有フロー（v2以降）
  Isar Entity  →  toDto()  →  TemplateDto  →  toJson()  →  API/Firestore
  Isar Entity  ←  toEntity()  ←  TemplateDto  ←  fromJson()  ←  API
```

### Isarスキーマ定義（freezed + isar）

```dart
// ① テンプレート本体
@collection
class NotebookTemplate {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;              // UUID v4 — リモートIDと共用・衝突なし

  late String name;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isPinned = false;
  List<String> tags = [];

  // 共有用フィールド（v1はすべてnull/false。スキーマ変更なしで対応可）
  String? authorId;              // ログインユーザーID
  bool isPublic = false;         // 公開フラグ
  String? remoteId;              // Firestore/Supabase側のdoc ID
  int downloadCount = 0;         // ローカルキャッシュ用

  final pageConfig = IsarLink<PageConfigEntity>();
  final layers = IsarLinks<LayerEntity>();
}

// ② ページ設定
@collection
class PageConfigEntity {
  Id id = Isar.autoIncrement;
  @enumerated late PaperSize paperSize;   // a4 / b5
  @enumerated late Orientation orientation;
  double marginTopMm = 10;
  double marginBottomMm = 10;
  double marginLeftMm = 20;              // 穴側
  double marginRightMm = 10;
  @enumerated late HoleConfig holeConfig; // none / h26 / h30
  int pageCount = 1;
}

// ③ レイヤー（sealed classをJSON化して保存）
@collection
class LayerEntity {
  Id id = Isar.autoIncrement;
  int sortOrder = 0;
  bool isVisible = true;
  double opacity = 1.0;
  late String colorHex;
  late String layerType;   // 'grid'|'hex'|'isometric'|'region'|'guide'
  late String configJson;  // 型別設定をJSONで保存（拡張性確保）
}
```

### レイヤー型の定義（freezed sealed class）

```dart
@freezed
sealed class LayerConfig with _$LayerConfig {
  // 方眼・罫線・ドット
  const factory LayerConfig.grid({
    required double cellWidthMm,
    required double cellHeightMm,
    required LineStyle lineStyle,
    int? boldEvery,        // N行ごとに太線
  }) = GridLayerConfig;

  // 化学：六角形グリッド
  const factory LayerConfig.hex({
    required double hexSizeMm,
    required HexOrientation orientation, // flat / pointy
  }) = HexLayerConfig;

  // 製図：アイソメトリック
  const factory LayerConfig.isometric({
    required double spacingMm,
  }) = IsometricLayerConfig;

  // 領域分割（方眼＋化学式スペース等の組み合わせに使用）
  const factory LayerConfig.region({
    required List<PageRegion> regions,
  }) = RegionLayerConfig;

  // 補助線（座標軸・結合角・罫線マージン）
  const factory LayerConfig.guide({
    required GuideType guideType,
    Map<String, dynamic>? params,
  }) = GuideLayerConfig;
}

// 領域定義（ページをN分割して異なるグリッドを適用）
@freezed
class PageRegion with _$PageRegion {
  const factory PageRegion({
    required double xRatio,     // 0.0〜1.0
    required double yRatio,
    required double widthRatio,
    required double heightRatio,
    required LayerConfig layerConfig,
  }) = _PageRegion;
}
```

### DTO層（共有・API転送用）

`IsarLink` はDB内部参照なのでネットワーク転送不可。
DTO（純粋なDartクラス）を介することで、ローカルDBとリモートAPIを完全分離する。

```dart
// TemplateDto — JSON直列化可能。Isarに依存しない
@freezed
class TemplateDto with _$TemplateDto {
  const factory TemplateDto({
    required String uuid,
    required String name,
    required String authorId,
    required PageConfigDto pageConfig,
    required List<LayerDto> layers,
    required List<String> tags,
    required DateTime createdAt,
    @Default(0) int downloadCount,
    @Default(0) int likeCount,
  }) = _TemplateDto;

  factory TemplateDto.fromJson(Map<String, dynamic> json)
      => _$TemplateDtoFromJson(json);
}

// LayerDto — layerType と configJson をそのまま転送
@freezed
class LayerDto with _$LayerDto {
  const factory LayerDto({
    required String uuid,
    required int sortOrder,
    required bool isVisible,
    required double opacity,
    required String colorHex,
    required String layerType,
    required String configJson,   // LayerConfig.toJson() と同一形式
  }) = _LayerDto;

  factory LayerDto.fromJson(Map<String, dynamic> json)
      => _$LayerDtoFromJson(json);
}
```

### リモートDB構造（v2以降：Firestore）

```
shared_templates/{uuid}
  uuid:               "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  name:               "有機化学ノート"
  authorId:           "user_abc"
  pageConfig:         { paperSize: "a4", marginLeftMm: 20, ... }
  layers:             [ { layerType: "hex", configJson: "..." }, ... ]
  tags:               ["有機化学", "化学"]
  likeCount:          42      ← 全期間ランキング用
  weeklyLikeCount:    12      ← 週間ランキング用（Cloud Functionsで毎週リセット）
  monthlyLikeCount:   30      ← 月間ランキング用（Cloud Functionsで毎月リセット）
  downloadCount:      120
  createdAt:          timestamp

  likes/{userId}              ← サブコレクション（重複いいね防止＋期間集計の根拠）
    likedAt: timestamp

users/{userId}
  displayName:        "..."
  likedTemplates:     ["uuid1", "uuid2"]  ← クライアント側の即時UI反映用キャッシュ
```

### ランキング種別と実装方針

| 種別 | クエリ | 集計方法 |
|------|--------|---------|
| 全期間 | `orderBy('likeCount', desc)` | いいね時に `FieldValue.increment(1)` |
| 週間 | `orderBy('weeklyLikeCount', desc)` | Cloud Functionsで毎週月曜0時にリセット |
| 月間 | `orderBy('monthlyLikeCount', desc)` | Cloud Functionsで毎月1日0時にリセット |

### いいね処理（Firestoreトランザクション）

競合による二重カウントを防ぐため、いいね操作は必ずトランザクションで行う。

```dart
Future<void> likeTemplate(String uuid, String userId) async {
  final templateRef = firestore.collection('shared_templates').doc(uuid);
  final likeRef = templateRef.collection('likes').doc(userId);

  await firestore.runTransaction((tx) async {
    final likeSnap = await tx.get(likeRef);
    if (likeSnap.exists) return; // 重複いいね防止

    tx.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
    tx.update(templateRef, {
      'likeCount':        FieldValue.increment(1),
      'weeklyLikeCount':  FieldValue.increment(1),
      'monthlyLikeCount': FieldValue.increment(1),
    });
  });
}
```

### Firestoreインデックス（要作成）

ランキングクエリに必要な複合インデックス：

```
Collection: shared_templates
  Fields: likeCount DESC, createdAt DESC        ← 全期間ランキング
  Fields: weeklyLikeCount DESC, createdAt DESC  ← 週間ランキング
  Fields: monthlyLikeCount DESC, createdAt DESC ← 月間ランキング
```

### レイヤー合成の拡張例（v2以降も同じ構造で対応）

| テンプレート | レイヤー構成 |
|------------|------------|
| 方眼ノート | GridLayer（5mm） |
| 化学ノート | HexLayer ＋ RegionLayer（式スペース） |
| 製図用紙 | IsometricLayer ＋ GuideLayer（スケール枠） |
| 数学証明 | GridLayer ＋ RegionLayer（思考欄／解答欄） |
| 実験ノート | RegionLayer（日付欄・条件欄・グラフ欄） |
| **組み合わせ（将来）** | GridLayer ＋ HexLayer（上半分方眼＋下半分化学） |

### CustomPainter ↔ PDF レンダラーの一致保証

```
LayerConfig
    │
    ├── LayerPainter（CustomPainter）  → 画面プレビュー
    └── LayerPdfRenderer（dart-pdf）   → PDF出力
```

同一の `LayerConfig` を受け取る2つのレンダラーを実装し、
プレビューと印刷の見た目を完全一致させる。
新しいレイヤー型追加時は Painter と PdfRenderer を1セット追加するだけ。

---

## 認証設計

### 方針：v1は匿名認証・v2で実名認証へ昇格

v1でFirebase匿名認証を裏で自動発行しておくことで、v2移行時にテンプレートデータを
ユーザーアカウントへ紐付けたまま移行できる。ユーザーは認証の存在を意識しない。

```
v1（MVP）
  アプリ起動 → Firebase匿名認証を自動発行（ユーザーには非表示）
  → anonymousUid をローカルに保持
  → NotebookTemplate.authorId = anonymousUid で保存

v2（掲示板実装時）
  「テンプレートを公開する」ボタンを押す
  → 「共有にはアカウントが必要です」モーダル表示
  → Apple / Google / メール でサインイン
  → 匿名アカウントに実名アカウントをリンク（Firebase credential linking）
  → authorId はそのまま引き継がれ、過去テンプレートも紐付き維持
```

### ログイン方法

| 方法 | 対応バージョン | 備考 |
|------|--------------|------|
| 匿名認証 | v1〜 | 自動・ユーザー操作なし |
| Apple でサインイン | v2〜 | **App Storeガイドライン上、ソーシャルログインを提供する場合は必須** |
| Google でサインイン | v2〜 | Android・Gmail ユーザー向け |
| メール＋パスワード | v2〜 | 全ユーザー対応 |

### 認証バックエンド：Firebase Auth

- `firebase_auth` + `google_sign_in` + `sign_in_with_apple` パッケージで対応
- 将来 Firestore（掲示板DB）と同一プロジェクトで運用できる
- 無料枠：MAU 10,000まで無料

### コード設計：AuthRepository インターフェースを今から定義

v1でも AuthRepository を抽象化しておくことで、v2で実装を差し込むだけで済む。

```dart
// domain層に定義（v1から存在。v1はAnonymousAuthRepositoryを注入）
abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithApple();
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  Future<void> linkWithApple();   // 匿名→実名アカウント昇格
  Future<void> linkWithGoogle();
}

// AppUser — アプリ内のユーザーモデル（Firebase Userをラップ）
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    String? displayName,
    String? email,
    @Default(false) bool isAnonymous,
  }) = _AppUser;
}
```

```dart
// v1: 自動匿名サインイン（main.dartで起動時に実行）
final user = await ref.read(authRepositoryProvider).signInAnonymously();

// v2: 公開ボタン押下時
if (user.isAnonymous) {
  showLinkAccountModal(context); // Apple/Google/メール選択モーダル
}
```

### 認証状態プロバイダー（Riverpod）

```dart
// 全画面で参照可能なユーザー状態
@riverpod
Stream<AppUser?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

// Proチェックと組み合わせて使用
final isPro = ref.watch(entitlementProvider);
final user  = ref.watch(authStateProvider).valueOrNull;
```

### パッケージ追加

| パッケージ | v1/v2 | 用途 |
|-----------|-------|------|
| `firebase_core` | v1〜 | Firebase初期化 |
| `firebase_auth` | v1〜 | 匿名認証（v1）・実名認証（v2） |
| `google_sign_in` | v2〜 | Googleログイン |
| `sign_in_with_apple` | v2〜 | Appleログイン（App Store必須） |

---

## v1→v2 移行コスト

### 変わらないもの（1行も触らない）

| 対象 | 理由 |
|------|------|
| エディタ・ホーム・保存一覧の画面 | 認証状態に依存しない |
| `LayerConfig` / `PageConfig` モデル | 設計変更なし |
| CustomPainter / PdfRenderer | 描画ロジックは認証と無関係 |
| `TemplateDto` | 既にJSON対応済み |
| Isarスキーマ | `authorId`・`uuid` を最初から入れるため |
| エディタ系Riverpod providers | 影響なし |

### v2で追加するだけ（既存コードを壊さない）

```
lib/features/
  ├── auth/                ← 新規追加（既存featuresに触れない）
  │   ├── data/firebase_auth_repository.dart   # linkWithApple/Google を実装
  │   └── presentation/link_account_modal.dart # 「公開にはアカウントが必要」モーダル
  └── community/           ← 新規追加（完全に新しい機能）
      ├── data/            # Firestore読み書き
      └── presentation/    # 掲示板・検索・いいね画面
```

### v2での修正（最小限）

| 変更箇所 | 内容 | 規模 |
|---------|------|------|
| `pubspec.yaml` | `google_sign_in` `sign_in_with_apple` 追加 | 2行 |
| `FirebaseAuthRepository` | `linkWithApple/Google` の実装を追加 | 1ファイル内 |
| エディタ保存ボタン付近 | 「公開する」ボタンを1つ追加 | 数行 |
| `main.dart` | Firebase初期化はv1から済み | 0行 |

### v1で済ませておく必須作業（これだけで移行コストが最小になる）

1. `firebase_core` + `firebase_auth` を pubspec に追加
2. `AuthRepository` インターフェースを domain 層に定義
3. 起動時に匿名認証を自動実行
4. `NotebookTemplate` に `uuid` / `authorId` / `isPublic` を追加（計画済み）
5. `TemplateDto` を定義（計画済み）

---

## iPad対応方針

- **Universal App**（iPhone + iPad 両対応）として開発
- Flutter の `LayoutBuilder` / `AdaptiveScaffold` でレイアウトを分岐
- iPad では設定パネルをサイドパネル固定表示、iPhone ではボトムシート表示
- 製図・実験ノート・証明系テンプレートはiPadでの利用を想定したキャンバスサイズで設計

```dart
// レイアウト分岐の基本パターン
LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth >= 768) {
    return EditorTabletLayout();  // iPad: サイドパネル固定
  }
  return EditorPhoneLayout();     // iPhone: ボトムシート
});
```

---

## アプリ名

| 項目 | 内容 |
|------|------|
| アプリ名 | **LabNote** |
| サブタイトル | 理系のためのノート設計 |
| App Store キーワード | 実験ノート, 理系ノート, PDF印刷, ラボノート, グリッドノート, 方眼紙, 化学ノート |
| Bundle ID | `com.[yourname].labnote` |

---

## v2以降のニッチデザインロードマップ

### 競合調査サマリー

GoodNotes・Notability・reMarkable などの競合はすべて「罫線・方眼・ドット」の変形止まりで、
理系特化テンプレートは事実上ゼロ。理系ユーザーをニッチ市場と見なし投資されてこなかった領域。

### 重点分野と優先実装リスト

#### 🧪 化学系（最優先）

| デザイン | 難易度 | 差別化ポイント |
|---------|--------|--------------|
| 反応式レーン型レイアウト（反応物→矢印→生成物） | 中 | 競合ゼロ |
| NMRスペクトル記録シート（δ軸・多重度・J値欄） | 高 | 専門知識が参入障壁 |
| 反応条件ボックス（試薬・溶媒・温度を矢印上下に配置） | 中 | 競合ゼロ |
| 有機合成ルート追跡シート（収率記入欄付き多工程） | 高 | 競合ゼロ |

#### 🧬 生命科学系（優先）

| デザイン | 難易度 | 差別化ポイント |
|---------|--------|--------------|
| 電気泳動ゲル記録シート（レーン数・サイズマーカー） | 中 | 市場に存在しない |
| 顕微鏡スケッチテンプレート（視野円・倍率・スケールバー） | 低 | 即実装可能 |
| 系統樹ワークシート（二分岐ガイド・支持率記入） | 中 | - |
| プライマー設計メモシート（Tm・GC%計算欄） | 低 | 即実装可能 |

#### ⚡ 電気電子系（優先）

| デザイン | 難易度 | 差別化ポイント |
|---------|--------|--------------|
| タイミングチャート（クロックサイクル軸・信号名欄） | 中 | 競合が完全無視 |
| ボード線図ワークシート（対数周波数軸・利得/位相2段） | 高 | 専門知識が参入障壁 |
| 真理値表＋カルノーマップセット | 低 | 即実装可能 |
| ラプラス変換対応ページ（s領域/時間域並列） | 中 | - |

#### 📋 実験ノート全般 - GLP準拠（優先）

| デザイン | 難易度 | 差別化ポイント |
|---------|--------|--------------|
| GLP準拠フォーマット（署名欄・ページ連番・空白禁止） | 高 | 競合ゼロ・院生需要確実 |
| 試薬・機器記録欄付きシート（ロット番号・校正日） | 中 | - |
| 計算検証欄付きデータシート（生データ/計算/検算の3列） | 中 | - |

#### その他（v2〜v3で順次）

| 分野 | 代表的デザイン | 難易度 |
|------|--------------|--------|
| 数学 | 証明2カラム・行列計算グリッド・統計ワークシート | 低〜中 |
| 機械工学 | 第三角法投影・ISO表題欄・断面ハッチングガイド | 中 |
| 材料工学 | XRD記録シート・二元系相図・応力-ひずみ曲線 | 低〜中 |
| 情報工学 | UMLシーケンス図・状態遷移図・アルゴリズム解析シート | 低 |
| 大学院共通 | ポスタースケッチ・論文アブストラクト要約シート | 低 |

### ポジショニング戦略

> 「理系学生の実験室・講義室・自宅をカバーする唯一のアカデミック特化ノートアプリ」

競合が「きれいなノートを取るツール」であるのに対し、
本プロダクトは「科学的記録・思考の構造化ツール」として差別化する。

---

## 確定済み方針

| 項目 | 決定内容 |
|------|---------|
| Apple Pencil | **非対応**（画面上への書き込み機能なし。印刷前提） |
| 言語 | **日本語のみ**（v1） |
| 初期テンプレート | **自分＋AIで作成**（外部協力者なし） |
| アクセシビリティ | **非対応**（v1スコープ外） |
| アナリティクス | **Firebase Analytics**（Firebase導入済みのため追加工数ほぼゼロ） |
| CI/CD | **GitHub Actions + Fastlane**（自動ビルド・TestFlight配布） |
| ベータテスト対象 | 未定（TestFlight提出前に決める） |

## 未決定事項

| 項目 | タイミング |
|------|-----------|
| プライバシーポリシー | v1リリース前（App Store審査に必要） |
| ベータテスト対象大学・学部 | TestFlight提出前 |

---

## CI/CD（GitHub Actions + Fastlane）

### 構成

```
.github/workflows/
  ci.yml         ← PR時: flutter test + flutter analyze
  deploy.yml     ← main push時: TestFlight自動配布

fastlane/
  Fastfile
  Appfile
  Matchfile      ← 証明書管理（match + GitHub Secrets）
```

### ワークフロー定義

```yaml
# ci.yml（PR時に自動実行）
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build ios --no-codesign  # ビルド通過確認

# deploy.yml（mainマージ時にTestFlight配布）
jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - run: bundle exec fastlane beta
```

```ruby
# Fastfile
lane :beta do
  match(type: "appstore")          # 証明書取得
  build_app(scheme: "Runner")
  upload_to_testflight(
    skip_waiting_for_build_processing: true
  )
end
```

### セットアップ順序（開発1〜2週目に実施）

1. `fastlane init` でAppfile・Matchfile生成
2. `fastlane match init` で証明書をGitHub Private Repoに格納
3. GitHub Secretsに `MATCH_PASSWORD` / `APP_STORE_CONNECT_API_KEY` を登録
4. PRを出すとテストが走り、mainにマージするとTestFlightに自動配布される状態を作る

### アナリティクス（Firebase Analytics）

Firebase導入済みのため `firebase_analytics` パッケージを追加するだけ。
追加工数：約1〜2時間。

```dart
// 計測したいイベント（最小限）
analytics.logEvent(name: 'template_selected', parameters: {'template_type': 'hex'});
analytics.logEvent(name: 'pdf_exported', parameters: {'page_count': 3});
analytics.logEvent(name: 'paywall_shown', parameters: {'trigger': 'save_limit'});
```

これだけで「どのテンプレートが使われているか」「どこでペイウォールが出るか」が把握できる。

---

## GitHub Copilot 活用方針

### 工数削減が大きい用途（積極活用）

| 作業 | Copilot の貢献 | 削減見込み |
|------|--------------|-----------|
| `freezed` モデルの定型コード | フィールド定義からコード補完 | 大 |
| CustomPainter の描画ロジック | グリッド・六角形の座標計算 | 大 |
| Riverpod provider の定型実装 | AsyncNotifier の雛形補完 | 中 |
| Fastlane / GitHub Actions YAML | 設定ファイルの補完 | 中 |
| `dart-pdf` の描画API呼び出し | ドキュメント参照不要で補完 | 中 |

### 注意が必要な用途（レビュー必須）

| 作業 | 理由 |
|------|------|
| Isarスキーマ定義 | アノテーションの細かい仕様を誤ることがある |
| mm→pt変換などの精度が必要な計算 | 定数・丸め誤差を確認する |
| RevenueCat の課金フロー | セキュリティに関わるため必ずレビュー |

### 推奨セットアップ

- VSCode + Flutter 拡張 + GitHub Copilot
- `.github/copilot-instructions.md` にプロジェクト固有の規約を記述すると補完精度が上がる

```markdown
# copilot-instructions.md の記載例
- 状態管理は riverpod + @riverpod アノテーションを使う
- モデルは freezed で定義する
- サイズ単位はすべて mm で扱い、描画時のみ pt に変換する（1mm = 2.8346pt）
- コメントは書かない
```

---

## 検証方法

1. **グリッド精度**: 実機でPDF出力 → 定規で実測（1mm単位の正確さ確認）
2. **六角形テンプレ**: ベンゼン環を手書きして整合性確認
3. **PDF共有**: iOS共有シート → AirPrint → 実際に印刷して余白・穴位置確認
4. **保存・再利用**: アプリ終了後も保存データが残ることを確認
5. **A4/B5切替**: 両サイズのPDFをPreviewで寸法確認
