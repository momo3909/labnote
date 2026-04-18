# LabNote v2 進捗

> v1 完了記録 → `docs/v1/PROGRESS.md`

---

## 現在の作業
**ブランチ**: `feature/log-grid` → **完了・マージ待ち**  
**次のタスク**: `feature/cornell` ブランチ作成 → タスク①から着手

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

### feature/cornell　[ 未着手 ]

**目標**: コーネルノート（左カラム＋下サマリー行の罫線レイアウト）を追加

- [ ] ① `lib/shared/models/layer_config.dart` — `LayerConfig.cornell({leftColMm, bottomRowMm, lineSpacingMm})` = `CornellLayerConfig` 追加 → build_runner
- [ ] ② `lib/shared/painters/cornell_layer_painter.dart` — 新規作成。区切り線（左縦・下横）＋横罫線（メインエリアのみ）
- [ ] ③ `lib/features/export/domain/cornell_layer_pdf_renderer.dart` — 新規作成
- [ ] ④ `lib/features/editor/presentation/editor_screen.dart` — case 追加・左カラム幅・下行高スライダー
- [ ] ⑤ `lib/features/templates/presentation/home_screen.dart` + `pdf_builder.dart` — preset & switch 追加

---

### feature/multi-layer　[ 未着手 ]

**Week 4: State & Preview**

- [ ] ① `lib/features/editor/domain/editor_notifier.dart` — `EditorState.activeLayer` → `List<EditorLayer> layers` + `int activeLayerIndex` に変更。DB の `layersJson: List<String>` は既存のまま使用
- [ ] ② `lib/features/editor/presentation/editor_screen.dart` — `_buildPreview` をすべての layers をスタックで描画するよう更新（`Stack` + `CustomPaint` ×N）

**Week 5: Layer Management UI**

- [ ] ③ `lib/features/editor/presentation/editor_screen.dart` — 設定パネルにレイヤー一覧追加（レイヤー追加ボタン・選択・削除）
- [ ] ④ `lib/features/editor/domain/editor_notifier.dart` — `addLayer(LayerConfig)` / `removeLayer(int index)` / `reorderLayer(int from, int to)` メソッド追加

**Week 6: Layer Properties**

- [ ] ⑤ `lib/shared/models/layer_config.dart` — 全 LayerConfig に `@Default(1.0) double opacity` 追加 → build_runner
- [ ] ⑥ `lib/features/editor/presentation/editor_screen.dart` — レイヤー行に不透明度スライダー・表示/非表示トグル追加
- [ ] ⑦ 全 Painter / PdfRenderer — `opacity` フィールドを実際に使用するよう確認・修正

---

### feature/hole-marks　[ 未着手 ]

**目標**: HoleConfig（26穴/30穴）をプレビューとPDFに描画

- [ ] ① `lib/shared/painters/hole_marks_painter.dart` — 新規作成。`HoleConfig` に応じて穴位置に `drawCircle`（中抜き円）
- [ ] ② `lib/features/export/domain/pdf_builder.dart` — `HoleConfig != none` のとき穴マークを各ページに描画
- [ ] ③ `lib/features/editor/presentation/editor_screen.dart` — 設定パネルに穴設定チップ追加（なし/26穴/30穴）
- [ ] ④ `lib/features/editor/presentation/editor_screen.dart` — `_buildPreview` に `HoleMasksPainter` をオーバーレイ

---

### feature/line-color　[ 未着手 ]

**目標**: 各レイヤーの線色を選択可能にする

- [ ] ① `lib/shared/models/layer_config.dart` — 全 LayerConfig に `@Default(0xFF9E9E9E) int colorValue` 追加 → build_runner（Color は JSON非対応なので int で保存）
- [ ] ② `lib/shared/painters/painter_utils.dart` — `colorFromValue(int v)` ヘルパー追加
- [ ] ③ 全 Painter / PdfRenderer — ハードコードの `Color(0xFFAAAAAA)` → `config.colorValue` 使用に変更
- [ ] ④ `lib/features/editor/presentation/editor_screen.dart` — 設定パネルに色選択UI追加（カラーパレット or `showColorPicker`）

---

### feature/paper-sizes　[ 未着手 ]

**目標**: Letter/A3/B4 を追加

- [ ] ① `lib/core/constants/print_constants.dart` — Letter/A3/B4 の幅・高さ定数追加
- [ ] ② `lib/shared/models/page_config.dart` — `PaperSize` に `letter`, `a3`, `b4` 追加 → build_runner
- [ ] ③ `lib/features/editor/presentation/editor_screen.dart` — 用紙チップに新サイズ追加。`paperWidthMm` / `paperHeightMm` の switch を更新
- [ ] ④ 全 Painter / PdfRenderer / pdf_builder — `PaperSize` switch に新ケース追加

---

### feature/page-elements　[ 未着手 ]

**目標**: 行番号・ページ番号をPDFに自動挿入

- [ ] ① `lib/shared/models/page_config.dart` — `showLineNumbers: bool`, `showPageNumber: bool` 追加 → build_runner
- [ ] ② `lib/features/export/domain/pdf_builder.dart` — ページ番号をフッターに挿入（`pw.Text` + `pw.FullPage`）
- [ ] ③ `lib/features/export/domain/pdf_builder.dart` — 行番号を左余白に挿入（グリッド行ごとに番号）
- [ ] ④ `lib/features/editor/presentation/editor_screen.dart` — 設定パネルに行番号/ページ番号トグル追加

---

### feature/polish-v2　[ 未着手 ]

- [ ] 全機能の結合テスト（PDF出力 + レイヤー合成）
- [ ] `flutter test` 全パス確認
- [ ] RevenueCat 実API key 設定（`entitlement_notifier.dart`）
- [ ] App Store Connect: In-App Purchase 商品作成
- [ ] TestFlight 提出

---

## 完了ブランチ
| ブランチ | 完了日 |
|---------|--------|
| v1 全機能 | 2026-04-18 |
