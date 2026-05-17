import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class HeaderControls extends StatelessWidget {
  const HeaderControls({
    super.key,
    required this.config,
    required this.notifier,
  });

  final HeaderLayerConfig config;
  final EditorNotifier notifier;

  void _update(HeaderLayerConfig c) =>
      notifier.updateActiveLayerConfig(c);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── フィールド ON/OFF ──────────────────────────────────────
        const Text('表示フィールド',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            buildStyleChip(
              label: 'タイトル',
              selected: config.showTitle,
              onTap: () => _update(config.copyWith(showTitle: !config.showTitle)),
            ),
            buildStyleChip(
              label: '日付',
              selected: config.showDate,
              onTap: () => _update(config.copyWith(showDate: !config.showDate)),
            ),
            buildStyleChip(
              label: '名前',
              selected: config.showName,
              onTap: () => _update(config.copyWith(showName: !config.showName)),
            ),
            buildStyleChip(
              label: '科目',
              selected: config.showSubject,
              onTap: () => _update(config.copyWith(showSubject: !config.showSubject)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ── ラベル編集 ────────────────────────────────────────────
        if (config.showTitle) _labelField(
          label: 'タイトルラベル',
          value: config.titleLabel,
          onChanged: (v) => _update(config.copyWith(titleLabel: v)),
        ),
        if (config.showDate) _labelField(
          label: '日付ラベル',
          value: config.dateLabel,
          onChanged: (v) => _update(config.copyWith(dateLabel: v)),
        ),
        if (config.showName) _labelField(
          label: '名前ラベル',
          value: config.nameLabel,
          onChanged: (v) => _update(config.copyWith(nameLabel: v)),
        ),
        if (config.showSubject) _labelField(
          label: '科目ラベル',
          value: config.subjectLabel,
          onChanged: (v) => _update(config.copyWith(subjectLabel: v)),
        ),
        // ── サイズ ────────────────────────────────────────────────
        const SizedBox(height: 4),
        buildSliderRow(
          label: 'フォント',
          value: config.fontSizeMm,
          min: 2.0,
          max: 8.0,
          onChanged: (v) => _update(config.copyWith(fontSizeMm: v)),
        ),
        buildSliderRow(
          label: '行高さ',
          value: config.rowHeightMm,
          min: 5.0,
          max: 20.0,
          onChanged: (v) => _update(config.copyWith(rowHeightMm: v)),
        ),
        const SizedBox(height: 6),
        // ── 枠線 ──────────────────────────────────────────────────
        buildStyleChip(
          label: '枠線を表示',
          selected: config.showBorder,
          onTap: () => _update(config.copyWith(showBorder: !config.showBorder)),
        ),
      ],
    );
  }

  Widget _labelField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: value)
                  ..selection =
                      TextSelection.collapsed(offset: value.length),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
}
