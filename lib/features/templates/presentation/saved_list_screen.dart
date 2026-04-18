import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
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
          if (templates.isEmpty) {
            return const Center(
              child: Text('保存済みテンプレートはありません', style: TextStyle(color: Colors.black38)),
            );
          }
          return ListView.separated(
            itemCount: templates.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
            itemBuilder: (context, i) => _TemplateListTile(
              template: templates[i],
              onDelete: () => _confirmDelete(context, ref, templates[i]),
            ),
          );
        },
      ),
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
  const _TemplateListTile({required this.template, required this.onDelete});
  final NotebookTemplate template;
  final VoidCallback onDelete;

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
        leading: const Icon(Icons.grid_on_outlined, color: Color(0xFF1A1A2E)),
        title: Text(template.name),
        subtitle: Text(
          _formatDate(template.updatedAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
        onTap: () => context.push('/editor/${template.uuid}'),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}
