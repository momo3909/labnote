import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class StaffControls extends StatelessWidget {
  const StaffControls({super.key, required this.config, required this.notifier});

  final StaffLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSliderRow(
          label: '線間隔',
          value: config.lineSpacingMm,
          min: 1.0,
          max: 5.0,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(lineSpacingMm: v)),
        ),
        buildSliderRow(
          label: '段間隔',
          value: config.staffGapMm,
          min: 4.0,
          max: 30.0,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(staffGapMm: v)),
        ),
      ],
    );
  }
}
