import 'dart:math';
import 'package:flutter/material.dart';

/// Canvas 上にスタンプ図形を描画するユーティリティ。
/// cx, cy は図形の中心 (Canvas 座標)。size はサイズ (px)。
class StampShapes {
  static const shapes = [
    // 汎用
    ('circle',           '強調丸'),
    ('star',             '星形'),
    ('checkbox',         'チェック'),
    ('cross',            '十字'),
    ('rect',             '矩形'),
    ('ellipse',          '楕円'),
    ('diamond',          '菱形'),
    ('arrow_right',      '矢印→'),
    ('arrow_both',       '両方向'),
    ('arrow_curved',     '曲線矢印'),
    ('divider_t',        'T字仕切り'),
    ('divider_l',        'L字仕切り'),
    // 化学
    ('benzene',          'ベンゼン'),
    ('benzene_kekule',   'ベンゼン(KE)'),
    ('arrow_equilibrium','平衡矢印⇌'),
    ('arrow_double',     '二重矢印→→'),
    ('functional_box',   '官能基枠'),
    // 物理
    ('xy_axis',          '座標軸'),
    ('xyz_axis',         '3D座標軸'),
    ('resistor',         '抵抗'),
    ('capacitor',        'コンデンサ'),
    ('battery',          '電池'),
    ('switch_open',      'スイッチ(開)'),
    // 数学
    ('number_line',      '数直線'),
    ('matrix_bracket',   '行列括弧'),
    ('venn2',            'ベン図'),
  ];

  static const categories = [
    ('汎用', ['circle', 'star', 'checkbox', 'cross', 'rect', 'ellipse', 'diamond',
              'arrow_right', 'arrow_both', 'arrow_curved', 'divider_t', 'divider_l']),
    ('化学', ['benzene', 'benzene_kekule', 'arrow_equilibrium', 'arrow_double', 'functional_box']),
    ('物理', ['xy_axis', 'xyz_axis', 'resistor', 'capacitor', 'battery', 'switch_open']),
    ('数学', ['number_line', 'matrix_bracket', 'venn2']),
  ];

  static void draw(
    Canvas canvas,
    String shapeType,
    Offset center,
    double width,
    double height,
    Color color,
    double opacity, {
    double rotation = 0.0,
    double strokeScale = 1.0,
  }) {
    final baseSize = width > height ? width : height;
    final size = baseSize; // shape helpers use `size`
    final scaleX = baseSize > 0 ? width / baseSize : 1.0;
    final scaleY = baseSize > 0 ? height / baseSize : 1.0;
    final minSize = width < height ? width : height;
    final sw = ((minSize * 0.09).clamp(0.8, 2.5) * strokeScale).clamp(0.5, 8.0);
    final stroke = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0.0) canvas.rotate(rotation * pi / 180.0);
    if (scaleX != 1.0 || scaleY != 1.0) canvas.scale(scaleX, scaleY);
    canvas.translate(-center.dx, -center.dy);

    switch (shapeType) {
      case 'circle':
        canvas.drawCircle(center, size / 2, stroke);
      case 'star':
        canvas.drawPath(_starPath(center, size), stroke);
      case 'checkbox':
        _drawCheckbox(canvas, center, size, stroke);
      case 'cross':
        _drawCross(canvas, center, size, stroke);
      case 'rect':
        canvas.drawRect(Rect.fromCenter(center: center, width: size, height: size * 0.75), stroke);
      case 'diamond':
        canvas.drawPath(_diamondPath(center, size), stroke);
      case 'arrow_right':
        _drawArrow(canvas, Offset(center.dx - size / 2, center.dy), Offset(center.dx + size / 2, center.dy), size, stroke);
      case 'arrow_both':
        _drawArrowBoth(canvas, center, size, stroke);
      case 'benzene':
        _drawBenzene(canvas, center, size, stroke);
      case 'xy_axis':
        _drawXYAxis(canvas, center, size, stroke);
      case 'resistor':
        _drawResistor(canvas, center, size, stroke);
      case 'venn2':
        _drawVenn2(canvas, center, size, stroke);
      case 'ellipse':
        canvas.drawOval(Rect.fromCenter(center: center, width: size, height: size * 0.65), stroke);
      case 'arrow_curved':
        _drawCurvedArrow(canvas, center, size, stroke);
      case 'divider_t':
        _drawDividerT(canvas, center, size, stroke);
      case 'divider_l':
        _drawDividerL(canvas, center, size, stroke);
      case 'benzene_kekule':
        _drawBenzeneKekule(canvas, center, size, stroke);
      case 'arrow_equilibrium':
        _drawEquilibrium(canvas, center, size, stroke);
      case 'arrow_double':
        _drawDoubleArrow(canvas, center, size, stroke);
      case 'functional_box':
        canvas.drawRect(Rect.fromCenter(center: center, width: size * 0.8, height: size * 0.5), stroke);
      case 'xyz_axis':
        _drawXYZAxis(canvas, center, size, stroke);
      case 'capacitor':
        _drawCapacitor(canvas, center, size, stroke);
      case 'battery':
        _drawBattery(canvas, center, size, stroke);
      case 'switch_open':
        _drawSwitchOpen(canvas, center, size, stroke);
      case 'number_line':
        _drawNumberLine(canvas, center, size, stroke);
      case 'matrix_bracket':
        _drawMatrixBracket(canvas, center, size, stroke);
      default:
        canvas.drawCircle(center, size / 4, stroke..style = PaintingStyle.fill);
    }

    canvas.restore();
  }

  static Path _starPath(Offset c, double size) {
    final r = size / 2;
    final inner = r * 0.4;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = -pi / 2 + i * pi / 5;
      final rad = i.isEven ? r : inner;
      final x = c.dx + rad * cos(angle);
      final y = c.dy + rad * sin(angle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    return path..close();
  }

  static Path _diamondPath(Offset c, double size) {
    final h = size / 2;
    return Path()
      ..moveTo(c.dx, c.dy - h)
      ..lineTo(c.dx + h * 0.7, c.dy)
      ..lineTo(c.dx, c.dy + h)
      ..lineTo(c.dx - h * 0.7, c.dy)
      ..close();
  }

  static void _drawCheckbox(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    canvas.drawRect(Rect.fromCenter(center: c, width: size, height: size), p);
    final check = Path()
      ..moveTo(c.dx - h * 0.45, c.dy)
      ..lineTo(c.dx - h * 0.05, c.dy + h * 0.4)
      ..lineTo(c.dx + h * 0.5, c.dy - h * 0.35);
    canvas.drawPath(check, p);
  }

  static void _drawCross(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    canvas.drawLine(Offset(c.dx - h, c.dy), Offset(c.dx + h, c.dy), p);
    canvas.drawLine(Offset(c.dx, c.dy - h), Offset(c.dx, c.dy + h), p);
  }

  static void _drawArrow(Canvas canvas, Offset from, Offset to, double size, Paint p) {
    canvas.drawLine(from, to, p);
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    final hs = size * 0.22;
    canvas.drawLine(to, Offset(to.dx - ux * hs - uy * hs * 0.5, to.dy - uy * hs + ux * hs * 0.5), p);
    canvas.drawLine(to, Offset(to.dx - ux * hs + uy * hs * 0.5, to.dy - uy * hs - ux * hs * 0.5), p);
  }

  static void _drawArrowBoth(Canvas canvas, Offset c, double size, Paint p) {
    final from = Offset(c.dx - size / 2, c.dy);
    final to = Offset(c.dx + size / 2, c.dy);
    canvas.drawLine(from, to, p);
    final hs = size * 0.22;
    // right arrowhead
    canvas.drawLine(to, Offset(to.dx - hs, to.dy - hs * 0.5), p);
    canvas.drawLine(to, Offset(to.dx - hs, to.dy + hs * 0.5), p);
    // left arrowhead
    canvas.drawLine(from, Offset(from.dx + hs, from.dy - hs * 0.5), p);
    canvas.drawLine(from, Offset(from.dx + hs, from.dy + hs * 0.5), p);
  }

  static void _drawBenzene(Canvas canvas, Offset c, double size, Paint p) {
    final r = size / 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = -pi / 2 + i * pi / 3;
      final x = c.dx + r * cos(angle);
      final y = c.dy + r * sin(angle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path..close(), p);
    canvas.drawCircle(c, r * 0.52, p);
  }

  static void _drawXYAxis(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    // X axis →
    _drawArrow(canvas, Offset(c.dx - h, c.dy), Offset(c.dx + h, c.dy), size, p);
    // Y axis ↑ (screen: y decreases going up)
    _drawArrow(canvas, Offset(c.dx, c.dy + h), Offset(c.dx, c.dy - h), size, p);
  }

  static void _drawResistor(Canvas canvas, Offset c, double size, Paint p) {
    final hw = size / 2;
    final hh = size * 0.15;
    // Lead lines
    canvas.drawLine(Offset(c.dx - hw, c.dy), Offset(c.dx - hw * 0.38, c.dy), p);
    canvas.drawLine(Offset(c.dx + hw * 0.38, c.dy), Offset(c.dx + hw, c.dy), p);
    // Resistor body (rectangle)
    canvas.drawRect(Rect.fromCenter(center: c, width: hw * 0.76, height: hh * 2), p);
  }

  static void _drawVenn2(Canvas canvas, Offset c, double size, Paint p) {
    final r = size * 0.36;
    final offset = size * 0.2;
    canvas.drawCircle(Offset(c.dx - offset, c.dy), r, p);
    canvas.drawCircle(Offset(c.dx + offset, c.dy), r, p);
  }

  static void _drawCurvedArrow(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    final path = Path()
      ..moveTo(c.dx - h, c.dy + h * 0.3)
      ..cubicTo(c.dx - h * 0.5, c.dy - h * 0.6, c.dx + h * 0.5, c.dy - h * 0.6, c.dx + h, c.dy + h * 0.3);
    canvas.drawPath(path, p);
    // Bezier tangent at endpoint = P3 - P2 = (0.5h, 0.9h)
    final tx = h * 0.5, ty = h * 0.9;
    final len = sqrt(tx * tx + ty * ty);
    final ux = tx / len, uy = ty / len;
    final hs = size * 0.2;
    final tip = Offset(c.dx + h, c.dy + h * 0.3);
    canvas.drawLine(tip, Offset(tip.dx - ux * hs + uy * hs * 0.5, tip.dy - uy * hs - ux * hs * 0.5), p);
    canvas.drawLine(tip, Offset(tip.dx - ux * hs - uy * hs * 0.5, tip.dy - uy * hs + ux * hs * 0.5), p);
  }

  static void _drawDividerT(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    canvas.drawLine(Offset(c.dx - h, c.dy), Offset(c.dx + h, c.dy), p);
    canvas.drawLine(Offset(c.dx, c.dy), Offset(c.dx, c.dy + h), p);
  }

  static void _drawDividerL(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    canvas.drawLine(Offset(c.dx - h, c.dy), Offset(c.dx, c.dy), p);
    canvas.drawLine(Offset(c.dx, c.dy), Offset(c.dx, c.dy + h), p);
  }

  static void _drawBenzeneKekule(Canvas canvas, Offset c, double size, Paint p) {
    final r = size / 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = -pi / 2 + i * pi / 3;
      final x = c.dx + r * cos(angle);
      final y = c.dy + r * sin(angle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path..close(), p);
    // Alternating double bonds (3 bonds)
    for (int i = 0; i < 3; i++) {
      final a1 = -pi / 2 + i * 2 * pi / 3;
      final a2 = a1 + pi / 3;
      final inner = r * 0.65;
      canvas.drawLine(
        Offset(c.dx + inner * cos(a1), c.dy + inner * sin(a1)),
        Offset(c.dx + inner * cos(a2), c.dy + inner * sin(a2)),
        p,
      );
    }
  }

  static void _drawEquilibrium(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    final gap = size * 0.12;
    final hs = size * 0.2;
    // Top arrow →
    canvas.drawLine(Offset(c.dx - h, c.dy - gap), Offset(c.dx + h, c.dy - gap), p);
    canvas.drawLine(Offset(c.dx + h, c.dy - gap),
        Offset(c.dx + h - hs, c.dy - gap - hs * 0.5), p);
    // Bottom arrow ←
    canvas.drawLine(Offset(c.dx + h, c.dy + gap), Offset(c.dx - h, c.dy + gap), p);
    canvas.drawLine(Offset(c.dx - h, c.dy + gap),
        Offset(c.dx - h + hs, c.dy + gap + hs * 0.5), p);
  }

  static void _drawDoubleArrow(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    final gap = size * 0.12;
    _drawArrow(canvas, Offset(c.dx - h, c.dy - gap), Offset(c.dx + h, c.dy - gap), size, p);
    _drawArrow(canvas, Offset(c.dx - h, c.dy + gap), Offset(c.dx + h, c.dy + gap), size, p);
  }

  static void _drawXYZAxis(Canvas canvas, Offset c, double size, Paint p) {
    final h = size * 0.45;
    final iso = size * 0.28;
    // Z axis ↑
    _drawArrow(canvas, Offset(c.dx, c.dy + h), Offset(c.dx, c.dy - h), size, p);
    // X axis →
    _drawArrow(canvas, Offset(c.dx, c.dy), Offset(c.dx + h, c.dy), size, p);
    // Y axis (isometric, lower-left)
    _drawArrow(canvas, Offset(c.dx, c.dy), Offset(c.dx - iso, c.dy + iso), size, p);
  }

  static void _drawCapacitor(Canvas canvas, Offset c, double size, Paint p) {
    final hw = size / 2;
    final gap = size * 0.08;
    final ph = size * 0.3;
    canvas.drawLine(Offset(c.dx - hw, c.dy), Offset(c.dx - gap, c.dy), p);
    canvas.drawLine(Offset(c.dx + gap, c.dy), Offset(c.dx + hw, c.dy), p);
    canvas.drawLine(Offset(c.dx - gap, c.dy - ph), Offset(c.dx - gap, c.dy + ph), p);
    canvas.drawLine(Offset(c.dx + gap, c.dy - ph), Offset(c.dx + gap, c.dy + ph), p);
  }

  static void _drawBattery(Canvas canvas, Offset c, double size, Paint p) {
    final hw = size / 2;
    final gap = size * 0.1;
    canvas.drawLine(Offset(c.dx - hw, c.dy), Offset(c.dx - gap * 0.5, c.dy), p);
    canvas.drawLine(Offset(c.dx + gap * 0.5, c.dy), Offset(c.dx + hw, c.dy), p);
    // Long line (positive)
    canvas.drawLine(Offset(c.dx - gap * 0.5, c.dy - size * 0.3),
        Offset(c.dx - gap * 0.5, c.dy + size * 0.3), p);
    // Short line (negative)
    canvas.drawLine(Offset(c.dx + gap * 0.5, c.dy - size * 0.15),
        Offset(c.dx + gap * 0.5, c.dy + size * 0.15), p);
  }

  static void _drawSwitchOpen(Canvas canvas, Offset c, double size, Paint p) {
    final hw = size / 2;
    final dotR = size * 0.08;
    final filled = Paint()
      ..color = p.color
      ..style = PaintingStyle.fill;
    canvas.drawLine(Offset(c.dx - hw, c.dy), Offset(c.dx - hw * 0.3, c.dy), p);
    canvas.drawLine(Offset(c.dx + hw * 0.3, c.dy), Offset(c.dx + hw, c.dy), p);
    canvas.drawCircle(Offset(c.dx - hw * 0.3, c.dy), dotR, filled);
    canvas.drawCircle(Offset(c.dx + hw * 0.3, c.dy), dotR, filled);
    // Angled bridge
    canvas.drawLine(Offset(c.dx - hw * 0.3, c.dy),
        Offset(c.dx + hw * 0.3, c.dy - size * 0.3), p);
  }

  static void _drawNumberLine(Canvas canvas, Offset c, double size, Paint p) {
    final h = size / 2;
    _drawArrow(canvas, Offset(c.dx - h, c.dy), Offset(c.dx + h, c.dy), size, p);
    final tickH = size * 0.12;
    canvas.drawLine(Offset(c.dx, c.dy - tickH), Offset(c.dx, c.dy + tickH), p);
    for (final frac in [-0.5, 0.5]) {
      canvas.drawLine(
        Offset(c.dx + h * frac, c.dy - tickH * 0.6),
        Offset(c.dx + h * frac, c.dy + tickH * 0.6),
        p,
      );
    }
  }

  static void _drawMatrixBracket(Canvas canvas, Offset c, double size, Paint p) {
    final hw = size * 0.35;
    final hh = size * 0.45;
    final bw = size * 0.12;
    // Left bracket [
    canvas.drawLine(Offset(c.dx - hw + bw, c.dy - hh), Offset(c.dx - hw, c.dy - hh), p);
    canvas.drawLine(Offset(c.dx - hw, c.dy - hh), Offset(c.dx - hw, c.dy + hh), p);
    canvas.drawLine(Offset(c.dx - hw, c.dy + hh), Offset(c.dx - hw + bw, c.dy + hh), p);
    // Right bracket ]
    canvas.drawLine(Offset(c.dx + hw - bw, c.dy - hh), Offset(c.dx + hw, c.dy - hh), p);
    canvas.drawLine(Offset(c.dx + hw, c.dy - hh), Offset(c.dx + hw, c.dy + hh), p);
    canvas.drawLine(Offset(c.dx + hw, c.dy + hh), Offset(c.dx + hw - bw, c.dy + hh), p);
  }
}
