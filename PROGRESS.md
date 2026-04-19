# LabNote v2 進捗

> v1 完了記録 → `docs/v1/PROGRESS.md`

---

## 現在の作業
**v2 コード実装 完了** 🎉  
**残タスク（外部作業）**: RevenueCat 本番キー設定 → TestFlight 提出

---

## v2 スケジュール

| 週 | 期間 | ブランチ | 内容 |
|----|------|---------|------|
| 1 | 04/19〜04/25 | `feature/dot-grid` | ドットグリッド |
| 2 | 04/26〜05/02 | `feature/log-grid` | 対数グラフ |
| 3 | 05/03〜05/09 | `feature/cornell` | コーネルノート |
| 4〜6 | 05/10〜05/30 | `feature/multi-layer` | レイヤー合成（State/UI/Properties） |
| 7 | 05/31〜06/06 | `feature/hole-marks` | ホール穴PDF描画 |
| 8 | 06/07〜06/13 | `feature/line-color` | カラー線 |
| 9 | 06/14〜06/20 | `feature/paper-sizes` | 用紙サイズ拡張 |
| 10 | 06/21〜06/27 | `feature/page-elements` | 行番号・ページ番号 |
| 11 | 06/28〜07/04 | `feature/polish-v2` | テスト・バグ修正・App Store準備 |

---

## タスク一覧

### feature/dot-grid　[ ✅ 完了 ]

**目標**: ドットグリッド（方眼の交点にドットを打つパターン）を追加

- [x] ① `lib/shared/models/layer_config.dart` — `LayerConfig.dot({spacingMm, dotRadiusMm})` = `DotLayerConfig` 追加 → build_runner
- [x] ② `lib/shared/painters/dot_layer_painter.dart` — 新規作成。`contentRect()` でクリップ後、交点に `canvas.drawCircle` 
- [x] ③ `lib/features/export/domain/dot_layer_pdf_renderer.dart` — 新規作成。PDF y-up 座標系
- [x] ④ `lib/features/editor/presentation/editor_screen.dart` — `DotLayerConfig` case 追加・`_buildDotControls()` 実装
- [x] ⑤ `lib/features/templates/presentation/home_screen.dart` + `pdf_builder.dart` + `editor_notifier.dart` — preset & switch 追加

---

### feature/log-grid　[ ✅ 完了 ]

**目標**: 対数グラフ用紙（片対数・両対数）を追加

- [x] ① `lib/shared/models/layer_config.dart` — `LogGridLayerConfig(xScale, yScale, xDecades, yDecades)` + `enum LogScale` 追加
- [x] ② `lib/shared/painters/log_grid_layer_painter.dart` — 新規作成。log10 で9本の minor 線 + major 線（太線）
- [x] ③ `lib/features/export/domain/log_grid_layer_pdf_renderer.dart` — 新規作成
- [x] ④ `lib/features/editor/presentation/editor_screen.dart` — case 追加・X/Y軸スケール切替チップ＋デケード数スライダー
- [x] ⑤ `home_screen.dart` + `pdf_builder.dart` + `editor_notifier.dart` — 片対数・両対数プリセット追加

---

### feature/cornell　[ ✅ 完了 ]

**目標**: コーネルノート（左カラム＋下サマリー行の罫線レイアウト）を追加

- [x] ① `lib/shared/models/layer_config.dart` — `CornellLayerConfig(leftColMm, bottomRowMm, lineSpacingMm)` 追加
- [x] ② `lib/shared/painters/cornell_layer_painter.dart` — 新規作成。区切り線（太線）＋メインエリアの横罫線
- [x] ③ `lib/features/export/domain/cornell_layer_pdf_renderer.dart` — 新規作成
- [x] ④ `lib/features/editor/presentation/editor_screen.dart` — case 追加・3スライダー（キーワード欄/サマリー欄/罫線間隔）
- [x] ⑤ `home_screen.dart` + `pdf_builder.dart` + `editor_notifier.dart` — preset & switch 追加

---

### feature/multi-layer　[ ✅ 完了 ]

**Week 4: State & Preview**

- [x] ① `lib/features/editor/domain/editor_notifier.dart` — `activeLayerIndex: int` を `EditorState` に追加。`activeLayer` getter を index ベースに変更
- [x] ② `lib/features/editor/presentation/editor_screen.dart` — `_buildPreview` を全可視レイヤーのスタック描画に更新

**Week 5: Layer Management UI**

- [x] ③ `lib/features/editor/presentation/editor_screen.dart` — `_buildLayerListPanel` 追加（追加ボタン・選択・削除・表示切替）
- [x] ④ `lib/features/editor/domain/editor_notifier.dart` — `addLayer` / `removeLayer` / `reorderLayer` / `setActiveLayerIndex` 追加

**Week 6: Layer Properties**

- [x] ⑤ `LayerEntity.opacity` は既存フィールドで対応済み（モデル変更不要）
- [x] ⑥ `lib/features/editor/presentation/editor_screen.dart` — レイヤー行にopacityスライダー・visibility トグル追加
- [x] ⑦ 全 Painter / PdfRenderer — `opacity` パラメータ済み確認済み

---

### feature/hole-marks　[ ✅ 完了 ]

**目標**: HoleConfig（26穴/30穴）をプレビューとPDFに描画

- [x] ① `lib/shared/painters/hole_marks_painter.dart` — 新規作成。`HoleConfig` に応じて穴位置に白塗り円＋ストローク
- [x] ② `lib/features/export/domain/hole_marks_pdf_renderer.dart` — 新規作成。PDF y-up 座標系
- [x] ③ `lib/features/export/domain/pdf_builder.dart` — 各ページの Stack に `HoleMarksPdfRenderer` を追加
- [x] ④ `lib/features/editor/presentation/editor_screen.dart` — 設定パネルに穴チップ（なし/26穴/30穴）＋プレビューオーバーレイ

---

### feature/line-color　[ ✅ 完了 ]

**目標**: 各レイヤーの線色を選択可能にする

- [x] ① `LayerEntity.colorHex` を活用（モデル変更不要）
- [x] ② `lib/shared/painters/painter_utils.dart` — `colorFromHex(String hex)` ヘルパー追加
- [x] ③ `lib/features/export/domain/pdf_builder.dart` — `pdfColorFromHex` 追加、各レイヤーで `layer.colorHex` を使用
- [x] ④ `lib/features/editor/presentation/editor_screen.dart` — プレビューで `colorFromHex(l.colorHex)` を渡すよう変更、レイヤー行にカラースウォッチ（7色）追加
- [x] ⑤ `lib/features/editor/domain/editor_notifier.dart` — `updateLayerColor(int index, String colorHex)` 追加

---

### feature/paper-sizes　[ ✅ 完了 ]

**目標**: Letter/A3/B4 を追加

- [x] ① `lib/core/constants/print_constants.dart` — A3/B4/Letter の定数追加 + `PaperSizeExt`（widthMm/heightMm）をここに定義
- [x] ② `lib/shared/models/page_config.dart` — `PaperSize` に `a3`, `b4`, `letter` 追加 → build_runner
- [x] ③ 全 Painter / PdfRenderer — テナリー式を `.widthMm` / `.heightMm` に一括 sed 置換
- [x] ④ `lib/features/editor/presentation/editor_screen.dart` — 用紙チップを Map ループで A4/B5/A3/B4/Letter 5択に変更

---

### feature/page-elements　[ ✅ 完了 ]

**目標**: 行番号・ページ番号をPDFに自動挿入

- [x] ① `lib/shared/models/page_config.dart` — `showPageNumber: bool`, `showLineNumbers: bool` 追加 → build_runner
- [x] ② `lib/features/export/domain/page_elements_pdf_renderer.dart` — 新規作成。`pw.Positioned` + `pw.Text` でページ番号（右下）・行番号（左余白）をウィジェットツリー方式で描画
- [x] ③ `lib/features/export/domain/pdf_builder.dart` — `PageElementsPdfRenderer` を各ページの Stack に追加
- [x] ④ `lib/features/editor/presentation/editor_screen.dart` — 「挿入」行にチェックボックス型トグルチップを追加（`_toggleChip` ヘルパー新規作成）

---

### feature/polish-v2　[ ✅ コード完了 / 外部作業残 ]

- [x] `flutter test` 全パス確認（10件）
- [x] `flutter analyze` ゼロエラー確認
- [x] `_addableLayerTypes` に `log_grid`（片対数・両対数）を追加
- [x] `home_screen.dart` の `_templateIcon` を dot/log_grid/cornell に対応
- [x] テスト修正: `marginLeftMm` デフォルト 20mm → 10mm に合わせて更新
- [ ] **【要対応】** `entitlement_notifier.dart` の `_rcApiKeyIos` を本番キーに差し替え
- [ ] **【要対応】** App Store Connect: In-App Purchase 商品作成
- [ ] **【要対応】** TestFlight 提出

---

### v2 追加実装（2026-04-19）　[ ✅ 完了 ]

**Undo / Redo**
- [x] `EditorState` に `canUndo`, `canRedo` フィールド追加
- [x] `EditorNotifier` に `_history` / `_future` スタック + `_commit()` ヘルパー実装（最大50件）
- [x] スライダー連続操作は `state =`（プレビューのみ）、`onChangeEnd` で `_commit`（2段階）
- [x] AppBar に undo/redo ボタン追加

**サムネイル保存**
- [x] `app_database.dart` — `thumbnailPng` nullable blob 列追加、schemaVersion 2、MigrationStrategy
- [x] `notebook_template.dart` — `Uint8List? thumbnailPng` フィールド追加
- [x] `template_repository.dart` — save/create/fromRow にサムネイル対応
- [x] `editor_screen.dart` — `RepaintBoundary` + `RenderRepaintBoundary.toImage()` でキャプチャ（保存ダイアログ表示前に撮影）
- [x] `home_screen.dart` / `saved_list_screen.dart` — `_TemplateThumbnail` / `_SavedThumbnail` ウィジェット追加

**レイアウト修正**
- [x] `editor_screen.dart` — body を `LayoutBuilder` でラップし実ボディ高さから `maxSheetContentH` を計算（オーバーフロー解消）

---

## 完了ブランチ
| ブランチ | 完了日 |
|---------|--------|
| v1 全機能 | 2026-04-18 |
| v2 全機能（main直コミット） | 2026-04-19 |
