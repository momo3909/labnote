import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class GraphAxisLayerPdfRenderer extends LayerPdfRendererBase<GraphAxisLayerConfig> {
  const GraphAxisLayerPdfRenderer({
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
    final stroke = 0.35;
    final tickStroke = 0.2;
    final tickLen = toPoints(config.tickLengthMm);
    final tickInterval = toPoints(config.tickIntervalMm);
    final arrowSize = toPoints(3.0);

    final c = PdfColor(color.red, color.green, color.blue, opacity);
    final ct = PdfColor(color.red, color.green, color.blue, opacity * 0.7);

    // 原点（PDF y-up: 下端=bottom が画面下）
    final ox = config.showNegative ? (left + right) / 2 : left;
    final oy = config.showNegative ? (bottom + top) / 2 : bottom;

    // X 軸
    if (config.showXAxis) {
      final xStart = config.showNegative ? left : ox;
      canvas.setStrokeColor(c); canvas.setLineWidth(stroke);
      canvas.moveTo(xStart, oy); canvas.lineTo(right, oy); canvas.strokePath();
      if (config.arrowTip) _arrowH(canvas, right, oy, arrowSize, c);

      if (config.showTickMarks && tickInterval > 0) {
        canvas.setStrokeColor(ct); canvas.setLineWidth(tickStroke);
        // PDF y-up: positive=上方向(oy+len), negative=下方向(oy-len)
        final (xT0, xT1) = switch (config.xTickSide) {
          TickSide.positive => (oy, oy + tickLen),
          TickSide.negative => (oy - tickLen, oy),
          TickSide.both     => (oy - tickLen, oy + tickLen),
        };
        double x = ox + tickInterval;
        while (x <= right) {
          canvas.moveTo(x, xT0); canvas.lineTo(x, xT1); canvas.strokePath();
          x += tickInterval;
        }
        if (config.showNegative) {
          double xn = ox - tickInterval;
          while (xn >= left) {
            canvas.moveTo(xn, xT0); canvas.lineTo(xn, xT1); canvas.strokePath();
            xn -= tickInterval;
          }
        }
      }
    }

    // Y 軸
    if (config.showYAxis) {
      final yStart = config.showNegative ? bottom : oy;
      canvas.setStrokeColor(c); canvas.setLineWidth(stroke);
      canvas.moveTo(ox, yStart); canvas.lineTo(ox, top); canvas.strokePath();
      if (config.arrowTip) _arrowV(canvas, ox, top, arrowSize, c);

      if (config.showTickMarks && tickInterval > 0) {
        canvas.setStrokeColor(ct); canvas.setLineWidth(tickStroke);
        // PDF y-up: positive=右(ox+len), negative=左(ox-len)
        final (yT0, yT1) = switch (config.yTickSide) {
          TickSide.positive => (ox, ox + tickLen),
          TickSide.negative => (ox - tickLen, ox),
          TickSide.both     => (ox - tickLen, ox + tickLen),
        };
        double y = oy + tickInterval;
        while (y <= top) {
          canvas.moveTo(yT0, y); canvas.lineTo(yT1, y); canvas.strokePath();
          y += tickInterval;
        }
        if (config.showNegative) {
          double yn = oy - tickInterval;
          while (yn >= bottom) {
            canvas.moveTo(yT0, yn); canvas.lineTo(yT1, yn); canvas.strokePath();
            yn -= tickInterval;
          }
        }
      }
    }
  }

  void _arrowH(PdfGraphics canvas, double x, double y, double size, PdfColor c) {
    final wing = size * 0.4;
    canvas.setStrokeColor(c);
    canvas.moveTo(x, y); canvas.lineTo(x - size, y + wing); canvas.strokePath();
    canvas.moveTo(x, y); canvas.lineTo(x - size, y - wing); canvas.strokePath();
  }

  void _arrowV(PdfGraphics canvas, double x, double y, double size, PdfColor c) {
    final wing = size * 0.4;
    canvas.setStrokeColor(c);
    canvas.moveTo(x, y); canvas.lineTo(x + wing, y - size); canvas.strokePath();
    canvas.moveTo(x, y); canvas.lineTo(x - wing, y - size); canvas.strokePath();
  }
}
