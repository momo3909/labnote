import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class ManuscriptControls extends StatelessWidget {
  const ManuscriptControls({super.key, required this.config, required this.notifier});

  final ManuscriptLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('プリセット', style: TextStyle(fontSize: 13)),
            buildStyleChip(
              label: '400字 (20×20)',
              selected: config.columns == 20 && config.rows == 20,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(columns: 20, rows: 20)),
            ),
            buildStyleChip(
              label: '200字 (20×10)',
              selected: config.columns == 20 && config.rows == 10,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(columns: 20, rows: 10)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _intSliderRow(
          label: '列数',
          value: config.columns,
          min: 10,
          max: 30,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(columns: v)),
        ),
        _intSliderRow(
          label: '行数',
          value: config.rows,
          min: 10,
          max: 35,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(rows: v)),
        ),
      ],
    );
  }
}

Widget _intSliderRow({
  required String label,
  required int value,
  required int min,
  required int max,
  required ValueChanged<int> onChanged,
}) {
  return Row(
    children: [
      SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 13))),
      Expanded(
        child: Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (v) => onChanged(v.round()),
        ),
      ),
      SizedBox(
        width: 32,
        child: Text('$value', style: const TextStyle(fontSize: 12), textAlign: TextAlign.right),
      ),
    ],
  );
}
