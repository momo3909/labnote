import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// スライダー + テキスト入力の複合行ウィジェット。
/// - スライダー操作: 即時反映
/// - テキスト入力: 範囲外→バリデーションエラー表示、許容刻みより細かい値→丸め
Widget buildSliderRow({
  Key? key,
  required String label,
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
  ValueChanged<double>? onChangeEnd,
  bool enabled = true,
  String suffix = 'mm',
  bool showAsInt = false,
}) =>
    _SliderRow(
      key: key,
      label: label,
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      enabled: enabled,
      suffix: suffix,
      showAsInt: showAsInt,
    );

class _SliderRow extends StatefulWidget {
  const _SliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
    this.enabled = true,
    this.suffix = 'mm',
    this.showAsInt = false,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool enabled;
  final String suffix;
  final bool showAsInt;

  @override
  State<_SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<_SliderRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  // mm 値は常に 0.1mm 刻み
  static const _mmStep = 0.1;

  String _format(double v) {
    if (widget.showAsInt) return '${v.round()}';
    return v.toStringAsFixed(1);
  }

  double _roundToStep(double v) {
    if (widget.showAsInt) return v.roundToDouble();
    return (v / _mmStep).round() * _mmStep;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _submit(_controller.text);
    });
  }

  @override
  void didUpdateWidget(_SliderRow old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = _format(widget.value);
      if (_errorText != null) setState(() => _errorText = null);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final raw = double.tryParse(text.replaceAll('，', '.'));
    if (raw == null) {
      setState(() => _errorText = '数値を入力してください');
      _controller.text = _format(widget.value);
      return;
    }
    if (raw < widget.min || raw > widget.max) {
      setState(() =>
          _errorText = '範囲: ${_format(widget.min)}〜${_format(widget.max)}${widget.suffix}');
      _controller.text = _format(widget.value);
      return;
    }
    final rounded = _roundToStep(raw);
    setState(() => _errorText = null);
    _controller.text = _format(rounded);
    widget.onChanged(rounded);
    widget.onChangeEnd?.call(rounded);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.enabled ? Colors.black87 : Colors.black38,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: widget.value.clamp(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                divisions: widget.showAsInt
                    ? (widget.max - widget.min).round().clamp(1, 1000)
                    : _sliderDivisions(widget.min, widget.max),
                onChanged: widget.enabled
                    ? (v) {
                        setState(() => _errorText = null);
                        _controller.text = _format(v);
                        widget.onChanged(v);
                      }
                    : null,
                onChangeEnd: widget.enabled ? widget.onChangeEnd : null,
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                keyboardType: widget.showAsInt
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true, signed: false),
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,\-]')),
                ],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: hasError ? Colors.red : (widget.enabled ? Colors.black87 : Colors.black38),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  suffix: widget.suffix.isNotEmpty
                      ? Text(widget.suffix,
                          style: const TextStyle(fontSize: 10, color: Colors.black54))
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                        color: hasError ? Colors.red : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                        color: hasError ? Colors.red : const Color(0xFF1A1A2E)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                onTap: () {
                  if (_focusNode.hasFocus) {
                    // iOSキーボード抑制状態（▼で閉じた後）をリセット:
                    // 一度接続を閉じてから再オープンするとキーボードが復活する
                    _focusNode.unfocus();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) FocusScope.of(context).requestFocus(_focusNode);
                    });
                  } else {
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                },
                onSubmitted: _submit,
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 72, top: 2, bottom: 2),
            child: Text(
              _errorText!,
              style: const TextStyle(fontSize: 10, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

// 0.1mm 刻みでスライダーを分割する（整数スライダーは別途 divisions を持つ）
int _sliderDivisions(double min, double max) {
  final range = max - min;
  return (range * 10).round().clamp(10, 1000);
}

Widget buildRatioSlider({
  required String label,
  required double value,
  required ValueChanged<double> onChanged,
  ValueChanged<double>? onChangeEnd,
  double max = 1.0,
}) {
  final effective = value.clamp(0.0, max);
  return Row(
    children: [
      SizedBox(
        width: 24,
        child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ),
      Expanded(
        child: Slider(
          value: effective,
          min: 0.0,
          max: max > 0 ? max : 0.01,
          divisions: ((max > 0 ? max : 0.01) * 20).round().clamp(1, 100),
          onChanged: max > 0 ? onChanged : null,
          onChangeEnd: onChangeEnd,
        ),
      ),
      SizedBox(
        width: 36,
        child: Text(
          '${(effective * 100).round()}%',
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ),
    ],
  );
}

Widget buildStyleChip({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    ),
  );
}

Widget buildToggleChip({
  required String label,
  required bool enabled,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.12)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: enabled ? const Color(0xFF1A1A2E) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_box : Icons.check_box_outline_blank,
            size: 14,
            color: enabled ? const Color(0xFF1A1A2E) : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: enabled ? const Color(0xFF1A1A2E) : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
