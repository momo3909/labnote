import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class HexControls extends StatelessWidget {
  const HexControls({super.key, required this.config, required this.notifier});

  final HexLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSliderRow(
          label: '六角形サイズ',
          value: config.hexSizeMm,
          min: 2,
          max: 20,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(hexSizeMm: v)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('向き', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildStyleChip(
              label: 'フラット',
              selected: config.orientation == HexOrientation.flat,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(orientation: HexOrientation.flat),
              ),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '尖り',
              selected: config.orientation == HexOrientation.pointy,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(orientation: HexOrientation.pointy),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
