import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class TableControls extends StatelessWidget {
  const TableControls({super.key, required this.config, required this.notifier});

  final TableLayerConfig config;
  final EditorNotifier notifier;

  void _update(TableLayerConfig c) => notifier.updateTableConfig(c);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSliderRow(
          label: '行数',
          value: config.rows.toDouble(),
          min: 2,
          max: 50,
          suffix: '行',
          showAsInt: true,
          onChanged: (v) => _update(config.copyWith(rows: v.round())),
        ),
        buildSliderRow(
          label: '列数',
          value: config.cols.toDouble(),
          min: 2,
          max: 50,
          suffix: '列',
          showAsInt: true,
          onChanged: (v) => _update(config.copyWith(cols: v.round())),
        ),
        buildSliderRow(
          label: '行高',
          value: config.cellHeightMm,
          min: 5,
          max: 20,
          onChanged: (v) => _update(config.copyWith(cellHeightMm: v)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _toggle('ヘッダー行', config.showHeaderRow, (v) => _update(config.copyWith(showHeaderRow: v))),
            _toggle('ヘッダー列', config.showHeaderCol, (v) => _update(config.copyWith(showHeaderCol: v))),
          ],
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) =>
      GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: value ? const Color(0xFF1A1A2E) : Colors.transparent,
            border: Border.all(color: value ? const Color(0xFF1A1A2E) : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(fontSize: 12, color: value ? Colors.white : Colors.black54)),
        ),
      );
}
