import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class IsometricControls extends StatelessWidget {
  const IsometricControls({super.key, required this.config, required this.notifier});

  final IsometricLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return buildSliderRow(
      label: '間隔',
      value: config.spacingMm,
      min: 2,
      max: 20,
      onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(spacingMm: v)),
    );
  }
}
