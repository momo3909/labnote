import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../features/gallery/data/gallery_repository.dart';
import '../../../features/gallery/domain/gallery_notifier.dart';
import '../../../features/paywall/domain/entitlement_notifier.dart';
import '../../../features/paywall/domain/free_limits.dart';
import '../../../features/paywall/presentation/paywall_modal.dart';
import '../../../features/profile/domain/profile_notifier.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/widgets/layer_stack_preview.dart';

void _showLoginRequired(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'ログインする',
        onPressed: () => context.push('/login'),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// _PublishDialogの戻り値型
typedef _PublishResult = ({
  String description,
  List<String> tags,
});

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
                    onUpdate: () => _updateGallery(context, ref, templates[i]),
                    onUnpublish: () => _unpublishFromGallery(context, ref, templates[i]),
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
    // 未ログイン時は投稿不可
    final profile = await ref.read(currentProfileProvider.future);
    if (!context.mounted) return;
    if (profile == null) {
      _showLoginRequired(context, 'ギャラリーへの投稿にはログインが必要です');
      return;
    }

    final result = await showDialog<_PublishResult>(
      context: context,
      builder: (ctx) => _PublishDialog(templateName: template.name),
    );
    if (result == null || !context.mounted) return;

    try {
      final docId = await ref.read(galleryRepositoryProvider).publish(
            template,
            description: result.description,
            tags: result.tags,
            authorName: profile.displayName,
            authorAvatarUrl: profile.avatarUrl,
          );
      // remoteId をローカルに保存
      template.remoteId = docId;
      await ref.read(templateRepositoryProvider).save(template);
      ref.invalidate(templatesProvider);
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

  Future<void> _updateGallery(
    BuildContext context,
    WidgetRef ref,
    NotebookTemplate template,
  ) async {
    final remoteId = template.remoteId;
    if (remoteId == null) return;

    final profile = await ref.read(currentProfileProvider.future);
    if (!context.mounted) return;
    if (profile == null) {
      _showLoginRequired(context, 'ギャラリーの更新にはログインが必要です');
      return;
    }

    final existing = await ref.read(galleryRepositoryProvider).fetchById(remoteId);
    if (!context.mounted) return;

    final result = await showDialog<_PublishResult>(
      context: context,
      builder: (ctx) => _PublishDialog(
        templateName: template.name,
        isUpdate: true,
        initialDescription: existing?.description ?? '',
        initialTags: existing?.tags ?? [],
      ),
    );
    if (result == null || !context.mounted) return;

    try {
      await ref.read(galleryRepositoryProvider).updatePublished(
            remoteId,
            template,
            description: result.description,
            tags: result.tags,
          );
      if (!context.mounted) return;
      ref.invalidate(galleryNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ギャラリーを更新しました')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新エラー: $e')),
      );
    }
  }

  Future<void> _unpublishFromGallery(
    BuildContext context,
    WidgetRef ref,
    NotebookTemplate template,
  ) async {
    final remoteId = template.remoteId;
    if (remoteId == null) return;

    // 未ログイン時はFirestoreの権限エラーになるため事前にブロック
    final profile = await ref.read(currentProfileProvider.future);
    if (!context.mounted) return;
    if (profile == null) {
      _showLoginRequired(context, '公開停止にはログインが必要です');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('公開を停止'),
        content: Text('「${template.name}」をギャラリーから削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('公開停止'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(galleryRepositoryProvider).deleteTemplate(remoteId);
      template.remoteId = null;
      await ref.read(templateRepositoryProvider).save(template);
      ref.invalidate(templatesProvider);
      if (!context.mounted) return;
      ref.invalidate(galleryNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ギャラリーから削除しました')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除エラー: $e')),
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
    required this.onUpdate,
    required this.onUnpublish,
    required this.onDuplicate,
  });
  final NotebookTemplate template;
  final VoidCallback onDelete;
  final VoidCallback onPublish;
  final VoidCallback onUpdate;
  final VoidCallback onUnpublish;
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
        leading: _SavedThumbnail(template: template),
        title: Text(template.name),
        subtitle: Row(
          children: [
            Text(_formatDate(template.updatedAt), style: const TextStyle(fontSize: 12)),
            if (template.remoteId != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.cloud_done_outlined, size: 12, color: Colors.green),
              const SizedBox(width: 2),
              const Text('公開中', style: TextStyle(fontSize: 11, color: Colors.green)),
            ],
          ],
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
            } else if (action == _TileAction.update) {
              onUpdate();
            } else if (action == _TileAction.unpublish) {
              onUnpublish();
            } else if (action == _TileAction.delete) {
              onDelete();
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: _TileAction.open,
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('編集'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: _TileAction.duplicate,
              child: ListTile(
                leading: Icon(Icons.copy_outlined),
                title: Text('複製'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (template.remoteId != null) ...[
              const PopupMenuItem(
                value: _TileAction.update,
                child: ListTile(
                  leading: Icon(Icons.sync_outlined),
                  title: Text('ギャラリーを更新'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: _TileAction.unpublish,
                child: ListTile(
                  leading: Icon(Icons.cloud_off_outlined, color: Colors.orange),
                  title: Text('公開を停止', style: TextStyle(color: Colors.orange)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ] else
              const PopupMenuItem(
                value: _TileAction.publish,
                child: ListTile(
                  leading: Icon(Icons.upload_outlined),
                  title: Text('ギャラリーに投稿'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
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

enum _TileAction { open, duplicate, publish, update, unpublish, delete }

class _PublishDialog extends StatefulWidget {
  const _PublishDialog({
    required this.templateName,
    this.isUpdate = false,
    this.initialDescription = '',
    this.initialTags = const [],
  });
  final String templateName;
  final bool isUpdate;
  final String initialDescription;
  final List<String> initialTags;

  @override
  State<_PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<_PublishDialog> {
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  String? _tagError;
  String _tagInput = '';

  static const _maxTagLength = 20;

  static const _suggestedTags = [
    // 科目
    '数学', '物理', '化学', '生物', '情報', '工学', '医学', '薬学', '建築',
    // レイアウト
    '方眼', 'ドット', 'コーネル', '罫線', 'グラフ', '座標軸', '対数', '極座標',
    '六角形', '製図', '五線譜', '数式罫線',
    // 用途
    '授業', '講義', '実験', 'レポート', '演習', '暗記', 'まとめ',
    // 対象
    '理系', '大学', '大学院', 'シンプル',
  ];

  @override
  void initState() {
    super.initState();
    _descController.text = widget.initialDescription;
    _tags.addAll(widget.initialTags);
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) return;
    if (tag.length > _maxTagLength) {
      setState(() => _tagError = '${_maxTagLength}文字以内で入力してください');
      return;
    }
    if (_tags.contains(tag)) {
      setState(() => _tagError = 'このタグはすでに追加されています');
      return;
    }
    if (_tags.length >= 5) {
      setState(() => _tagError = 'タグは最大5件です');
      return;
    }
    setState(() {
      _tags.add(tag);
      _tagController.clear();
      _tagInput = '';
      _tagError = null;
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
      title: Text(widget.isUpdate ? 'ギャラリーを更新' : 'ギャラリーに投稿'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isUpdate
                ? '「${widget.templateName}」の内容を更新します。'
                : '「${widget.templateName}」を公開します。'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      maxLength: _maxTagLength,
                      decoration: InputDecoration(
                        hintText: 'タグを入力（${_maxTagLength}文字以内）',
                        isDense: true,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        errorText: _tagError,
                        counterText: '',
                      ),
                                      onChanged: (v) {
                        setState(() {
                          _tagInput = v.trim();
                          _tagError = null;
                        });
                      },
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
              // 候補タグ
              Builder(builder: (_) {
                final suggestions = _suggestedTags.where((t) =>
                  !_tags.contains(t) &&
                  (_tagInput.isEmpty || t.contains(_tagInput)),
                ).toList();
                if (suggestions.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: suggestions.map((t) => GestureDetector(
                      onTap: () {
                        _tagController.text = t;
                        _addTag();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Text(t,
                            style: TextStyle(fontSize: 11, color: Colors.indigo.shade700)),
                      ),
                    )).toList(),
                  ),
                );
              }),
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
          onPressed: () => Navigator.pop<_PublishResult>(
            context,
            (description: _descController.text.trim(), tags: List<String>.from(_tags)),
          ),
          child: Text(widget.isUpdate ? '更新' : '投稿'),
        ),
      ],
    );
  }
}

class _SavedThumbnail extends StatelessWidget {
  const _SavedThumbnail({required this.template});
  final NotebookTemplate template;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 32,
        height: 44,
        child: template.thumbnailPng != null
            ? Image.memory(template.thumbnailPng!, fit: BoxFit.cover)
            : LayerStackPreview(
                pageConfig: template.pageConfig,
                layers: template.layers,
                padding: EdgeInsets.zero,
              ),
      ),
    );
  }
}
