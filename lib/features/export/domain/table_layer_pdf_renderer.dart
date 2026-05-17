import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class TableLayerPdfRenderer extends LayerPdfRendererBase<TableLayerConfig> {
  const TableLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  }) {
    if (config.rows <= 0 || config.cols <= 0) return;

    final cellH = toPoints(config.cellHeightMm);
    final cellW = (right - left) / config.cols;
    final tableTop = top; // PDF y-up: 上端から描画開始
    final tableBottom = (top - cellH * config.rows).clamp(bottom, top);

    final thin = 0.25;
    final bold = 0.6;

    void hLine(double y, double w) {
      canvas.setLineWidth(w);
      canvas.moveTo(left, y);
      canvas.lineTo(left + cellW * config.cols, y);
      canvas.strokePath();
    }

    void vLine(double x, double w) {
      canvas.setLineWidth(w);
      canvas.moveTo(x, tableBottom);
      canvas.lineTo(x, tableTop);
      canvas.strokePath();
    }

    canvas.setStrokeColor(PdfColor(color.red, color.green, color.blue, opacity));

    // 水平線（PDF y-up: 上から下へ = y 減少方向）
    for (int r = 0; r <= config.rows; r++) {
      final y = tableTop - cellH * r;
      if (y < bottom - 0.5) break;
      final isHeader = config.showHeaderRow && r == 1;
      final isOuter = r == 0 || r == config.rows;
      hLine(y, (isHeader || isOuter) ? bold : thin);
    }

    // 垂直線
    for (int c = 0; c <= config.cols; c++) {
      final x = left + cellW * c;
      final isHeader = config.showHeaderCol && c == 1;
      final isOuter = c == 0 || c == config.cols;
      vLine(x, (isHeader || isOuter) ? bold : thin);
    }
  }
}
