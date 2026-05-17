import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class CustomLineControls extends StatelessWidget {
  const CustomLineControls({
    super.key,
    required this.config,
    required this.notifier,
  });

  final CustomLineLayerConfig config;
  final EditorNotifier notifier;

  void _add(bool isHorizontal) {
    final updated = [
      ...config.lineSets,
      LineSet(isHorizontal: isHorizontal),
    ];
    notifier.updateActiveLayerConfig(config.copyWith(lineSets: updated));
  }

  void _remove(int index) {
    final updated = [...config.lineSets]..removeAt(index);
    notifier.updateActiveLayerConfig(config.copyWith(lineSets: updated));
  }

  void _update(int index, LineSet set) {
    final updated = config.lineSets.toList()..[index] = set;
    notifier.updateActiveLayerConfig(config.copyWith(lineSets: updated));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _addButton('＋ 横線', () => _add(true)),
            const SizedBox(width: 8),
            _addButton('＋ 縦線', () => _add(false)),
          ],
        ),
        if (config.lineSets.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...config.lineSets.asMap().entries.map(
                (e) => _LineSetCard(
                  index: e.key,
                  set: e.value,
                  onUpdate: (s) => _update(e.key, s),
                  onDelete: () => _remove(e.key),
                ),
              ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '「＋ 横線」または「＋ 縦線」で線セットを追加',
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ),
      ],
    );
  }

  Widget _addButton(String label, VoidCallback onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      );
}

class _LineSetCard extends StatelessWidget {
  const _LineSetCard({
    required this.index,
    required this.set,
    required this.onUpdate,
    required this.onDelete,
  });

  final int index;
  final LineSet set;
  final ValueChanged<LineSet> onUpdate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                set.isHorizontal ? '横線' : '縦線',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 16, color: Colors.black38),
              ),
            ],
          ),
          const SizedBox(height: 4),
          buildSliderRow(
            label: '本数',
            value: set.count.toDouble(),
            min: 1,
            max: 50,
            suffix: '本',
            showAsInt: true,
            onChanged: (v) => onUpdate(set.copyWith(count: v.round())),
          ),
          buildSliderRow(
            label: '間隔',
            value: set.spacingMm,
            min: 1,
            max: 50,
            onChanged: (v) => onUpdate(set.copyWith(spacingMm: v)),
          ),
          buildSliderRow(
            label: '開始',
            value: set.startMm,
            min: 0,
            max: 100,
            onChanged: (v) => onUpdate(set.copyWith(startMm: v)),
          ),
          buildSliderRow(
            label: '太さ',
            value: set.strokeWidthMm,
            min: 0.1,
            max: 2.0,
            onChanged: (v) => onUpdate(set.copyWith(strokeWidthMm: v)),
          ),
          const SizedBox(height: 4),
          _lineStyleChips(set.lineStyle, (s) => onUpdate(set.copyWith(lineStyle: s))),
          const SizedBox(height: 8),
          // サブ罫線セクション
          Row(
            children: [
              const Text('サブ罫線', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
              const Spacer(),
              GestureDetector(
                onTap: () => onUpdate(set.copyWith(subLines: [...set.subLines, const SubLineConfig()])),
                child: const Icon(Icons.add, size: 15, color: Colors.black38),
              ),
            ],
          ),
          ...set.subLines.asMap().entries.map((e) {
            final si = e.key;
            final sub = e.value;
            return Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSliderRow(
                          label: '位置',
                          value: sub.positionRatio,
                          min: 0.05,
                          max: 0.95,
                          suffix: '',
                          onChanged: (v) {
                            final updated = set.subLines.toList()..[si] = sub.copyWith(positionRatio: v);
                            onUpdate(set.copyWith(subLines: updated));
                          },
                        ),
                        buildSliderRow(
                          label: '太さ',
                          value: sub.strokeWidthMm,
                          min: 0.05,
                          max: 1.0,
                          onChanged: (v) {
                            final updated = set.subLines.toList()..[si] = sub.copyWith(strokeWidthMm: v);
                            onUpdate(set.copyWith(subLines: updated));
                          },
                        ),
                        _lineStyleChips(sub.lineStyle, (s) {
                          final updated = set.subLines.toList()..[si] = sub.copyWith(lineStyle: s);
                          onUpdate(set.copyWith(subLines: updated));
                        }),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final updated = set.subLines.toList()..removeAt(si);
                      onUpdate(set.copyWith(subLines: updated));
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.close, size: 14, color: Colors.black26),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget _lineStyleChips(LineStyle current, ValueChanged<LineStyle> onChanged) => Row(
        children: [
          const Text('線種:', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(width: 8),
          for (final (style, label) in [
            (LineStyle.solid, '実線'),
            (LineStyle.dashed, '破線'),
            (LineStyle.dotted, '点線'),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => onChanged(style),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: current == style ? const Color(0xFF1A1A2E) : Colors.transparent,
                    border: Border.all(
                      color: current == style ? const Color(0xFF1A1A2E) : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11, color: current == style ? Colors.white : Colors.black54)),
                ),
              ),
            ),
        ],
      );
}
