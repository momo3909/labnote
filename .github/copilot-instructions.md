# LabNote — Copilot Instructions

## プロジェクト概要
理系大学生向けのノート設計・PDF印刷アプリ。Flutter製。

## コーディング規約

- 状態管理: `flutter_riverpod` + `@riverpod` アノテーション（riverpod_generator）
- モデル定義: `freezed` を使用。コード生成前提
- ローカルDB: `isar`。Isarコレクションとfreezedモデルは分離する
- ルーティング: `go_router`
- サイズ単位: **すべてmmで扱い、描画・PDF出力時のみptに変換**（1mm = 2.8346pt）
- コメントは書かない（自明なコードには不要）
- `print()` は使用禁止。デバッグは `debugPrint()` のみ

## フォルダ構成ルール

```
lib/
  core/          # アプリ全体の共通設定（router, theme, constants）
  features/      # 機能単位（editor, templates, export, paywall, auth）
    [feature]/
      data/      # Repository実装（Isar読み書き、API呼び出し）
      domain/    # Notifier（Riverpod）、Repository抽象クラス
      presentation/ # Screen, Widget
  shared/
    models/      # sealed class LayerConfig など共有モデル
    painters/    # CustomPainter実装（レイヤー別）
    widgets/     # 共通ウィジェット
```

## 重要な型・クラス

- `LayerConfig` — sealed class（freezed）。グリッドの種類を表す
  - `LayerConfig.grid(cellWidthMm, cellHeightMm, lineStyle)`
  - `LayerConfig.hex(hexSizeMm, orientation)`
  - `LayerConfig.isometric(spacingMm)`
  - `LayerConfig.region(regions)`
  - `LayerConfig.guide(guideType, params)`
- `NotebookTemplate` — Isarコレクション。`uuid`（UUID v4）を主キーとして持つ
- `PageConfig` — 用紙サイズ・余白・穴位置の設定
- `TemplateDto` — freezed + json_serializable。ネットワーク転送用
- `AppUser` — Firebase Userのラップ。`uid`, `isAnonymous` を持つ

## mm→pt変換

```dart
// lib/core/constants/print_constants.dart に定義済み
const double mmToPt = 2.8346;
double mmToPtValue(double mm) => mm * mmToPt;
```

## 命名規則

- Notifier: `TemplateListNotifier`, `EditorNotifier`
- Repository: `TemplateRepository`（抽象）/ `IsarTemplateRepository`（実装）
- Screen: `HomeScreen`, `EditorScreen`
- Provider: `templateListProvider`, `editorProvider`
