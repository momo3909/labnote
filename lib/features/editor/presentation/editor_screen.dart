import 'package:flutter/material.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';
import '../../../shared/painters/grid_layer_painter.dart';
import '../../../core/constants/print_constants.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.templateId});
  final String? templateId;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  var _config = const GridLayerConfig(
    cellWidthMm: 5.0,
    cellHeightMm: 5.0,
    lineStyle: LineStyle.solid,
  );
  var _pageConfig = const PageConfig();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateId == null ? '新規作成' : 'テンプレート編集'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('保存')),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildPreview()),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final paperWidthMm = _pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
    final paperHeightMm = _pageConfig.paperSize == PaperSize.a4 ? a4HeightMm : b5HeightMm;
    final aspectRatio = paperWidthMm / paperHeightMm;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)],
            ),
            child: CustomPaint(
              painter: GridLayerPainter(
                config: _config,
                pageConfig: _pageConfig,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSliderRow(
            label: 'グリッド幅',
            value: _config.cellWidthMm,
            min: 1,
            max: 20,
            onChanged: (v) => setState(() {
              _config = GridLayerConfig(
                cellWidthMm: v,
                cellHeightMm: _config.cellHeightMm,
                lineStyle: _config.lineStyle,
                boldEvery: _config.boldEvery,
              );
            }),
          ),
          _buildSliderRow(
            label: 'グリッド高さ',
            value: _config.cellHeightMm,
            min: 1,
            max: 20,
            onChanged: (v) => setState(() {
              _config = GridLayerConfig(
                cellWidthMm: _config.cellWidthMm,
                cellHeightMm: v,
                lineStyle: _config.lineStyle,
                boldEvery: _config.boldEvery,
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('線種', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              _lineStyleChip(LineStyle.solid, '実線'),
              const SizedBox(width: 8),
              _lineStyleChip(LineStyle.dashed, '破線'),
              const SizedBox(width: 8),
              _lineStyleChip(LineStyle.dotted, '点線'),
              const Spacer(),
              _paperSizeChip(PaperSize.a4, 'A4'),
              const SizedBox(width: 8),
              _paperSizeChip(PaperSize.b5, 'B5'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () {}, child: const Text('PDF 出力')),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 2).toInt(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text('${value.toStringAsFixed(1)}mm', style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _lineStyleChip(LineStyle style, String label) {
    final selected = _config.lineStyle == style;
    return GestureDetector(
      onTap: () => setState(() {
        _config = GridLayerConfig(
          cellWidthMm: _config.cellWidthMm,
          cellHeightMm: _config.cellHeightMm,
          lineStyle: style,
          boldEvery: _config.boldEvery,
        );
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _paperSizeChip(PaperSize size, String label) {
    final selected = _pageConfig.paperSize == size;
    return GestureDetector(
      onTap: () => setState(() {
        _pageConfig = PageConfig(
          paperSize: size,
          orientation: _pageConfig.orientation,
          marginTopMm: _pageConfig.marginTopMm,
          marginBottomMm: _pageConfig.marginBottomMm,
          marginLeftMm: _pageConfig.marginLeftMm,
          marginRightMm: _pageConfig.marginRightMm,
          holeConfig: _pageConfig.holeConfig,
          pageCount: _pageConfig.pageCount,
        );
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
