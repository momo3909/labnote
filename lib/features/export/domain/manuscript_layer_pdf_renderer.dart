import 'package:pdf/pdf.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class ManuscriptLayerPdfRenderer extends LayerPdfRendererBase<ManuscriptLayerConfig> {
  const ManuscriptLayerPdfRenderer({
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
    final cols = config.columns;
    final rows = config.rows;
    final cellW = (right - left) / cols;
    final cellH = (top - bottom) / rows;

    canvas.setStrokeColor(color);

    // 横罫線
    for (int row = 0; row <= rows; row++) {
      final y = bottom + cellH * row;
      final isEdge = row == 0 || row == rows;
      canvas.setLineWidth(isEdge ? 0.6 : 0.3);
      canvas.moveTo(left, y); canvas.lineTo(right, y); canvas.strokePath();
    }

    // 縦罫線
    for (int col = 0; col <= cols; col++) {
      final x = left + cellW * col;
      final isEdge = col == 0 || col == cols;
      canvas.setLineWidth(isEdge ? 0.6 : 0.3);
      canvas.moveTo(x, bottom); canvas.lineTo(x, top); canvas.strokePath();
    }

    // 各セルの中央縦補助線
    final guideColor = PdfColor(color.red, color.green, color.blue, color.alpha * 0.25);
    canvas.setStrokeColor(guideColor);
    canvas.setLineWidth(0.2);
    for (int col = 0; col < cols; col++) {
      final x = left + cellW * col + cellW / 2;
      canvas.moveTo(x, bottom); canvas.lineTo(x, top); canvas.strokePath();
    }
  }
}
