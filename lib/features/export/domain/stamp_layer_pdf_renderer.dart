import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/painters/painter_utils.dart' show colorFromHex;
import 'layer_pdf_renderer_base.dart';

class StampLayerPdfRenderer extends LayerPdfRendererBase<StampLayerConfig> {
  const StampLayerPdfRenderer({
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
    final paperW = toPoints(pageConfig.effectiveWidthMm);
    final paperH = toPoints(pageConfig.effectiveHeightMm);

    for (final item in config.items) {
      final cx = item.xRatio * paperW;
      // PDF y-axis is up; yRatio=0 is top of paper → PDF y = paperH
      final cy = paperH * (1.0 - item.yRatio);
      final wPts = toPoints(item.widthMm > 0 ? item.widthMm : item.sizeMm);
      final hPts = toPoints(item.heightMm > 0 ? item.heightMm : item.sizeMm);
      final basePts = wPts > hPts ? wPts : hPts;
      final scaleX = basePts > 0 ? wPts / basePts : 1.0;
      final scaleY = basePts > 0 ? hPts / basePts : 1.0;
      final minPts = wPts < hPts ? wPts : hPts;
      final sw = ((minPts * 0.09).clamp(0.5, 2.0) * item.strokeScale).clamp(0.3, 6.0);
      final fc = colorFromHex(item.colorHex);
      final pc = PdfColor(fc.r.toDouble(), fc.g.toDouble(), fc.b.toDouble(), opacity.toDouble());
      canvas.setStrokeColor(pc);
      canvas.setFillColor(pc);
      canvas.setLineWidth(sw);

      // rotation と非均等スケールを CTM に合成して適用
      // PDF y-up: rotateZ 正 = 反時計回り。Flutter (y-down) 正 = 時計回りに合わせ符号反転
      final angle = -item.rotation * pi / 180.0;
      canvas.saveContext();
      final m = Matrix4.identity()
        ..translate(cx, cy)
        ..rotateZ(angle)
        ..scale(scaleX, scaleY)
        ..translate(-cx, -cy);
      canvas.setTransform(m);
      _drawShape(canvas, item.shapeType, cx, cy, basePts);
      canvas.restoreContext();
    }
  }

  void _drawShape(PdfGraphics c, String type, double cx, double cy, double sz) {
    final h = sz / 2;
    switch (type) {
      case 'circle':
        c.drawEllipse(cx, cy, h, h);
        c.strokePath();
      case 'star':
        _drawStar(c, cx, cy, sz);
      case 'checkbox':
        _drawRect(c, cx, cy, sz, sz);
        c.moveTo(cx - h * 0.45, cy);
        c.lineTo(cx - h * 0.05, cy - h * 0.4);
        c.lineTo(cx + h * 0.5, cy + h * 0.35);
        c.strokePath();
      case 'cross':
        c.drawLine(cx - h, cy, cx + h, cy); c.strokePath();
        c.drawLine(cx, cy - h, cx, cy + h); c.strokePath();
      case 'rect':
        _drawRect(c, cx, cy, sz, sz * 0.75);
      case 'diamond':
        c.moveTo(cx, cy + h);
        c.lineTo(cx + h * 0.7, cy);
        c.lineTo(cx, cy - h);
        c.lineTo(cx - h * 0.7, cy);
        c.closePath(); c.strokePath();
      case 'arrow_right':
        _drawArrow(c, cx - h, cy, cx + h, cy, sz);
      case 'arrow_both':
        c.drawLine(cx - h, cy, cx + h, cy); c.strokePath();
        final hs = sz * 0.22;
        c.drawLine(cx + h, cy, cx + h - hs, cy + hs * 0.5); c.strokePath();
        c.drawLine(cx + h, cy, cx + h - hs, cy - hs * 0.5); c.strokePath();
        c.drawLine(cx - h, cy, cx - h + hs, cy + hs * 0.5); c.strokePath();
        c.drawLine(cx - h, cy, cx - h + hs, cy - hs * 0.5); c.strokePath();
      case 'benzene':
        _drawBenzene(c, cx, cy, sz);
      case 'xy_axis':
        // X axis → (right)
        _drawArrow(c, cx - h, cy, cx + h, cy, sz);
        // Y axis ↑ (up in PDF = positive y direction)
        _drawArrow(c, cx, cy - h, cx, cy + h, sz);
      case 'resistor':
        final hw = sz / 2;
        final hh = sz * 0.15;
        c.drawLine(cx - hw, cy, cx - hw * 0.38, cy); c.strokePath();
        c.drawLine(cx + hw * 0.38, cy, cx + hw, cy); c.strokePath();
        _drawRect(c, cx, cy, hw * 0.76, hh * 2);
      case 'venn2':
        final r = sz * 0.36;
        final off = sz * 0.2;
        c.drawEllipse(cx - off, cy, r, r); c.strokePath();
        c.drawEllipse(cx + off, cy, r, r); c.strokePath();
      case 'ellipse':
        c.drawEllipse(cx, cy, h, h * 0.65); c.strokePath();
      case 'functional_box':
        _drawRect(c, cx, cy, sz * 0.8, sz * 0.5);
      case 'arrow_equilibrium':
        final gap = sz * 0.12;
        final hs = sz * 0.2;
        c.drawLine(cx - h, cy + gap, cx + h, cy + gap); c.strokePath();
        c.drawLine(cx + h, cy + gap, cx + h - hs, cy + gap + hs * 0.5); c.strokePath();
        c.drawLine(cx - h, cy - gap, cx + h, cy - gap); c.strokePath();
        c.drawLine(cx - h, cy - gap, cx - h + hs, cy - gap - hs * 0.5); c.strokePath();
      case 'arrow_double':
        final gap2 = sz * 0.12;
        _drawArrow(c, cx - h, cy + gap2, cx + h, cy + gap2, sz);
        _drawArrow(c, cx - h, cy - gap2, cx + h, cy - gap2, sz);
      case 'benzene_kekule':
        _drawBenzeneKekule(c, cx, cy, sz);
      case 'capacitor':
        final gap3 = sz * 0.08;
        final ph = sz * 0.3;
        c.drawLine(cx - h, cy, cx - gap3, cy); c.strokePath();
        c.drawLine(cx + gap3, cy, cx + h, cy); c.strokePath();
        c.drawLine(cx - gap3, cy - ph, cx - gap3, cy + ph); c.strokePath();
        c.drawLine(cx + gap3, cy - ph, cx + gap3, cy + ph); c.strokePath();
      case 'battery':
        final gap4 = sz * 0.1;
        c.drawLine(cx - h, cy, cx - gap4 * 0.5, cy); c.strokePath();
        c.drawLine(cx + gap4 * 0.5, cy, cx + h, cy); c.strokePath();
        c.drawLine(cx - gap4 * 0.5, cy - sz * 0.3, cx - gap4 * 0.5, cy + sz * 0.3); c.strokePath();
        c.drawLine(cx + gap4 * 0.5, cy - sz * 0.15, cx + gap4 * 0.5, cy + sz * 0.15); c.strokePath();
      case 'switch_open':
        c.drawLine(cx - h, cy, cx - h * 0.3, cy); c.strokePath();
        c.drawLine(cx + h * 0.3, cy, cx + h, cy); c.strokePath();
        c.drawLine(cx - h * 0.3, cy, cx + h * 0.3, cy - sz * 0.3); c.strokePath();
        c.drawEllipse(cx - h * 0.3, cy, sz * 0.08, sz * 0.08); c.fillPath();
        c.drawEllipse(cx + h * 0.3, cy, sz * 0.08, sz * 0.08); c.fillPath();
      case 'xyz_axis':
        final ha = sz * 0.45;
        final iso = sz * 0.28;
        _drawArrow(c, cx, cy - ha, cx, cy + ha, sz);
        _drawArrow(c, cx, cy, cx + ha, cy, sz);
        _drawArrow(c, cx, cy, cx - iso, cy - iso, sz);
      case 'number_line':
        _drawArrow(c, cx - h, cy, cx + h, cy, sz);
        final tk = sz * 0.12;
        c.drawLine(cx, cy - tk, cx, cy + tk); c.strokePath();
        c.drawLine(cx - h * 0.5, cy - tk * 0.6, cx - h * 0.5, cy + tk * 0.6); c.strokePath();
        c.drawLine(cx + h * 0.5, cy - tk * 0.6, cx + h * 0.5, cy + tk * 0.6); c.strokePath();
      case 'matrix_bracket':
        final hw = sz * 0.35;
        final hh = sz * 0.45;
        final bw = sz * 0.12;
        c.moveTo(cx - hw + bw, cy - hh); c.lineTo(cx - hw, cy - hh);
        c.lineTo(cx - hw, cy + hh); c.lineTo(cx - hw + bw, cy + hh); c.strokePath();
        c.moveTo(cx + hw - bw, cy - hh); c.lineTo(cx + hw, cy - hh);
        c.lineTo(cx + hw, cy + hh); c.lineTo(cx + hw - bw, cy + hh); c.strokePath();
      case 'arrow_curved':
        // PDF y-up: arch goes upward (larger y), start/end are h*0.3 below center
        c.moveTo(cx - h, cy - h * 0.3);
        c.curveTo(cx - h * 0.5, cy + h * 0.6, cx + h * 0.5, cy + h * 0.6, cx + h, cy - h * 0.3);
        c.strokePath();
        // Tangent at endpoint = P3 - CP2 = (0.5h, -0.9h)
        final tx2 = h * 0.5, ty2 = -h * 0.9;
        final len2 = sqrt(tx2 * tx2 + ty2 * ty2);
        final ux2 = tx2 / len2, uy2 = ty2 / len2;
        final hs2 = sz * 0.2;
        c.drawLine(cx + h, cy - h * 0.3,
            cx + h - ux2 * hs2 - uy2 * hs2 * 0.5, cy - h * 0.3 - uy2 * hs2 + ux2 * hs2 * 0.5); c.strokePath();
        c.drawLine(cx + h, cy - h * 0.3,
            cx + h - ux2 * hs2 + uy2 * hs2 * 0.5, cy - h * 0.3 - uy2 * hs2 - ux2 * hs2 * 0.5); c.strokePath();
      case 'divider_t':
        c.drawLine(cx - h, cy, cx + h, cy); c.strokePath();
        c.drawLine(cx, cy, cx, cy + h); c.strokePath();
      case 'divider_l':
        c.drawLine(cx - h, cy, cx, cy); c.strokePath();
        c.drawLine(cx, cy, cx, cy + h); c.strokePath();
      default:
        c.drawEllipse(cx, cy, sz / 4, sz / 4);
        c.fillPath();
    }
  }

  void _drawRect(PdfGraphics c, double cx, double cy, double w, double h) {
    c.drawRect(cx - w / 2, cy - h / 2, w, h);
    c.strokePath();
  }

  void _drawArrow(PdfGraphics c, double x1, double y1, double x2, double y2, double sz) {
    c.drawLine(x1, y1, x2, y2); c.strokePath();
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    final hs = sz * 0.22;
    c.drawLine(x2, y2, x2 - ux * hs - uy * hs * 0.5, y2 - uy * hs + ux * hs * 0.5); c.strokePath();
    c.drawLine(x2, y2, x2 - ux * hs + uy * hs * 0.5, y2 - uy * hs - ux * hs * 0.5); c.strokePath();
  }

  void _drawBenzeneKekule(PdfGraphics c, double cx, double cy, double sz) {
    final r = sz / 2;
    c.moveTo(cx + r * cos(-pi / 2), cy + r * sin(-pi / 2));
    for (int i = 1; i < 6; i++) {
      final a = -pi / 2 + i * pi / 3;
      c.lineTo(cx + r * cos(a), cy + r * sin(a));
    }
    c.closePath(); c.strokePath();
    final inner = r * 0.65;
    for (int i = 0; i < 3; i++) {
      final a1 = -pi / 2 + i * 2 * pi / 3;
      final a2 = a1 + pi / 3;
      c.drawLine(cx + inner * cos(a1), cy + inner * sin(a1),
          cx + inner * cos(a2), cy + inner * sin(a2)); c.strokePath();
    }
  }

  void _drawBenzene(PdfGraphics c, double cx, double cy, double sz) {
    final r = sz / 2;
    c.moveTo(cx + r * cos(-pi / 2), cy + r * sin(-pi / 2));
    for (int i = 1; i < 6; i++) {
      final a = -pi / 2 + i * pi / 3;
      c.lineTo(cx + r * cos(a), cy + r * sin(a));
    }
    c.closePath(); c.strokePath();
    c.drawEllipse(cx, cy, r * 0.52, r * 0.52); c.strokePath();
  }

  void _drawStar(PdfGraphics c, double cx, double cy, double sz) {
    final r = sz / 2;
    final inner = r * 0.4;
    // PDF y-up: pi/2 = 上端。時計回り（-方向）で Flutter の見た目に合わせる
    c.moveTo(cx + r * cos(pi / 2), cy + r * sin(pi / 2));
    for (int i = 1; i < 10; i++) {
      final a = pi / 2 - i * pi / 5;
      final rad = i.isEven ? r : inner;
      c.lineTo(cx + rad * cos(a), cy + rad * sin(a));
    }
    c.closePath(); c.strokePath();
  }
}
