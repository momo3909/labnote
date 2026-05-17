import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class RuledGridControls extends StatelessWidget {
  const RuledGridControls({super.key, required this.config, required this.notifier});

  final RuledGridLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSliderRow(
          label: 'グリッド間隔',
          value: config.cellMm,
          min: 2.0,
          max: 15.0,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(cellMm: v)),
        ),
        buildSliderRow(
          label: '罫線間隔',
          value: config.ruledSpacingMm,
          min: 3.0,
          max: 20.0,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(ruledSpacingMm: v)),
        ),
      ],
    );
  }
}
