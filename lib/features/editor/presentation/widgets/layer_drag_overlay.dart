import 'dart:math' show sqrt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/print_constants.dart';
import '../../../../shared/models/layer_config.dart';
import '../../../../shared/models/layer_region.dart';
import '../../../../shared/painters/painter_utils.dart';
import '../../domain/editor_notifier.dart';
import 'layer_controls/stamp_controls.dart' show selectedStampIndexProvider, activeStampShapeProvider, activeStampWidthProvider, activeStampHeightProvider;

/// true の間、IV の pan/zoom を無効化してレイヤーをドラッグ/ピンチ操作できる。
final isLayerDragModeProvider = StateProvider<bool>((_) => false);

// ─────────────────────────────────────────────────────────────────────────────
// IV 内 overlayChild — ボーダー描画 ＋ ドラッグモード時の GestureDetector
// ─────────────────────────────────────────────────────────────────────────────

class LayerDragPaperOverlay extends ConsumerStatefulWidget {
  const LayerDragPaperOverlay({
    required this.state,
    required this.notifier,
    required this.paperKey,
  });

  final EditorState state;
  final EditorNotifier notifier;
  final GlobalKey paperKey;

  @override
  ConsumerState<LayerDragPaperOverlay> createState() =>
      _LayerDragPaperOverlayState();
}

class _LayerDragPaperOverlayState
    extends ConsumerState<LayerDragPaperOverlay> {
  // LayoutBuilder で更新した最終コンテンツ矩形（コールバック内で使う）
  Rect _lastContent = Rect.zero;

  // ドラッグ開始時のレイヤー位置・サイズ
  double? _initX, _initY, _initW, _initH;
  // ドラッグ開始時のポインター位置（コンテンツ比率空間）
  double? _initPtrX, _initPtrY;

  /// globalFocalPoint を紙面ローカル座標に変換してからコンテンツ比率へ変換する。
  /// GD の位置に依存しないため、GD をレイヤー矩形に限定しても正確に動作する。
  Offset? _toContentRatio(Offset globalFocalPoint) {
    final paperRb = widget.paperKey.currentContext?.findRenderObject() as RenderBox?;
    if (paperRb == null) return null;
    final paperLocal = paperRb.globalToLocal(globalFocalPoint);
    final c = _lastContent;
    if (c.width == 0 || c.height == 0) return null;
    return Offset(
      (paperLocal.dx - c.left) / c.width,
      (paperLocal.dy - c.top) / c.height,
    );
  }

  @override
  void didUpdateWidget(LayerDragPaperOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.activeLayerIndex != widget.state.activeLayerIndex &&
        _initX != null) {
      // 別レイヤーに切り替わったら進行中のドラッグを確定してリセット
      widget.notifier.commitLayerRegion(oldWidget.state.activeLayerIndex);
      _initX = _initY = _initW = _initH = null;
      _initPtrX = _initPtrY = null;
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    final layer = widget.state.activeLayer;
    if (layer == null) return;
    _initX = layer.xRatio;
    _initY = layer.yRatio;
    _initW = layer.widthRatio;
    _initH = layer.heightRatio;
    final ptr = _toContentRatio(d.focalPoint);
    if (ptr == null) return;
    _initPtrX = ptr.dx;
    _initPtrY = ptr.dy;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_initX == null) return;
    final idx = widget.state.activeLayerIndex;
    if (d.pointerCount >= 2) {
      widget.notifier.updateLayerRegion(
        idx,
        widthRatio: (_initW! * d.scale).clamp(0.05, 1.0),
        heightRatio: (_initH! * d.scale).clamp(0.05, 1.0),
      );
    } else {
      final ptr = _toContentRatio(d.focalPoint);
      if (ptr == null) return;
      widget.notifier.updateLayerRegion(
        idx,
        xRatio: _initX! + (ptr.dx - _initPtrX!),
        yRatio: _initY! + (ptr.dy - _initPtrY!),
      );
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_initX != null) {
      widget.notifier.commitLayerRegion(widget.state.activeLayerIndex);
      _initX = _initY = _initW = _initH = null;
      _initPtrX = _initPtrY = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDragMode = ref.watch(isLayerDragModeProvider);
    final layer = widget.state.activeLayer;
    if (layer == null) return const SizedBox.expand();

    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final scale = scaleFactor(w, widget.state.pageConfig.effectiveWidthMm);
      final content =
          contentRect(Size(w, h), widget.state.pageConfig, scale);
      // LayoutBuilder は build 内で実行される → コールバックより必ず先に更新される
      _lastContent = content;

      final region = LayerRegion(
        x: layer.xRatio,
        y: layer.yRatio,
        width: layer.widthRatio,
        height: layer.heightRatio,
      );
      final layerRect = layerRegionRect(content, region);
      return Stack(
        children: [
          // 破線ボーダー（常に表示、ドラッグモード時は強調）
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _LayerBorderPainter(
                    rect: layerRect, active: isDragMode),
              ),
            ),
          ),
          // ドラッグモード時はレイヤー矩形のみ opaque GD → 矩形外は IV に流れる
          if (isDragMode)
            Positioned(
              left: layerRect.left,
              top: layerRect.top,
              width: layerRect.width,
              height: layerRect.height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
              ),
            ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IV 外 Positioned.fill — 長押し検出（常に translucent で IV を妨げない）
// ─────────────────────────────────────────────────────────────────────────────

class LayerLongPressOverlay extends ConsumerStatefulWidget {
  const LayerLongPressOverlay({
    super.key,
    required this.state,
    required this.notifier,
    required this.paperKey,
  });

  final EditorState state;
  final EditorNotifier notifier;
  final GlobalKey paperKey;

  @override
  ConsumerState<LayerLongPressOverlay> createState() =>
      _LayerLongPressOverlayState();
}

class _LayerLongPressOverlayState
    extends ConsumerState<LayerLongPressOverlay> {
  // レイヤードラッグ状態
  bool _isDraggingLayer = false;
  int? _dragLayerIndex;
  double? _initLayerX, _initLayerY;
  Offset? _initPaperPos;

  // スタンプドラッグ状態
  static const _snapThreshold = 0.012;
  static const _stampHitRadius = 24.0;
  bool _isDraggingStamp = false;
  int? _dragStampIndex;
  Offset? _stampDragOffset;
  Map<int, (double, double)> _stampGroupInitPos = {};

  RenderBox? get _paperRb =>
      widget.paperKey.currentContext?.findRenderObject() as RenderBox?;

  Offset? _toPaper(Offset local) {
    final my = context.findRenderObject() as RenderBox?;
    final paper = _paperRb;
    if (my == null || paper == null) return null;
    return paper.globalToLocal(my.localToGlobal(local));
  }

  Offset? _paperToContentRatio(Offset paperLocal) {
    final rb = _paperRb;
    if (rb == null) return null;
    final scale = scaleFactor(rb.size.width, widget.state.pageConfig.effectiveWidthMm);
    final c = contentRect(rb.size, widget.state.pageConfig, scale);
    if (c.width == 0 || c.height == 0) return null;
    return Offset((paperLocal.dx - c.left) / c.width, (paperLocal.dy - c.top) / c.height);
  }

  /// 全レイヤーを逆順でヒットテストしてインデックスを返す。
  /// スタンプレイヤーはアイテムの近傍のみヒット。
  int? _hitTestLayer(Offset local) {
    final paperPos = _toPaper(local);
    final rb = _paperRb;
    if (paperPos == null || rb == null) return null;
    final scale = scaleFactor(rb.size.width, widget.state.pageConfig.effectiveWidthMm);
    final content = contentRect(rb.size, widget.state.pageConfig, scale);
    final layers = widget.state.layers;

    for (var i = layers.length - 1; i >= 0; i--) {
      final layer = layers[i];
      if (!layer.isVisible || layer.layerType != 'stamp') continue;
      final config = layer.config;
      if (config is! StampLayerConfig) continue;
      for (final item in config.items) {
        final cx = item.xRatio * rb.size.width;
        final cy = item.yRatio * rb.size.height;
        if ((paperPos - Offset(cx, cy)).distance < 36) return i;
      }
    }

    for (var i = layers.length - 1; i >= 0; i--) {
      final layer = layers[i];
      if (!layer.isVisible || layer.layerType == 'stamp') continue;
      final region = LayerRegion(
        x: layer.xRatio, y: layer.yRatio,
        width: layer.widthRatio, height: layer.heightRatio,
      );
      if (layerRegionRect(content, region).contains(paperPos)) return i;
    }
    return null;
  }

  /// アクティブなスタンプレイヤー内のアイテムをヒットテスト。
  int? _hitTestStampItem(Offset local) {
    final paper = _toPaper(local);
    final rb = _paperRb;
    if (paper == null || rb == null) return null;
    final stampLayer = widget.state.activeLayer;
    if (stampLayer?.config is! StampLayerConfig) return null;
    final items = (stampLayer!.config as StampLayerConfig).items;
    for (var i = items.length - 1; i >= 0; i--) {
      final cx = items[i].xRatio * rb.size.width;
      final cy = items[i].yRatio * rb.size.height;
      if ((paper - Offset(cx, cy)).distance < _stampHitRadius) return i;
    }
    return null;
  }

  void _resetDragState() {
    _isDraggingLayer = false;
    _dragLayerIndex = null;
    _initLayerX = _initLayerY = null;
    _initPaperPos = null;
    _isDraggingStamp = false;
    _dragStampIndex = null;
    _stampDragOffset = null;
    _stampGroupInitPos = {};
  }

  // ── GestureDetector コールバック ────────────────────────────────────────────

  void _onLongPressStart(LongPressStartDetails d) {
    final hit = _hitTestLayer(d.localPosition);
    if (hit == null || hit >= widget.state.layers.length) return;

    final isStamp = widget.state.layers[hit].layerType == 'stamp';

    if (hit != widget.state.activeLayerIndex) {
      if (!isStamp) {
        widget.notifier.setActiveLayerIndexForDrag(hit);
      } else {
        widget.notifier.setActiveLayerIndex(hit);
      }
    }

    HapticFeedback.mediumImpact();

    if (!isStamp) {
      // ── レイヤードラッグ ──
      ref.read(isLayerDragModeProvider.notifier).state = true;
      final layer = widget.state.layers[hit];
      final paperPos = _toPaper(d.localPosition);
      if (paperPos != null) {
        _isDraggingLayer = true;
        _dragLayerIndex = hit;
        _initLayerX = layer.xRatio;
        _initLayerY = layer.yRatio;
        _initPaperPos = paperPos;
      }
    } else {
      // ── スタンプアイテムドラッグ ──
      final stampIdx = _hitTestStampItem(d.localPosition);
      if (stampIdx == null) return;
      ref.read(selectedStampIndexProvider.notifier).state = stampIdx;
      final paper = _toPaper(d.localPosition);
      final rb = _paperRb;
      if (paper == null || rb == null) return;
      final config = widget.state.layers[hit].config as StampLayerConfig;
      final item = config.items[stampIdx];
      _isDraggingStamp = true;
      _dragStampIndex = stampIdx;
      _stampDragOffset =
          Offset(item.xRatio * rb.size.width, item.yRatio * rb.size.height) - paper;
      final groupId = item.groupId;
      _stampGroupInitPos = {
        for (var i = 0; i < config.items.length; i++)
          if (i == stampIdx || (groupId != null && config.items[i].groupId == groupId))
            i: (config.items[i].xRatio, config.items[i].yRatio),
      };
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d) {
    if (_isDraggingLayer) _updateLayerDrag(d.localPosition);
    if (_isDraggingStamp) _updateStampDrag(d.localPosition);
  }

  void _updateLayerDrag(Offset local) {
    if (_initLayerX == null || _initPaperPos == null) return;
    final paperPos = _toPaper(local);
    if (paperPos == null) return;
    final initRatio = _paperToContentRatio(_initPaperPos!);
    final currRatio = _paperToContentRatio(paperPos);
    if (initRatio == null || currRatio == null) return;
    widget.notifier.updateLayerRegion(
      _dragLayerIndex!,
      xRatio: _initLayerX! + (currRatio.dx - initRatio.dx),
      yRatio: _initLayerY! + (currRatio.dy - initRatio.dy),
    );
  }

  void _updateStampDrag(Offset local) {
    if (_dragStampIndex == null) return;
    final paper = _toPaper(local);
    final rb = _paperRb;
    if (paper == null || rb == null) return;
    final stampLayer = widget.state.activeLayer;
    if (stampLayer?.config is! StampLayerConfig) return;
    final config = stampLayer!.config as StampLayerConfig;
    final idx = _dragStampIndex!;
    final items = config.items.toList();
    final target = paper + (_stampDragOffset ?? Offset.zero);
    var xRatio = (target.dx / rb.size.width).clamp(0.0, 1.0);
    var yRatio = (target.dy / rb.size.height).clamp(0.0, 1.0);

    final groupId = items[idx].groupId;
    for (var i = 0; i < items.length; i++) {
      if (i == idx) continue;
      if (groupId != null && items[i].groupId == groupId) continue;
      if ((xRatio - items[i].xRatio).abs() < _snapThreshold) xRatio = items[i].xRatio;
      if ((yRatio - items[i].yRatio).abs() < _snapThreshold) yRatio = items[i].yRatio;
    }

    items[idx] = items[idx].copyWith(xRatio: xRatio, yRatio: yRatio);

    if (groupId != null) {
      final init = _stampGroupInitPos[idx];
      if (init != null) {
        final dispX = xRatio - init.$1;
        final dispY = yRatio - init.$2;
        for (final e in _stampGroupInitPos.entries) {
          if (e.key == idx) continue;
          items[e.key] = items[e.key].copyWith(
            xRatio: (e.value.$1 + dispX).clamp(0.0, 1.0),
            yRatio: (e.value.$2 + dispY).clamp(0.0, 1.0),
          );
        }
      }
    }
    widget.notifier.previewStampItems(items);
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    if (_isDraggingLayer) widget.notifier.commitLayerRegion(_dragLayerIndex!);
    if (_isDraggingStamp) widget.notifier.commitStampItems();
    _resetDragState();
  }

  void _onLongPressCancel() {
    if (_isDraggingLayer) widget.notifier.commitLayerRegion(_dragLayerIndex!);
    if (_isDraggingStamp) widget.notifier.commitStampItems();
    _resetDragState();
  }

  /// タップ: スタンプ配置/選択解除/ドラッグモード解除
  void _onTapUp(TapUpDetails d) {
    if (!mounted) return;
    final isStampActive = widget.state.activeLayer?.config is StampLayerConfig;
    final isEditMode = ref.read(selectedStampIndexProvider) != null;

    if (isStampActive) {
      if (!isEditMode) {
        if (_hitTestStampItem(d.localPosition) == null) _placeStamp(d.localPosition);
      } else {
        if (_hitTestStampItem(d.localPosition) == null) {
          ref.read(selectedStampIndexProvider.notifier).state = null;
        }
      }
    }

    if (ref.read(isLayerDragModeProvider)) {
      ref.read(isLayerDragModeProvider.notifier).state = false;
    }
  }

  void _placeStamp(Offset local) {
    final paper = _toPaper(local);
    final rb = _paperRb;
    if (paper == null || rb == null) return;
    final xRatio = (paper.dx / rb.size.width).clamp(0.0, 1.0);
    final yRatio = (paper.dy / rb.size.height).clamp(0.0, 1.0);
    final shape = ref.read(activeStampShapeProvider);
    final widthMm = ref.read(activeStampWidthProvider);
    final heightMm = ref.read(activeStampHeightProvider);
    widget.notifier.addStampItem(xRatio, yRatio, shape, widthMm, heightMm);
    final stampLayer = widget.state.activeLayer;
    if (stampLayer?.config is StampLayerConfig) {
      ref.read(selectedStampIndexProvider.notifier).state =
          (stampLayer!.config as StampLayerConfig).items.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      onTapUp: _onTapUp,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

class _LayerBorderPainter extends CustomPainter {
  const _LayerBorderPainter({required this.rect, required this.active});
  final Rect rect;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: active ? 0.75 : 0.25)
      ..strokeWidth = active ? 1.5 : 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedRect(canvas, rect, paint);

    if (active) {
      final fillPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      for (final corner in [
        rect.topLeft,
        rect.topRight,
        rect.bottomLeft,
        rect.bottomRight,
      ]) {
        canvas.drawRect(
          Rect.fromCenter(center: corner, width: 8, height: 8),
          fillPaint,
        );
      }
    }
  }

  static void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashLen = 5.0;
    const gapLen = 3.0;
    for (final (s, e) in [
      (rect.topLeft, rect.topRight),
      (rect.topRight, rect.bottomRight),
      (rect.bottomRight, rect.bottomLeft),
      (rect.bottomLeft, rect.topLeft),
    ]) {
      final dx = e.dx - s.dx;
      final dy = e.dy - s.dy;
      final len = sqrt(dx * dx + dy * dy);
      if (len == 0) continue;
      final ux = dx / len;
      final uy = dy / len;
      double pos = 0;
      bool on = true;
      while (pos < len) {
        final next = (pos + (on ? dashLen : gapLen)).clamp(0.0, len);
        if (on) {
          canvas.drawLine(
            Offset(s.dx + ux * pos, s.dy + uy * pos),
            Offset(s.dx + ux * next, s.dy + uy * next),
            paint,
          );
        }
        pos = next;
        on = !on;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LayerBorderPainter old) =>
      old.rect != rect || old.active != active;
}
