import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class GraphAxisControls extends StatefulWidget {
  const GraphAxisControls({super.key, required this.config, required this.notifier});

  final GraphAxisLayerConfig config;
  final EditorNotifier notifier;

  @override
  State<GraphAxisControls> createState() => _GraphAxisControlsState();
}

class _GraphAxisControlsState extends State<GraphAxisControls> {
  late TextEditingController _xCtrl;
  late TextEditingController _yCtrl;
  late FocusNode _xFocus;
  late FocusNode _yFocus;

  @override
  void initState() {
    super.initState();
    _xCtrl  = TextEditingController(text: widget.config.xLabel);
    _yCtrl  = TextEditingController(text: widget.config.yLabel);
    _xFocus = FocusNode()..addListener(_onXFocusChange);
    _yFocus = FocusNode()..addListener(_onYFocusChange);
  }

  @override
  void didUpdateWidget(GraphAxisControls old) {
    super.didUpdateWidget(old);
    if (!_xFocus.hasFocus && old.config.xLabel != widget.config.xLabel) {
      _xCtrl.text = widget.config.xLabel;
    }
    if (!_yFocus.hasFocus && old.config.yLabel != widget.config.yLabel) {
      _yCtrl.text = widget.config.yLabel;
    }
  }

  @override
  void dispose() {
    _xCtrl.dispose();
    _yCtrl.dispose();
    _xFocus.dispose();
    _yFocus.dispose();
    super.dispose();
  }

  void _onXFocusChange() {
    if (!_xFocus.hasFocus) _update(widget.config.copyWith(xLabel: _xCtrl.text));
  }

  void _onYFocusChange() {
    if (!_yFocus.hasFocus) _update(widget.config.copyWith(yLabel: _yCtrl.text));
  }

  void _update(GraphAxisLayerConfig c) => widget.notifier.updateActiveLayerConfig(c);

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _toggle('X 軸', config.showXAxis, (v) => _update(config.copyWith(showXAxis: v))),
            _toggle('Y 軸', config.showYAxis, (v) => _update(config.copyWith(showYAxis: v))),
            _toggle('矢印', config.arrowTip,  (v) => _update(config.copyWith(arrowTip: v))),
            _toggle('目盛り', config.showTickMarks, (v) => _update(config.copyWith(showTickMarks: v))),
            _toggle('負方向', config.showNegative,  (v) => _update(config.copyWith(showNegative: v))),
          ],
        ),
        if (config.showTickMarks) ...[
          const SizedBox(height: 8),
          buildSliderRow(
            key: const ValueKey('tickInterval'),
            label: '目盛間隔',
            value: config.tickIntervalMm,
            min: 1.0,
            max: 50,
            onChanged: (v) => _update(config.copyWith(tickIntervalMm: v)),
          ),
          const SizedBox(height: 4),
          buildSliderRow(
            key: const ValueKey('tickLength'),
            label: '目盛高さ',
            value: config.tickLengthMm,
            min: 0.5,
            max: 10.0,
            onChanged: (v) => _update(config.copyWith(tickLengthMm: v)),
          ),
          const SizedBox(height: 8),
          _tickSideRow(
            label: 'X 軸方向',
            side: config.xTickSide,
            positiveLabel: '上のみ',
            negativeLabel: '下のみ',
            onChanged: (v) => _update(config.copyWith(xTickSide: v)),
          ),
          const SizedBox(height: 4),
          _tickSideRow(
            label: 'Y 軸方向',
            side: config.yTickSide,
            positiveLabel: '右のみ',
            negativeLabel: '左のみ',
            onChanged: (v) => _update(config.copyWith(yTickSide: v)),
          ),
        ],
        const SizedBox(height: 8),
        _labelField('X ラベル', _xCtrl, _xFocus,
            (v) => _update(config.copyWith(xLabel: v))),
        const SizedBox(height: 6),
        _labelField('Y ラベル', _yCtrl, _yFocus,
            (v) => _update(config.copyWith(yLabel: v))),
      ],
    );
  }

  Widget _tickSideRow({
    required String label,
    required TickSide side,
    required String positiveLabel,
    required String negativeLabel,
    required ValueChanged<TickSide> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ),
        _sideChip('両側',        side == TickSide.both,     () => onChanged(TickSide.both)),
        const SizedBox(width: 6),
        _sideChip(positiveLabel, side == TickSide.positive,  () => onChanged(TickSide.positive)),
        const SizedBox(width: 6),
        _sideChip(negativeLabel, side == TickSide.negative,  () => onChanged(TickSide.negative)),
      ],
    );
  }

  Widget _sideChip(String label, bool selected, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1A1A2E) : Colors.transparent,
            border: Border.all(
                color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white : Colors.black54)),
        ),
      );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) =>
      GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: value ? const Color(0xFF1A1A2E) : Colors.transparent,
            border: Border.all(
                color: value ? const Color(0xFF1A1A2E) : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: value ? Colors.white : Colors.black54)),
        ),
      );

  Widget _labelField(
    String hint,
    TextEditingController controller,
    FocusNode focusNode,
    ValueChanged<String> onChanged,
  ) =>
      Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(hint,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: onChanged,
            ),
          ),
        ],
      );
}
