import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../features/gallery/data/gallery_repository.dart';
import '../../../features/gallery/domain/gallery_notifier.dart';
import '../../../features/paywall/domain/entitlement_notifier.dart';
import '../../../features/paywall/domain/free_limits.dart';
import '../../../features/paywall/presentation/paywall_modal.dart';
import '../../../shared/models/notebook_template.dart';

class SavedListScreen extends ConsumerWidget {
  const SavedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('保存済みテンプレート')),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('読み込みエラー: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (templates) {
          final isPro = ref.watch(entitlementNotifierProvider).valueOrNull ?? false;
          if (templates.isEmpty) {
            return const Center(
              child: Text('保存済みテンプレートはありません', style: TextStyle(color: Colors.black38)),
            );
          }
          return Column(
            children: [
              if (!isPro)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.amber.shade50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '無料プラン: ${templates.length}/$freeMaxSavedTemplates 件使用',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                      TextButton(
                        onPressed: () => showPaywallModal(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Proにアップグレード',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: templates.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (context, i) => _TemplateListTile(
                    template: templates[i],
                    onDelete: () => _confirmDelete(context, ref, templates[i]),
                    onPublish: () => _publishToGallery(context, ref, templates[i]),
                    onDuplicate: () => _duplicate(context, ref, templates[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _publishToGallery(
    BuildContext context,
    WidgetRef ref,
    NotebookTemplate template,
  ) async {
    final result = await showDialog<({String description, List<String> tags})>(
      context: context,
      builder: (ctx) => _PublishDialog(templateName: template.name),
    );
    if (result == null || !context.mounted) return;

    try {
      await ref.read(galleryRepositoryProvider).publish(
            template,
            description: result.description,
            tags: result.tags,
          );
      if (!context.mounted) return;
      ref.invalidate(galleryNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ギャラリーに投稿しました')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('投稿エラー: $e')),
      );
    }
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    NotebookTemplate template,
  ) async {
    await ref.read(templateRepositoryProvider).create(
          name: '${template.name} のコピー',
          pageConfig: template.pageConfig,
          layers: template.layers,
          thumbnail: template.thumbnailPng,
        );
    ref.invalidate(templatesProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「${template.name}」を複製しました')),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    NotebookTemplate template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テンプレートを削除'),
        content: Text('「${template.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(templateRepositoryProvider).delete(template.uuid);
    ref.invalidate(templatesProvider);
  }
}

class _TemplateListTile extends StatelessWidget {
  const _TemplateListTile({
    required this.template,
    required this.onDelete,
    required this.onPublish,
    required this.onDuplicate,
  });
  final NotebookTemplate template;
  final VoidCallback onDelete;
  final VoidCallback onPublish;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(template.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ListTile(
        leading: _SavedThumbnail(thumbnail: template.thumbnailPng),
        title: Text(template.name),
        subtitle: Text(
          _formatDate(template.updatedAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: PopupMenuButton<_TileAction>(
          icon: const Icon(Icons.more_vert, size: 18, color: Colors.black38),
          onSelected: (action) {
            if (action == _TileAction.open) {
              context.push('/editor/${template.uuid}');
            } else if (action == _TileAction.duplicate) {
              onDuplicate();
            } else if (action == _TileAction.publish) {
              onPublish();
            } else if (action == _TileAction.delete) {
              onDelete();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: _TileAction.open,
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('編集'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _TileAction.duplicate,
              child: ListTile(
                leading: Icon(Icons.copy_outlined),
                title: Text('複製'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _TileAction.publish,
              child: ListTile(
                leading: Icon(Icons.upload_outlined),
                title: Text('ギャラリーに投稿'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _TileAction.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('削除', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => context.push('/editor/${template.uuid}'),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

enum _TileAction { open, duplicate, publish, delete }

class _PublishDialog extends StatefulWidget {
  const _PublishDialog({required this.templateName});
  final String templateName;

  @override
  State<_PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<_PublishDialog> {
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty || _tags.contains(tag) || _tags.length >= 5) return;
    setState(() {
      _tags.add(tag);
      _tagController.clear();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ギャラリーに投稿'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('「${widget.templateName}」を公開します。'),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                hintText: '例: 理系向け方眼＋コーネルノート',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('タグ（最大5件）',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 6),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _tags
                    .map(
                      (tag) => InputChip(
                        label: Text(tag,
                            style: const TextStyle(fontSize: 12)),
                        onDeleted: () =>
                            setState(() => _tags.remove(tag)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            if (_tags.length < 5) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'タグを入力してEnter',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _addTag,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            (description: _descController.text.trim(), tags: List<String>.from(_tags)),
          ),
          child: const Text('投稿'),
        ),
      ],
    );
  }
}

class _SavedThumbnail extends StatelessWidget {
  const _SavedThumbnail({required this.thumbnail});
  final Uint8List? thumbnail;

  @override
  Widget build(BuildContext context) {
    if (thumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          thumbnail!,
          width: 32,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Icon(Icons.grid_on_outlined, color: Color(0xFF1A1A2E));
  }
}
