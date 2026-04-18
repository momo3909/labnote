import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/templates/presentation/home_screen.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/templates/presentation/saved_list_screen.dart';
import '../../shared/models/layer_config.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/saved', builder: (context, state) => const SavedListScreen()),
      ],
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => EditorScreen(
        templateUuid: null,
        presetConfig: state.extra as LayerConfig?,
      ),
    ),
    GoRoute(
      path: '/editor/:uuid',
      builder: (context, state) => EditorScreen(
        templateUuid: state.pathParameters['uuid'],
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
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/saved')) return 1;
    return 0;
  }
}
