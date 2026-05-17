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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSliderRow(
          label: '間隔',
          value: config.spacingMm,
          min: 2,
          max: 20,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(spacingMm: v)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('線種:', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(width: 8),
            for (final (style, label) in [
              (LineStyle.solid,  '実線'),
              (LineStyle.dashed, '破線'),
              (LineStyle.dotted, '点線'),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => notifier.updateActiveLayerConfig(
                      config.copyWith(lineStyle: style)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: config.lineStyle == style
                          ? const Color(0xFF1A1A2E)
                          : Colors.transparent,
                      border: Border.all(
                        color: config.lineStyle == style
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: config.lineStyle == style
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
