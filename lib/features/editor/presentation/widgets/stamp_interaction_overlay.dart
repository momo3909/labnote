import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/layer_config.dart';
import '../../domain/editor_notifier.dart';
import 'layer_controls/stamp_controls.dart';

/// 紙面 Stack 内に配置（overlayChild）。
/// 選択リング描画 ＋ 編集モード時にスタンプごとの GestureDetector を重ねる。
/// IV の子ツリー内にある GD はジェスチャーアリーナで IV より優先されるため、
/// スタンプ上では GD が drag/pinch を処理し、空白では IV が pan/zoom を処理する。
class StampPaperOverlay extends ConsumerStatefulWidget {
  const StampPaperOverlay({
    required this.config,
    required this.notifier,
    required this.paperKey,
  });

  final StampLayerConfig config;
  final EditorNotifier notifier;
  final GlobalKey paperKey;

  @override
  ConsumerState<StampPaperOverlay> createState() => _StampPaperOverlayState();
}

class _StampPaperOverlayState extends ConsumerState<StampPaperOverlay> {
  int? _activeIndex;
  Offset? _dragOffset;
  // index → (xRatio, yRatio, effectiveWidthMm, effectiveHeightMm) at drag start
  Map<int, (double, double, double, double)> _groupInitialState = {};

  List<double> _hGuides = [];
  List<double> _vGuides = [];

  RenderBox? get _paperRb =>
      widget.paperKey.currentContext?.findRenderObject() as RenderBox?;

  Offset? _globalToPaper(Offset global) {
    final rb = _paperRb;
    if (rb == null) return null;
    return rb.globalToLocal(global);
  }

  void _onScaleStart(ScaleStartDetails d, int idx) {
    _activeIndex = idx;
    ref.read(selectedStampIndexProvider.notifier).state = idx;
    final paper = _globalToPaper(d.focalPoint);
    final rb = _paperRb;
    if (paper != null && rb != null) {
      final item = widget.config.items[idx];
      _dragOffset =
          Offset(item.xRatio * rb.size.width, item.yRatio * rb.size.height) -
              paper;
    }

    final groupId = widget.config.items[idx].groupId;
    _groupInitialState = {
      for (var i = 0; i < widget.config.items.length; i++)
        if (i == idx || (groupId != null && widget.config.items[i].groupId == groupId))
          i: (
            widget.config.items[i].xRatio,
            widget.config.items[i].yRatio,
            widget.config.items[i].widthMm > 0
                ? widget.config.items[i].widthMm
                : widget.config.items[i].sizeMm,
            widget.config.items[i].heightMm > 0
                ? widget.config.items[i].heightMm
                : widget.config.items[i].sizeMm,
          ),
    };
  }

  static const _snapThreshold = 0.012;

  void _onScaleUpdate(ScaleUpdateDetails d, int idx) {
    if (_activeIndex == null) return;
    final rb = _paperRb;
    if (rb == null) return;
    final items = widget.config.items.toList();

    if (d.pointerCount >= 2) {
      for (final e in _groupInitialState.entries) {
        items[e.key] = items[e.key].copyWith(
          widthMm: (e.value.$3 * d.scale).clamp(2.0, 100.0),
          heightMm: (e.value.$4 * d.scale).clamp(2.0, 100.0),
        );
      }
      _hGuides = [];
      _vGuides = [];
    } else {
      final paper = _globalToPaper(d.focalPoint);
      if (paper == null) return;
      final target = paper + (_dragOffset ?? Offset.zero);
      var xRatio = (target.dx / rb.size.width).clamp(0.0, 1.0);
      var yRatio = (target.dy / rb.size.height).clamp(0.0, 1.0);

      final groupId = items[idx].groupId;
      final hGuides = <double>[];
      final vGuides = <double>[];
      for (var i = 0; i < items.length; i++) {
        if (i == idx) continue;
        if (groupId != null && items[i].groupId == groupId) continue;
        final other = items[i];
        if ((xRatio - other.xRatio).abs() < _snapThreshold) {
          xRatio = other.xRatio;
          vGuides.add(other.xRatio);
        }
        if ((yRatio - other.yRatio).abs() < _snapThreshold) {
          yRatio = other.yRatio;
          hGuides.add(other.yRatio);
        }
      }
      _hGuides = hGuides;
      _vGuides = vGuides;

      final initIdx = _groupInitialState[idx];
      final dispX = initIdx != null ? xRatio - initIdx.$1 : 0.0;
      final dispY = initIdx != null ? yRatio - initIdx.$2 : 0.0;

      items[idx] = items[idx].copyWith(xRatio: xRatio, yRatio: yRatio);

      if (groupId != null) {
        for (final e in _groupInitialState.entries) {
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

  void _onScaleEnd(int idx) {
    if (_activeIndex != null) {
      widget.notifier.commitStampItems();
      _activeIndex = null;
      _dragOffset = null;
      _groupInitialState = {};
      _hGuides = [];
      _vGuides = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIdx = ref.watch(selectedStampIndexProvider);
    final items = widget.config.items;
    const hitSize = 48.0;

    final selectedGroupId = selectedIdx != null && selectedIdx < items.length
        ? items[selectedIdx].groupId
        : null;

    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Stack(
        children: [
          Positioned.fill(
            key: const ValueKey('ring'),
            child: IgnorePointer(
              child: selectedIdx != null && selectedIdx < items.length
                  ? CustomPaint(
                      painter: _SelectionRingPainter(
                        item: items[selectedIdx],
                        groupItems: selectedGroupId != null
                            ? items.where((e) => e.groupId == selectedGroupId).toList()
                            : null,
                      ),
                    )
                  : const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            key: const ValueKey('guides'),
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GuidePainter(hGuides: _hGuides, vGuides: _vGuides),
              ),
            ),
          ),
          if (selectedIdx != null)
            ...items.asMap().entries
                .where((e) =>
                    e.key == selectedIdx ||
                    (selectedGroupId != null &&
                        e.value.groupId == selectedGroupId))
                .map((e) {
              final i = e.key;
              final item = e.value;
              final cx = item.xRatio * w;
              final cy = item.yRatio * h;
              return Positioned(
                key: ValueKey('gd_$i'),
                left: cx - hitSize / 2,
                top: cy - hitSize / 2,
                width: hitSize,
                height: hitSize,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (d) => _onScaleStart(d, i),
                  onScaleUpdate: (d) => _onScaleUpdate(d, i),
                  onScaleEnd: (_) => _onScaleEnd(i),
                  child: const SizedBox.expand(),
                ),
              );
            }),
        ],
      );
    });
  }
}

/// IV 外側の Positioned.fill に配置。ジェスチャーアリーナに参加しない Listener。
/// 担当: 長押しでスタンプ選択、タップで配置/選択解除のみ。
/// drag/pinch は StampPaperOverlay（IV 子ツリー内）が担う。
class StampTapLongPressOverlay extends ConsumerStatefulWidget {
  const StampTapLongPressOverlay({
    required this.config,
    required this.notifier,
    required this.paperKey,
  });

  final StampLayerConfig config;
  final EditorNotifier notifier;
  final GlobalKey paperKey;

  @override
  ConsumerState<StampTapLongPressOverlay> createState() =>
      _StampTapLongPressOverlayState();
}

class _StampTapLongPressOverlayState
    extends ConsumerState<StampTapLongPressOverlay> {
  // 長押し→そのままドラッグのための状態
  bool _isDragging = false;
  int? _dragItemIndex;
  Offset? _dragOffset;                        // スタンプ中心と指の差分（紙面px）
  Map<int, (double, double)> _groupInitPos = {}; // グループ各アイテムの初期 (xRatio, yRatio)

  static const _snapThreshold = 0.012;

  RenderBox? get _paperRb =>
      widget.paperKey.currentContext?.findRenderObject() as RenderBox?;

  Offset? _toPaper(Offset local) {
    final my = context.findRenderObject() as RenderBox?;
    final paper = _paperRb;
    if (my == null || paper == null) return null;
    return paper.globalToLocal(my.localToGlobal(local));
  }

  int? _hitTest(Offset local) {
    final paper = _toPaper(local);
    final rb = _paperRb;
    if (paper == null || rb == null) return null;
    for (var i = widget.config.items.length - 1; i >= 0; i--) {
      final item = widget.config.items[i];
      final cx = item.xRatio * rb.size.width;
      final cy = item.yRatio * rb.size.height;
      if ((paper - Offset(cx, cy)).distance < 24) return i;
    }
    return null;
  }

  void _resetDragState() {
    _isDragging = false;
    _dragItemIndex = null;
    _dragOffset = null;
    _groupInitPos = {};
  }

  // ── GestureDetector コールバック ────────────────────────────────────────────

  void _onLongPressStart(LongPressStartDetails d) {
    final hit = _hitTest(d.localPosition);
    if (hit == null) return;

    ref.read(selectedStampIndexProvider.notifier).state = hit;
    HapticFeedback.mediumImpact();

    // 長押し開始時の情報を記録して即時ドラッグを開始
    final paper = _toPaper(d.localPosition);
    final rb = _paperRb;
    if (paper == null || rb == null) return;

    final item = widget.config.items[hit];
    _isDragging = true;
    _dragItemIndex = hit;
    _dragOffset =
        Offset(item.xRatio * rb.size.width, item.yRatio * rb.size.height) - paper;

    final groupId = item.groupId;
    _groupInitPos = {
      for (var i = 0; i < widget.config.items.length; i++)
        if (i == hit || (groupId != null && widget.config.items[i].groupId == groupId))
          i: (widget.config.items[i].xRatio, widget.config.items[i].yRatio),
    };
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d) {
    if (!_isDragging || _dragItemIndex == null) return;
    final paper = _toPaper(d.localPosition);
    final rb = _paperRb;
    if (paper == null || rb == null) return;

    final idx = _dragItemIndex!;
    final items = widget.config.items.toList();
    final target = paper + (_dragOffset ?? Offset.zero);
    var xRatio = (target.dx / rb.size.width).clamp(0.0, 1.0);
    var yRatio = (target.dy / rb.size.height).clamp(0.0, 1.0);

    // スナップ
    final groupId = items[idx].groupId;
    for (var i = 0; i < items.length; i++) {
      if (i == idx) continue;
      if (groupId != null && items[i].groupId == groupId) continue;
      if ((xRatio - items[i].xRatio).abs() < _snapThreshold) xRatio = items[i].xRatio;
      if ((yRatio - items[i].yRatio).abs() < _snapThreshold) yRatio = items[i].yRatio;
    }

    items[idx] = items[idx].copyWith(xRatio: xRatio, yRatio: yRatio);

    // グループドラッグ
    if (groupId != null) {
      final init = _groupInitPos[idx];
      if (init != null) {
        final dispX = xRatio - init.$1;
        final dispY = yRatio - init.$2;
        for (final e in _groupInitPos.entries) {
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
    if (_isDragging) widget.notifier.commitStampItems();
    _resetDragState();
  }

  void _onLongPressCancel() {
    if (_isDragging) widget.notifier.commitStampItems();
    _resetDragState();
  }

  /// 短いタップ: スタンプ配置 or 選択解除
  void _onTapUp(TapUpDetails d) {
    final isEditMode = ref.read(selectedStampIndexProvider) != null;
    final hit = _hitTest(d.localPosition);
    if (!isEditMode) {
      if (hit == null) _placeStamp(d.localPosition);
    } else {
      if (hit == null) ref.read(selectedStampIndexProvider.notifier).state = null;
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
    ref.read(selectedStampIndexProvider.notifier).state =
        widget.config.items.length;
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

class _GuidePainter extends CustomPainter {
  const _GuidePainter({required this.hGuides, required this.vGuides});
  final List<double> hGuides;
  final List<double> vGuides;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.75)
      ..strokeWidth = 1.0;
    for (final y in hGuides) {
      final dy = y * size.height;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
    for (final x in vGuides) {
      final dx = x * size.width;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter old) =>
      old.hGuides != hGuides || old.vGuides != vGuides;
}

class _SelectionRingPainter extends CustomPainter {
  const _SelectionRingPainter({required this.item, this.groupItems});
  final StampItem item;
  final List<StampItem>? groupItems;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final targets = groupItems ?? [item];
    for (final t in targets) {
      canvas.drawCircle(Offset(t.xRatio * size.width, t.yRatio * size.height), 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionRingPainter old) =>
      old.item != item || old.groupItems != groupItems;
}
