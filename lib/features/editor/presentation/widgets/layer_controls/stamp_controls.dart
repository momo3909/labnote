import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../../../shared/painters/stamp_shapes.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

final activeStampShapeProvider = StateProvider<String>((_) => 'circle');
final activeStampWidthProvider = StateProvider<double>((_) => 8.0);
final activeStampHeightProvider = StateProvider<double>((_) => 8.0);
final activeStampAspectLockedProvider = StateProvider<bool>((_) => true);
final selectedStampIndexProvider = StateProvider<int?>((_) => null);

const _stampColorSwatches = [
  '#1A1A2E', '#1565C0', '#B71C1C', '#1B5E20',
  '#4A148C', '#E65100', '#37474F', '#F57F17',
];

class StampControls extends ConsumerWidget {
  const StampControls({super.key, required this.config, required this.notifier});

  final StampLayerConfig config;
  final EditorNotifier notifier;

  Future<void> _showGridDialog(
      BuildContext context, WidgetRef ref, String shape, double widthMm, double heightMm) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _GridDialog(
        shape: shape,
        widthMm: widthMm,
        heightMm: heightMm,
        onConfirm: ({required cols, required rows, required hSpacing, required vSpacing}) {
          notifier.addStampGrid(
            shapeType: shape,
            widthMm: widthMm,
            heightMm: heightMm,
            columns: cols,
            rows: rows,
            hSpacingMm: hSpacing,
            vSpacingMm: vSpacing,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedShape = ref.watch(activeStampShapeProvider);
    final activeW = ref.watch(activeStampWidthProvider);
    final activeH = ref.watch(activeStampHeightProvider);
    final aspectLocked = ref.watch(activeStampAspectLockedProvider);
    final selectedIndex = ref.watch(selectedStampIndexProvider);
    final hasSelection = selectedIndex != null && selectedIndex < config.items.length;
    final selectedItem = hasSelection ? config.items[selectedIndex] : null;
    final isGrouped = selectedItem?.groupId != null;

    // 選択中スタンプの effective w/h（0 → sizeMm フォールバック）
    final currentW = hasSelection
        ? (selectedItem!.widthMm > 0 ? selectedItem.widthMm : selectedItem.sizeMm)
        : activeW;
    final currentH = hasSelection
        ? (selectedItem!.heightMm > 0 ? selectedItem.heightMm : selectedItem.sizeMm)
        : activeH;

    void updateSize(double w, double h) {
      if (hasSelection) {
        final groupId = selectedItem!.groupId;
        final items = config.items.toList();
        for (var i = 0; i < items.length; i++) {
          if (i == selectedIndex || (groupId != null && items[i].groupId == groupId)) {
            items[i] = items[i].copyWith(widthMm: w, heightMm: h);
          }
        }
        notifier.previewStampItems(items);
      } else {
        ref.read(activeStampWidthProvider.notifier).state = w;
        ref.read(activeStampHeightProvider.notifier).state = h;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 幅スライダー
        Row(
          children: [
            Expanded(
              child: buildSliderRow(
                label: '幅',
                value: currentW,
                min: 2.0,
                max: 100.0,
                onChanged: (v) {
                  final newH = aspectLocked ? (v * currentH / currentW).clamp(2.0, 100.0) : currentH;
                  updateSize(v, newH);
                },
                onChangeEnd: hasSelection ? (_) => notifier.commitStampItems() : null,
              ),
            ),
            GestureDetector(
              onTap: () => ref.read(activeStampAspectLockedProvider.notifier).state = !aspectLocked,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  aspectLocked ? Icons.lock : Icons.lock_open,
                  size: 16,
                  color: aspectLocked ? const Color(0xFF1A1A2E) : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        // 高さスライダー
        buildSliderRow(
          label: '高さ',
          value: currentH,
          min: 2.0,
          max: 100.0,
          onChanged: (v) {
            final newW = aspectLocked ? (v * currentW / currentH).clamp(2.0, 100.0) : currentW;
            updateSize(newW, v);
          },
          onChangeEnd: hasSelection ? (_) => notifier.commitStampItems() : null,
        ),
        if (hasSelection) ...[
          const SizedBox(height: 6),
          buildSliderRow(
            label: '線の太さ',
            value: selectedItem!.strokeScale,
            min: 0.5,
            max: 4.0,
            onChanged: (v) => notifier.updateStampStrokeScale(selectedIndex!, v),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('色:', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 6),
              ..._stampColorSwatches.map((hex) {
                final selected = selectedItem!.colorHex.toUpperCase() == hex.toUpperCase();
                return GestureDetector(
                  onTap: () => notifier.updateStampColor(selectedIndex!, hex),
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.black87 : Colors.black26,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('回転:', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 6),
              for (final deg in [-90, -45, 45, 90])
                GestureDetector(
                  onTap: () => notifier.updateStampRotation(
                      selectedIndex!, (selectedItem!.rotation + deg)),
                  child: Container(
                    width: 36,
                    height: 28,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${deg > 0 ? '+' : ''}$deg°',
                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => notifier.updateStampRotation(selectedIndex!, 0),
                child: Container(
                  width: 36,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text('0°', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        const Text('タップで配置 / 長押しで選択→ドラッグ移動・ピンチリサイズ',
            style: TextStyle(fontSize: 11, color: Colors.black45)),
        const SizedBox(height: 6),
        _ShapePalette(
          selectedShape: selectedShape,
          onSelect: (shape) => ref.read(activeStampShapeProvider.notifier).state = shape,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showGridDialog(context, ref, selectedShape, activeW, activeH),
              icon: const Icon(Icons.grid_on, size: 16),
              label: const Text('グリッド配置', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            if (isGrouped)
              OutlinedButton.icon(
                onPressed: () {
                  notifier.ungroupStamps(selectedIndex!);
                  ref.read(selectedStampIndexProvider.notifier).state = null;
                },
                icon: const Icon(Icons.link_off, size: 16),
                label: const Text('グループ解除', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        if (config.items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text('配置済み ${config.items.length} 件',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const Spacer(),
              GestureDetector(
                onTap: () => notifier.clearStampItems(),
                child: const Text('すべて削除',
                    style: TextStyle(fontSize: 12, color: Colors.red)),
              ),
            ],
          ),
          ...config.items.asMap().entries.map((e) => _StampItemRow(
                index: e.key,
                item: e.value,
                onDelete: () => notifier.removeStampItem(e.key),
              )),
        ],
      ],
    );
  }
}

class _ShapePalette extends StatefulWidget {
  const _ShapePalette({required this.selectedShape, required this.onSelect});
  final String selectedShape;
  final void Function(String) onSelect;

  @override
  State<_ShapePalette> createState() => _ShapePaletteState();
}

class _ShapePaletteState extends State<_ShapePalette> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: StampShapes.categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: StampShapes.categories
              .map((c) => Tab(text: c.$1))
              .toList(),
        ),
        SizedBox(
          height: 120,
          child: TabBarView(
            controller: _tab,
            children: StampShapes.categories.map((cat) {
              final shapeIds = cat.$2;
              final shapes = StampShapes.shapes
                  .where((s) => shapeIds.contains(s.$1))
                  .toList();
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: shapes.map((entry) {
                    final (type, label) = entry;
                    final selected = type == widget.selectedShape;
                    return GestureDetector(
                      onTap: () => widget.onSelect(type),
                      child: Container(
                        width: 52,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1A1A2E).withValues(alpha: 0.12)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 26,
                              height: 26,
                              child: CustomPaint(
                                painter: _ShapeIconPainter(shapeType: type),
                              ),
                            ),
                            Text(label,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: selected ? const Color(0xFF1A1A2E) : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ShapeIconPainter extends CustomPainter {
  const _ShapeIconPainter({required this.shapeType});
  final String shapeType;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide * 0.72;
    StampShapes.draw(canvas, shapeType, c, s, s, const Color(0xFF1A1A2E), 1.0);
  }

  @override
  bool shouldRepaint(covariant _ShapeIconPainter old) => old.shapeType != shapeType;
}

class _StampItemRow extends StatelessWidget {
  const _StampItemRow({required this.index, required this.item, required this.onDelete});
  final int index;
  final StampItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = StampShapes.shapes
        .where((e) => e.$1 == item.shapeType)
        .map((e) => e.$2)
        .firstOrNull ?? item.shapeType;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(painter: _ShapeIconPainter(shapeType: item.shapeType)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              () {
                final w = item.widthMm > 0 ? item.widthMm : item.sizeMm;
                final h = item.heightMm > 0 ? item.heightMm : item.sizeMm;
                return w == h
                    ? '$label  ${w.toStringAsFixed(1)}mm'
                    : '$label  ${w.toStringAsFixed(1)}×${h.toStringAsFixed(1)}mm';
              }(),
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

class _GridDialog extends StatefulWidget {
  const _GridDialog({
    required this.shape,
    required this.widthMm,
    required this.heightMm,
    required this.onConfirm,
  });

  final String shape;
  final double widthMm;
  final double heightMm;
  final void Function({
    required int cols,
    required int rows,
    required double hSpacing,
    required double vSpacing,
  }) onConfirm;

  @override
  State<_GridDialog> createState() => _GridDialogState();
}

class _GridDialogState extends State<_GridDialog> {
  int _cols = 3;
  int _rows = 3;
  double _hSpacing = 5.0;
  double _vSpacing = 5.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('グリッド配置'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CountRow(label: '列数', value: _cols, min: 1, max: 20,
              onChanged: (v) => setState(() => _cols = v)),
          const SizedBox(height: 8),
          _CountRow(label: '行数', value: _rows, min: 1, max: 20,
              onChanged: (v) => setState(() => _rows = v)),
          const SizedBox(height: 12),
          _SpacingRow(
            label: '横間隔 (mm)',
            value: _hSpacing,
            onChanged: (v) => setState(() => _hSpacing = v),
          ),
          const SizedBox(height: 8),
          _SpacingRow(
            label: '縦間隔 (mm)',
            value: _vSpacing,
            onChanged: (v) => setState(() => _vSpacing = v),
          ),
          const SizedBox(height: 12),
          Text(
            '${_cols}列 × ${_rows}行 = ${_cols * _rows}個',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(
              cols: _cols, rows: _rows,
              hSpacing: _hSpacing, vSpacing: _vSpacing,
            );
          },
          child: const Text('配置'),
        ),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 13))),
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        SizedBox(
          width: 36,
          child: Text('$value', textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15)),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _SpacingRow extends StatelessWidget {
  const _SpacingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            value: value.clamp(0.0, 20.0),
            min: 0,
            max: 20,
            divisions: 40,
            label: '${value.toStringAsFixed(1)}mm',
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 38,
          child: Text('${value.toStringAsFixed(1)}',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
      ],
    );
  }
}
