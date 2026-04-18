import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/templates/presentation/home_screen.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/templates/presentation/saved_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/models/layer_config.dart';

CustomTransitionPage<void> _fadeRoute(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/saved', builder: (context, state) => const SavedListScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/editor',
      pageBuilder: (context, state) => _fadeRoute(
        state,
        EditorScreen(
          templateUuid: null,
          presetConfig: state.extra as LayerConfig?,
        ),
      ),
    ),
    GoRoute(
      path: '/editor/:uuid',
      pageBuilder: (context, state) => _fadeRoute(
        state,
        EditorScreen(templateUuid: state.pathParameters['uuid']),
      ),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/saved');
            case 2:
              context.go('/settings');
          }
        },
        selectedIndex: _selectedIndex(context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: '保存済み',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/saved')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }
}
