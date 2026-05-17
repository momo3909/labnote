import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class CornellControls extends StatefulWidget {
  const CornellControls({super.key, required this.config, required this.notifier});

  final CornellLayerConfig config;
  final EditorNotifier notifier;

  @override
  State<CornellControls> createState() => _CornellControlsState();
}

class _CornellControlsState extends State<CornellControls> {
  late final TextEditingController _keyCtrl;
  late final TextEditingController _sumCtrl;

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.config.keywordLabel);
    _sumCtrl = TextEditingController(text: widget.config.summaryLabel);
  }

  @override
  void didUpdateWidget(covariant CornellControls old) {
    super.didUpdateWidget(old);
    if (old.config.keywordLabel != widget.config.keywordLabel &&
        _keyCtrl.text != widget.config.keywordLabel) {
      _keyCtrl.text = widget.config.keywordLabel;
    }
    if (old.config.summaryLabel != widget.config.summaryLabel &&
        _sumCtrl.text != widget.config.summaryLabel) {
      _sumCtrl.text = widget.config.summaryLabel;
    }
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _sumCtrl.dispose();
    super.dispose();
  }

  CornellLayerConfig get config => widget.config;
  EditorNotifier get notifier => widget.notifier;

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
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 72, child: Text('左欄ラベル', style: TextStyle(fontSize: 12))),
            Expanded(
              child: TextField(
                controller: _keyCtrl,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (v) =>
                    notifier.updateActiveLayerConfig(config.copyWith(keywordLabel: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 72, child: Text('下欄ラベル', style: TextStyle(fontSize: 12))),
            Expanded(
              child: TextField(
                controller: _sumCtrl,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (v) =>
                    notifier.updateActiveLayerConfig(config.copyWith(summaryLabel: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
