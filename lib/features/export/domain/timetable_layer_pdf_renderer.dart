import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';
import 'pdf_font_store.dart';

const _dayLabels = ['月', '火', '水', '木', '金', '土', '日'];

class TimetableLayerPdfRenderer extends LayerPdfRendererBase<TimetableLayerConfig> {
  const TimetableLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  // pw widget 座標系 (y-down) でコンテンツ領域を計算
  ({double left, double right, double top, double bottom}) _widgetRegion() {
    final pageW = toPoints(pageConfig.effectiveWidthMm);
    final pageH = toPoints(pageConfig.effectiveHeightMm);
    final cLeft = toPoints(effectiveMarginLeftMm(pageConfig));
    final cRight = pageW - toPoints(pageConfig.marginRightMm);
    final cTop = toPoints(pageConfig.marginTopMm);
    final cBottom = pageH - toPoints(pageConfig.marginBottomMm);
    final cW = cRight - cLeft;
    final cH = cBottom - cTop;
    return (
      left: cLeft + cW * region.x,
      right: cLeft + cW * (region.x + region.width),
      top: cTop + cH * region.y,
      bottom: cTop + cH * (region.y + region.height),
    );
  }

  @override
  pw.Widget build() {
    final slots = config.endHour - config.startHour;
    if (slots <= 0 || config.daysCount <= 0) return pw.SizedBox.shrink();

    final pageW = toPoints(pageConfig.effectiveWidthMm);
    final pageH = toPoints(pageConfig.effectiveHeightMm);
    final r = _widgetRegion();

    final headerH = toPoints(7.0);
    final timeColW = toPoints(11.0);
    final gridLeft = r.left + timeColW;
    final gridTop = r.top + headerH;
    final colW = (r.right - gridLeft) / config.daysCount;
    final rowH = (r.bottom - gridTop) / slots;

    final style = pw.TextStyle(
      font: PdfFontStore.ja,
      fontSize: 7,
      color: PdfColor(color.red, color.green, color.blue),
    );

    final items = <pw.Widget>[
      // グリッド線
      pw.CustomPaint(
        painter: (canvas, size) => _paintGrid(canvas, r, gridLeft, gridTop, colW, rowH, slots),
        size: PdfPoint(pageW, pageH),
      ),
      // 曜日ラベル
      for (int d = 0; d < config.daysCount; d++)
        pw.Positioned(
          left: gridLeft + colW * d + (colW - toPoints(5.0)) / 2,
          top: r.top + (headerH - toPoints(5.5)) / 2,
          child: pw.Text(_dayLabels[d], style: style),
        ),
      // 時刻ラベル
      for (int s = 0; s < slots; s++)
        pw.Positioned(
          left: r.left + toPoints(1.5),
          top: gridTop + rowH * s + (rowH - toPoints(4.5)) / 2,
          child: pw.Text('${config.startHour + s}', style: style),
        ),
    ];

    return pw.Positioned.fill(child: pw.Stack(children: items));
  }

  void _paintGrid(
    PdfGraphics canvas,
    ({double left, double right, double top, double bottom}) r,
    double gridLeft,
    double gridTop,
    double colW,
    double rowH,
    int slots,
  ) {
    // pw 座標 (y-down) → PDF 座標 (y-up) 変換
    final pageH = toPoints(pageConfig.effectiveHeightMm);
    final pLeft = r.left;
    final pRight = r.right;
    final pTop = pageH - r.top;       // PDF y-up
    final pBottom = pageH - r.bottom; // PDF y-up
    final pgLeft = gridLeft;
    final pgTop = pageH - gridTop;    // PDF y-up

    canvas.setStrokeColor(color);

    // 外枠
    canvas.setLineWidth(0.5);
    canvas.drawRect(pLeft, pBottom, pRight - pLeft, pTop - pBottom);
    canvas.strokePath();

    // ヘッダー・時刻列の区切り線
    canvas.moveTo(pLeft, pgTop); canvas.lineTo(pRight, pgTop); canvas.strokePath();
    canvas.moveTo(pgLeft, pBottom); canvas.lineTo(pgLeft, pTop); canvas.strokePath();

    canvas.setLineWidth(0.3);

    // 縦線 (各日)
    for (int d = 1; d < config.daysCount; d++) {
      final x = pgLeft + colW * d;
      canvas.moveTo(x, pBottom); canvas.lineTo(x, pTop); canvas.strokePath();
    }

    // 横線 (各コマ)
    for (int s = 1; s < slots; s++) {
      final y = pgTop - rowH * s; // PDF y-up: gridTopから下に
      canvas.moveTo(pLeft, y); canvas.lineTo(pRight, y); canvas.strokePath();
    }
  }

  @override
  void paintContent(PdfGraphics canvas, {required double left, required double right, required double bottom, required double top}) {}
}
