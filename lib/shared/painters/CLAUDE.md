# Painters — 規約

## 必須パターン（全 Painter 共通）
```dart
@override
void paint(Canvas canvas, Size size) {
  final paperWidthMm = pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
  final scale = scaleFactor(size.width, paperWidthMm);
  // ... 計算 ...

  final clip = contentRect(size, pageConfig, scale);  // 余白クリップ
  canvas.save();
  canvas.clipRect(clip);
  // ... 描画 ...
  canvas.restore();
}
```

## ユーティリティ（`painter_utils.dart`）
- `scaleFactor(canvasWidthPx, paperWidthMm)` → double
- `mmToPx(mm, scale)` → double
- `contentRect(size, pageConfig, scale)` → Rect（余白考慮済みクリップ領域）

## グリッドのセンタリング
```dart
final offsetX = (clip.width % cellW) / 2;  // 両端の半端セルを均等に
for (double x = clip.left + offsetX; x <= clip.right + 0.5; x += cellW) { ... }
```
