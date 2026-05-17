import 'package:flutter/material.dart';

class GalleryTagPickerButton extends StatelessWidget {
  const GalleryTagPickerButton({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onChanged,
  });

  final List<String> allTags;
  final Set<String> selectedTags;
  final void Function(Set<String>) onChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedTags.isNotEmpty;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => _TagFilterSheet(
          allTags: allTags,
          selectedTags: selectedTags,
          onChanged: onChanged,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: hasSelection ? Colors.indigo.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasSelection ? Colors.indigo : Colors.black26,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.label_outline,
                size: 13,
                color: hasSelection ? Colors.indigo : Colors.black54),
            const SizedBox(width: 4),
            Text(
              'タグ',
              style: TextStyle(
                fontSize: 12,
                color: hasSelection ? Colors.indigo : Colors.black54,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, size: 14, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _TagFilterSheet extends StatefulWidget {
  const _TagFilterSheet({
    required this.allTags,
    required this.selectedTags,
    required this.onChanged,
  });

  final List<String> allTags;
  final Set<String> selectedTags;
  final void Function(Set<String>) onChanged;

  @override
  State<_TagFilterSheet> createState() => _TagFilterSheetState();
}

class _TagFilterSheetState extends State<_TagFilterSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('タグで絞り込む',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _selected.clear());
                      widget.onChanged({});
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('リセット',
                        style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.allTags.map((tag) {
                  final selected = _selected.contains(tag);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selected.remove(tag);
                        } else {
                          _selected.add(tag);
                        }
                      });
                      widget.onChanged(Set.from(_selected));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.indigo.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? Colors.indigo : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected) ...[
                            const Icon(Icons.check, size: 13, color: Colors.indigo),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              color: selected ? Colors.indigo : Colors.black87,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
