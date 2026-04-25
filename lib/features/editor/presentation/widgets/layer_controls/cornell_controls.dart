import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class CornellControls extends StatelessWidget {
  const CornellControls({super.key, required this.config, required this.notifier});

  final CornellLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSliderRow(
          label: 'キーワード欄',
          value: config.leftColMm,
          min: 20,
          max: 80,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(leftColMm: v)),
        ),
        buildSliderRow(
          label: 'サマリー欄',
          value: config.bottomRowMm,
          min: 10,
          max: 60,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(bottomRowMm: v)),
        ),
        buildSliderRow(
          label: '罫線間隔',
          value: config.lineSpacingMm,
          min: 4,
          max: 12,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(lineSpacingMm: v)),
        ),
      ],
    );
  }
}
