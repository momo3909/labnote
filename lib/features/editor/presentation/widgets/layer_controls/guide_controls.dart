import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class GuideControls extends StatelessWidget {
  const GuideControls({super.key, required this.config, required this.notifier});

  final GuideLayerConfig config;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('種類', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final (label, type) in const [
                ('軸線', GuideType.axis),
                ('結合60°', GuideType.bondAngle60),
                ('結合109°', GuideType.bondAngle109),
                ('結合120°', GuideType.bondAngle120),
                ('スケール', GuideType.scale),
              ])
                buildStyleChip(
                  label: label,
                  selected: config.guideType == type,
                  onTap: () => notifier.updateActiveLayerConfig(config.copyWith(guideType: type)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
