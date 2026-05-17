import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class DotControls extends StatelessWidget {
  const DotControls({super.key, required this.config, required this.notifier});

  final DotLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSliderRow(
          label: 'ドット間隔',
          value: config.spacingMm,
          min: 1.0,
          max: 20,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(spacingMm: v)),
        ),
        buildSliderRow(
          label: 'ドット径',
          value: config.dotRadiusMm * 2,
          min: 0.2,
          max: 2.0,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(dotRadiusMm: v / 2)),
        ),
        const SizedBox(height: 8),
        buildToggleChip(
          label: '原点揃え（座標軸と合わせる）',
          enabled: config.alignToOrigin,
          onTap: () => notifier.updateActiveLayerConfig(
              config.copyWith(alignToOrigin: !config.alignToOrigin)),
        ),
      ],
    );
  }
}
