# LabNote 開発進捗

## 引き継ぎ情報

- **リポジトリ**: https://github.com/momo3909/labnote
- **プランファイル**: `/Users/momonoi/.claude/plans/parallel-strolling-brooks.md`
- **メモリ**: `/Users/momonoi/.claude/projects/-Users-momonoi/memory/project_labnote.md`
- **作業ディレクトリ**: `~/labnote`
- **Flutter**: 3.41.7 / `/opt/homebrew/bin/flutter`

## ブランチ戦略

```
main          ← 常にビルド通る状態。mainマージ→TestFlight自動配布
feature/xxx   ← 機能単位で作業。完成したらPR→main
fix/xxx       ← バグ修正
```

## スケジュール（全12週）

| 週 | ブランチ | 内容 | 状態 |
|----|---------|------|------|
| 1-2 | `feature/grid-painter` | GridLayerPainter + GridLayerPdfRenderer + エディタプレビュー | ✅ 完了 |
| 3-4 | `feature/editor-ui` | グリッド設定UI（スライダー・ボトムシート）・プレビュー更新 | ✅ 完了 |
| 5-6 | `feature/db-repository` | Drift DB・TemplateRepository・保存/読み込み | ✅ 完了（editor-uiに前倒し） |
| 7-8 | `feature/layer-types` | HexLayer / IsometricLayer / RegionLayer（Painter+PDF各セット） | ✅ 完了 |
| 9-10 | `feature/screens` | ホーム・保存一覧・go_routerナビゲーション | ✅ 完了（layer-typesに前倒し） |
| 11a | `feature/paywall` | RevenueCat連携・EntitlementNotifier・ペイウォールUI | ⬜ 未着手 |
| 11b | `feature/firebase-auth` | 匿名認証自動実行・AuthStateProvider | ⬜ 未着手 |
| 12 | `main` | UI磨き・バグ修正・TestFlight提出 | ⬜ 未着手 |

## 完了済みタスク

### 環境構築（週0）
- [x] Flutter 3.41.7 確認
- [x] `flutter create labnote` プロジェクト作成
- [x] フォルダ構成作成（Feature-first + Clean Architecture）
- [x] `pubspec.yaml` パッケージ追加（riverpod, freezed, drift, go_router, pdf, printing, RevenueCat, Firebase）
- [x] `build_runner` コード生成（freezed/drift/json_serializable）
- [x] `flutter analyze` エラーゼロ確認
- [x] `flutter test` パス確認
- [x] GitHub リポジトリ作成・初回プッシュ（https://github.com/momo3909/labnote）
- [x] GitHub Actions CI/Deploy ワークフロー設定
- [x] Fastlane `beta` lane 設定
- [x] `.github/copilot-instructions.md` 作成

### 作成済みファイル
- [x] `lib/core/constants/print_constants.dart` — mm→pt変換、用紙サイズ定数
- [x] `lib/core/router/app_router.dart` — go_router設定
- [x] `lib/core/theme/app_theme.dart` — ミニマルテーマ
- [x] `lib/shared/models/layer_config.dart` — LayerConfig sealed class（freezed）
- [x] `lib/shared/models/page_config.dart` — PageConfig（freezed）
- [x] `lib/shared/models/notebook_template.dart` — NotebookTemplate（UUID主キー）
- [x] `lib/features/auth/domain/app_user.dart` — AppUser（freezed）
- [x] `lib/features/auth/domain/auth_repository.dart` — AuthRepository抽象クラス
- [x] `lib/features/auth/data/firebase_auth_repository.dart` — Firebase匿名認証実装
- [x] `lib/features/editor/data/app_database.dart` — Drift DB定義（@DataClassName('TemplateRow')でNamingConflict解決済み）
- [x] `lib/features/templates/data/template_repository.dart` — Drift CRUD
- [x] `lib/features/editor/domain/editor_notifier.dart` — EditorNotifier（Riverpod）

## 進行中タスク

### feature/editor-ui（週3-4）

**目標**: テンプレート保存フロー完成・ホーム画面（保存済み一覧）実装

- [x] `lib/features/templates/data/template_repository.dart` — Drift CRUD（getAll/getByUuid/save/create/delete）
- [x] `lib/features/editor/domain/editor_notifier.dart` — EditorNotifier（Riverpod）・EditorState・templatesProvider
- [x] `lib/features/templates/presentation/home_screen.dart` — ホーム画面（プリセット選択＋保存済み一覧）
- [x] `lib/features/templates/presentation/saved_list_screen.dart` — スワイプ削除対応リスト
- [x] エディタ保存ボタン → 名前入力ダイアログ → DB保存 → ホームに戻る遷移
- [x] `app_router.dart` — /editor ルート競合修正

### feature/grid-painter（週1-2）

**目標**: `LayerConfig.grid(...)` を受け取り、画面とPDFに同一グリッドを描画する

- [x] `lib/shared/painters/grid_layer_painter.dart` — CustomPainter実装（実線・破線・点線・boldEvery対応）
- [x] `lib/features/export/domain/grid_layer_pdf_renderer.dart` — dart-pdf実装（PDF座標系変換済み）
- [x] `lib/shared/painters/painter_utils.dart` — mm→px変換ユーティリティ
- [x] `lib/features/editor/presentation/editor_screen.dart` — グリッドプレビュー＋ボトムシート設定UI
- [x] `test/features/editor/grid_layer_painter_test.dart` — ユニットテスト10件パス

**設計メモ**:
```
GridLayerConfig(cellWidthMm: 5, cellHeightMm: 5, lineStyle: solid)
  └→ GridLayerPainter.paint(canvas, size)  // 画面: 1px = ? mm はdpiから算出
  └→ GridLayerPdfRenderer.render(page)     // PDF: 1pt = 1/72inch, 1mm = 2.8346pt
```

画面プレビューのスケール:
- A4(210×297mm)をデバイス画面幅に収まるよう等倍縮小
- `scaleFactor = canvasWidthPx / (paperWidthMm * mmToPt)`

## 完了済みタスク（feature/layer-types）

- [x] `lib/shared/painters/hex_layer_painter.dart` — 六角形グリッド CustomPainter（flat/pointy対応）
- [x] `lib/shared/painters/isometric_layer_painter.dart` — アイソメトリックグリッド CustomPainter
- [x] `lib/features/export/domain/hex_layer_pdf_renderer.dart` — 六角形グリッド PDF レンダラー
- [x] `lib/features/export/domain/isometric_layer_pdf_renderer.dart` — アイソメトリック PDF レンダラー
- [x] `lib/features/export/domain/pdf_builder.dart` — テンプレート→PDF変換（複数ページ対応）
- [x] `lib/features/export/presentation/export_service.dart` — iOS共有シート経由PDF出力
- [x] `EditorScreen` — 全レイヤー型プレビュー対応・PDF出力ボタン実装・ページ数ダイアログ
- [x] `HomeScreen` — プリセットカードから適切なLayerConfigをエディタに渡すよう接続
- [x] `app_router.dart` — `/editor` ルートのextraでLayerConfigを受け渡し
- [x] `EditorNotifier` — `EditorParam({uuid, preset})` でプリセット初期設定に対応

## 未着手タスク（詳細は着手時に展開）

- feature/paywall（RevenueCat）
- feature/firebase-auth
- CI/CD: Fastlane match 証明書設定（TestFlight提出前）
- プライバシーポリシー作成（リリース前）

## 技術メモ・決定事項

### DBについて
- Isar 3.x はメンテ停止のため **drift** を採用
- テンプレートのレイヤー設定は `layersJson`（JSON文字列）として保存
- `uuid` パッケージで UUID v4 を生成して主キーに使用

### mm→px変換（画面プレビュー）
```dart
// 画面プレビュー用スケール係数の計算
double scaleFactor(double canvasWidthPx, double paperWidthMm) {
  return canvasWidthPx / (paperWidthMm * mmToPt);
}
// pt座標をピクセルに変換
double ptToPx(double pt, double scaleFactor) => pt * scaleFactor;
```

### LayerConfig の追加方法（拡張時）
1. `layer_config.dart` に `const factory LayerConfig.newType(...)` を追加
2. `build_runner` を再実行
3. `NewTypeLayerPainter` と `NewTypeLayerPdfRenderer` を1セット追加
4. `EditorScreen` の switch 文に case を追加
