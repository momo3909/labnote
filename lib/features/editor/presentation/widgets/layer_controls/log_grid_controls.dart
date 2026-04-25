import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class LogGridControls extends StatelessWidget {
  const LogGridControls({super.key, required this.config, required this.notifier});

  final LogGridLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('X軸', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildStyleChip(
              label: '等間隔',
              selected: config.xScale == LogScale.linear,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(xScale: LogScale.linear)),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '対数',
              selected: config.xScale == LogScale.log,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(xScale: LogScale.log)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('Y軸', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildStyleChip(
              label: '等間隔',
              selected: config.yScale == LogScale.linear,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(yScale: LogScale.linear)),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '対数',
              selected: config.yScale == LogScale.log,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(yScale: LogScale.log)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (config.xScale == LogScale.log)
          buildSliderRow(
            label: 'X デケード',
            value: config.xDecades.toDouble(),
            min: 1,
            max: 5,
            onChanged: (v) =>
                notifier.updateActiveLayerConfig(config.copyWith(xDecades: v.round())),
          ),
        if (config.yScale == LogScale.log)
          buildSliderRow(
            label: 'Y デケード',
            value: config.yDecades.toDouble(),
            min: 1,
            max: 5,
            onChanged: (v) =>
                notifier.updateActiveLayerConfig(config.copyWith(yDecades: v.round())),
          ),
      ],
    );
  }
}
