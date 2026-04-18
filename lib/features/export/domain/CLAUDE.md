# PDF Renderers — 規約

## 座標系（重要）
PDF は **左下原点・y軸上向き**。画面は左上原点・y軸下向き。

```
PDF y = size.y - screen_y   // 画面→PDF変換（古い方式、現在は不使用）
```

現在は contentRect を PDF 座標系で直接計算する方式を採用:
```dart
final left   = toPoints(pageConfig.marginLeftMm);
final right  = size.x - toPoints(pageConfig.marginRightMm);
final bottom = toPoints(pageConfig.marginBottomMm);   // PDF下端からの距離
final top    = size.y - toPoints(pageConfig.marginTopMm); // PDF上端からの距離
```

## クリップパターン（全 PdfRenderer 共通）
```dart
canvas.saveContext();
canvas.drawRect(left, bottom, right - left, top - bottom);
canvas.clipPath();
// ... 描画（PDF座標系で） ...
canvas.restoreContext();
```

## ユーティリティ
- `toPoints(mm)` → double（`print_constants.dart`）
- グリッドセンタリング: `offsetX = ((right - left) % cellW) / 2`
