import 'package:flutter_test/flutter_test.dart';
import 'package:labnote/shared/models/layer_config.dart';
import 'package:labnote/shared/models/page_config.dart';
import 'package:labnote/shared/painters/painter_utils.dart';
import 'package:labnote/core/constants/print_constants.dart';

void main() {
  group('scaleFactor', () {
    test('A4幅のキャンバスでscaleFactorが1.0になる', () {
      final paperWidthPx = a4WidthMm * mmToPt;
      final scale = scaleFactor(paperWidthPx, a4WidthMm);
      expect(scale, closeTo(1.0, 0.001));
    });

    test('半分の幅のキャンバスでscaleFactorが0.5になる', () {
      final paperWidthPx = a4WidthMm * mmToPt * 0.5;
      final scale = scaleFactor(paperWidthPx, a4WidthMm);
      expect(scale, closeTo(0.5, 0.001));
    });
  });

  group('mmToPx', () {
    test('scale=1のとき 1mm = 2.8346px', () {
      expect(mmToPx(1.0, 1.0), closeTo(mmToPt, 0.001));
    });

    test('scale=0.5のとき 5mm = 5 * 2.8346 * 0.5 px', () {
      expect(mmToPx(5.0, 0.5), closeTo(5.0 * mmToPt * 0.5, 0.001));
    });
  });

  group('GridLayerConfig', () {
    test('デフォルト値が正しい', () {
      const config = GridLayerConfig();
      expect(config.cellWidthMm, 5.0);
      expect(config.cellHeightMm, 5.0);
      expect(config.lineStyle, LineStyle.solid);
      expect(config.boldEvery, null);
    });

    test('copyWithで値を変更できる', () {
      const config = GridLayerConfig();
      final updated = config.copyWith(cellWidthMm: 10.0, lineStyle: LineStyle.dashed);
      expect(updated.cellWidthMm, 10.0);
      expect(updated.cellHeightMm, 5.0);
      expect(updated.lineStyle, LineStyle.dashed);
    });

    test('同じ値のConfigは等価', () {
      const a = GridLayerConfig(cellWidthMm: 5.0, cellHeightMm: 5.0);
      const b = GridLayerConfig(cellWidthMm: 5.0, cellHeightMm: 5.0);
      expect(a, equals(b));
    });
  });

  group('PageConfig', () {
    test('A4のデフォルト用紙サイズ', () {
      const config = PageConfig();
      expect(config.paperSize, PaperSize.a4);
      expect(config.marginLeftMm, 10.0);
    });

    test('toJson/fromJsonのラウンドトリップ', () {
      const original = PageConfig(paperSize: PaperSize.b5, pageCount: 3);
      final json = original.toJson();
      final restored = PageConfig.fromJson(json);
      expect(restored, equals(original));
    });
  });
}
