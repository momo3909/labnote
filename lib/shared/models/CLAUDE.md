# Models — 規約

## freezed 変更後は必ず実行
```bash
dart run build_runner build --delete-conflicting-outputs
```

## LayerConfig 追加テンプレート
```dart
// layer_config.dart に追加
const factory LayerConfig.xxx({
  @Default(5.0) double someMm,
  // ...
}) = XxxLayerConfig;
```

## PageConfig / LayerConfig の JSON 保存
- `Color` は JSON 非対応 → `int colorValue` で保存し `Color(colorValue)` で復元
- 新フィールドは必ず `@Default(...)` を付ける（既存DBとの互換性）
