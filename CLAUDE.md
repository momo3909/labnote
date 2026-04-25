# LabNote

作業前に `PROGRESS.md` で現タスクを確認すること。

Flutter / Riverpod (`@riverpod`) / Drift / go_router / dart-pdf

## 必須コマンド
```bash
dart run build_runner build --delete-conflicting-outputs  # freezed/Riverpod 変更後
flutter analyze --no-fatal-infos                          # 完了前にゼロ確認
```

## 規約
- コメントは WHY 非自明な場合のみ
- Painter は `canvas.save()` / `canvas.clipRect(contentRect(...))` / `canvas.restore()` で余白クリップ
- 詳細規約 → `lib/shared/painters/CLAUDE.md` / `lib/features/export/domain/CLAUDE.md` / `lib/shared/models/CLAUDE.md`
