import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class TimetableControls extends StatelessWidget {
  const TimetableControls({super.key, required this.config, required this.notifier});

  final TimetableLayerConfig config;
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
            const Text('曜日数', style: TextStyle(fontSize: 13)),
            for (final (label, days) in const [('平日5日', 5), ('土含む6日', 6), ('7日', 7)])
              buildStyleChip(
                label: label,
                selected: config.daysCount == days,
                onTap: () => notifier.updateActiveLayerConfig(config.copyWith(daysCount: days)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        _intSliderRow(
          label: '開始時刻',
          value: config.startHour,
          min: 6,
          max: 12,
          unit: '時',
          onChanged: (v) {
            if (v < config.endHour) notifier.updateActiveLayerConfig(config.copyWith(startHour: v));
          },
        ),
        _intSliderRow(
          label: '終了時刻',
          value: config.endHour,
          min: 16,
          max: 24,
          unit: '時',
          onChanged: (v) {
            if (v > config.startHour) notifier.updateActiveLayerConfig(config.copyWith(endHour: v));
          },
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
  String unit = '',
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
        width: 40,
        child: Text('$value$unit', style: const TextStyle(fontSize: 12), textAlign: TextAlign.right),
      ),
    ],
  );
}
