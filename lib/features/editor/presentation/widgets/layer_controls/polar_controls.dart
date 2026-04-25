import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class PolarControls extends StatelessWidget {
  const PolarControls({super.key, required this.config, required this.notifier});

  final PolarLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _intSliderRow(
          label: '同心円数',
          value: config.rings,
          min: 2,
          max: 12,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(rings: v)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('分割数', style: TextStyle(fontSize: 13)),
            for (final s in [4, 6, 8, 12, 24])
              buildStyleChip(
                label: '$s',
                selected: config.sectors == s,
                onTap: () => notifier.updateActiveLayerConfig(config.copyWith(sectors: s)),
              ),
          ],
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
