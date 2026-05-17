import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';
import 'pdf_font_store.dart';

class LogGridLayerPdfRenderer extends LayerPdfRendererBase<LogGridLayerConfig> {
  const LogGridLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  pw.Widget build() {
    final base = super.build();
    final labels = <pw.Widget>[];
    final labelStyle = pw.TextStyle(
      font: PdfFontStore.ja,
      fontSize: 7,
      color: PdfColor(color.red, color.green, color.blue, opacity * 0.7),
    );
    final marginRight = toPoints(pageConfig.marginRightMm);
    final marginTop = toPoints(pageConfig.marginTopMm);

    if (config.xLabel.isNotEmpty) {
      labels.add(pw.Positioned(
        top: toPoints(pageConfig.effectiveHeightMm) - marginTop - 12,
        right: marginRight + 3,
        child: pw.Text(config.xLabel, style: labelStyle),
      ));
    }
    if (config.yLabel.isNotEmpty) {
      labels.add(pw.Positioned(
        top: marginTop + 3,
        left: toPoints(effectiveMarginLeftMm(pageConfig)) + 3,
        child: pw.Transform.rotateBox(
          angle: -pi / 2,
          child: pw.Text(config.yLabel, style: labelStyle),
        ),
      ));
    }
    if (labels.isEmpty) return base;
    return pw.Stack(children: [base, ...labels]);
  }

  @override
  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  }) {
    if (config.xScale == LogScale.log) {
      _drawLogAxis(canvas, left, right, bottom, top,
          decades: config.xDecades, horizontal: false);
    } else {
      _drawLinearAxis(canvas, left, right, bottom, top, horizontal: false);
    }

    if (config.yScale == LogScale.log) {
      _drawLogAxis(canvas, left, right, bottom, top,
          decades: config.yDecades, horizontal: true);
    } else {
      _drawLinearAxis(canvas, left, right, bottom, top, horizontal: true);
    }
  }

  void _drawLogAxis(
    PdfGraphics canvas,
    double left,
    double right,
    double bottom,
    double top, {
    required int decades,
    required bool horizontal,
  }) {
    final length = horizontal ? top - bottom : right - left;
    final decadeSize = length / decades;

    for (int d = 0; d <= decades; d++) {
      final pos = (horizontal ? bottom : left) + d * decadeSize;
      _drawLine(canvas, left, right, bottom, top, pos, horizontal, bold: true);

      if (d < decades) {
        for (int i = 2; i <= 9; i++) {
          final offset = log(i) / log(10) * decadeSize;
          _drawLine(canvas, left, right, bottom, top, pos + offset, horizontal, bold: false);
        }
      }
    }
  }

  void _drawLinearAxis(
    PdfGraphics canvas,
    double left,
    double right,
    double bottom,
    double top, {
    required bool horizontal,
  }) {
    final nominalStep = toPoints(5.0);
    final length = horizontal ? top - bottom : right - left;
    final count = (length / nominalStep).round().clamp(1, 10000);
    final step = length / count;
    final origin = horizontal ? bottom : left;

    for (int i = 0; i <= count; i++) {
      _drawLine(canvas, left, right, bottom, top, origin + step * i, horizontal, bold: false);
    }
  }

  void _drawLine(
    PdfGraphics canvas,
    double left,
    double right,
    double bottom,
    double top,
    double pos,
    bool horizontal, {
    required bool bold,
  }) {
    canvas.setStrokeColor(color);
    canvas.setLineWidth(bold ? 0.5 : 0.25);
    if (horizontal) {
      canvas.moveTo(left, pos);
      canvas.lineTo(right, pos);
    } else {
      canvas.moveTo(pos, bottom);
      canvas.lineTo(pos, top);
    }
    canvas.strokePath();
  }
}
