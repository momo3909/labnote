# LabNote — Claude Instructions

## 現在のフェーズ
v2 開発中。**作業前に `PROGRESS.md` を読んで現在タスクを確認すること。**

## アーキテクチャ
Feature-first + Clean Architecture / Flutter 3.x / Riverpod (`@riverpod`) / Drift / go_router

```
lib/
  core/          # constants, router, theme
  features/      # editor, export, paywall, settings, templates
  shared/        # models (freezed), painters
```

## 必須コマンド
```bash
dart run build_runner build --delete-conflicting-outputs  # freezed/Riverpod 変更後
flutter analyze --no-fatal-infos                          # 完了前に必ずゼロ確認
```

## LayerConfig 新規追加の手順（v2で頻繁に使用）
1. `lib/shared/models/layer_config.dart` に factory 追加 → build_runner
2. `lib/shared/painters/xxx_layer_painter.dart` 新規作成（`contentRect()` でクリップ）
3. `lib/features/export/domain/xxx_layer_pdf_renderer.dart` 新規作成（PDF y-up 座標系）
4. `lib/features/editor/presentation/editor_screen.dart` の switch に case 追加
5. `lib/features/templates/presentation/home_screen.dart` の `_presets` に追加

## コード規約
- コメントは WHY が非自明な場合のみ（WHAT の説明コメント不要）
- 新機能追加時はスコープ外ファイルを触らない
- `canvas.save()` / `canvas.clipRect(contentRect(...))` / `canvas.restore()` で余白クリップ
