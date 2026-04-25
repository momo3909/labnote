import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/profile_notifier.dart';
import '../domain/user_profile.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  bool _sortByLikes = true;

  @override
  Widget build(BuildContext context) {
    final rankingAsync = ref.watch(userRankingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ユーザーランキング')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('いいね数'), icon: Icon(Icons.favorite_border, size: 16)),
                ButtonSegment(value: false, label: Text('投稿数'), icon: Icon(Icons.description_outlined, size: 16)),
              ],
              selected: {_sortByLikes},
              onSelectionChanged: (sel) => setState(() => _sortByLikes = sel.first),
            ),
          ),
          Expanded(
            child: rankingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('エラー: $e')),
              data: (users) {
                final sorted = [...users];
                if (_sortByLikes) {
                  sorted.sort((a, b) => b.totalLikes.compareTo(a.totalLikes));
                } else {
                  sorted.sort((a, b) => b.templateCount.compareTo(a.templateCount));
                }
                if (sorted.isEmpty) {
                  return const Center(
                    child: Text('まだユーザーがいません', style: TextStyle(color: Colors.black38)),
                  );
                }
                return ListView.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (context, _) => const Divider(height: 1, indent: 72),
                  itemBuilder: (ctx, i) => _RankingTile(
                    rank: i + 1,
                    profile: sorted[i],
                    sortByLikes: _sortByLikes,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingTile extends ConsumerWidget {
  const _RankingTile({
    required this.rank,
    required this.profile,
    required this.sortByLikes,
  });
  final int rank;
  final UserProfile profile;
  final bool sortByLikes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: rank <= 3 ? Colors.amber.shade700 : Colors.black45,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _AvatarWidget(profile: profile, radius: 20),
        ],
      ),
      title: Text(
        profile.displayName.isNotEmpty ? profile.displayName : '(名前なし)',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        sortByLikes
            ? 'いいね ${profile.totalLikes}  投稿 ${profile.templateCount}'
            : '投稿 ${profile.templateCount}  いいね ${profile.totalLikes}',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () => context.push('/profile/${profile.uid}'),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({required this.profile, required this.radius});
  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (profile.avatarBytes != null) {
      return CircleAvatar(radius: radius, backgroundImage: MemoryImage(profile.avatarBytes!));
    }
    if (profile.avatarUrl != null) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(profile.avatarUrl!));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.indigo.shade100,
      child: Icon(Icons.person, size: radius, color: Colors.indigo),
    );
  }
}
