import 'package:flutter/material.dart';

Widget buildSliderRow({
  required String label,
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
  bool enabled = true,
}) {
  return Row(
    children: [
      SizedBox(
        width: 72,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: enabled ? Colors.black87 : Colors.black38,
          ),
        ),
      ),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 2).toInt(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
      SizedBox(
        width: 48,
        child: Text(
          '${value.toStringAsFixed(1)}mm',
          style: TextStyle(
            fontSize: 12,
            color: enabled ? Colors.black87 : Colors.black38,
          ),
        ),
      ),
    ],
  );
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
