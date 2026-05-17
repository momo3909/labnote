import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class LogGridControls extends StatefulWidget {
  const LogGridControls({super.key, required this.config, required this.notifier});

  final LogGridLayerConfig config;
  final EditorNotifier notifier;

  @override
  State<LogGridControls> createState() => _LogGridControlsState();
}

class _LogGridControlsState extends State<LogGridControls> {
  late final TextEditingController _xLabelCtrl;
  late final TextEditingController _yLabelCtrl;

  @override
  void initState() {
    super.initState();
    _xLabelCtrl = TextEditingController(text: widget.config.xLabel);
    _yLabelCtrl = TextEditingController(text: widget.config.yLabel);
  }

  @override
  void didUpdateWidget(covariant LogGridControls old) {
    super.didUpdateWidget(old);
    if (old.config.xLabel != widget.config.xLabel &&
        _xLabelCtrl.text != widget.config.xLabel) {
      _xLabelCtrl.text = widget.config.xLabel;
    }
    if (old.config.yLabel != widget.config.yLabel &&
        _yLabelCtrl.text != widget.config.yLabel) {
      _yLabelCtrl.text = widget.config.yLabel;
    }
  }

  @override
  void dispose() {
    _xLabelCtrl.dispose();
    _yLabelCtrl.dispose();
    super.dispose();
  }

  LogGridLayerConfig get config => widget.config;
  EditorNotifier get notifier => widget.notifier;

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
            suffix: '桁',
            showAsInt: true,
            onChanged: (v) =>
                notifier.updateActiveLayerConfig(config.copyWith(xDecades: v.round())),
          ),
        if (config.yScale == LogScale.log)
          buildSliderRow(
            label: 'Y デケード',
            value: config.yDecades.toDouble(),
            min: 1,
            max: 5,
            suffix: '桁',
            showAsInt: true,
            onChanged: (v) =>
                notifier.updateActiveLayerConfig(config.copyWith(yDecades: v.round())),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 56, child: Text('X ラベル', style: TextStyle(fontSize: 12))),
            Expanded(
              child: TextField(
                controller: _xLabelCtrl,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '例: 周波数 (Hz)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(xLabel: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 56, child: Text('Y ラベル', style: TextStyle(fontSize: 12))),
            Expanded(
              child: TextField(
                controller: _yLabelCtrl,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '例: 利得 (dB)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(yLabel: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
