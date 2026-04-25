import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/templates/presentation/home_screen.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/templates/presentation/saved_list_screen.dart';
import '../../features/gallery/presentation/gallery_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/user_profile_screen.dart';
import '../../features/profile/presentation/ranking_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
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
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
        ),
        GoRoute(
          path: '/saved',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const SavedListScreen()),
        ),
        GoRoute(
          path: '/gallery',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const GalleryScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const SettingsScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const ProfileScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _fadeRoute(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/profile/:uid',
      pageBuilder: (context, state) => _fadeRoute(
        state,
        UserProfileScreen(uid: state.pathParameters['uid']!),
      ),
    ),
    GoRoute(
      path: '/ranking',
      pageBuilder: (context, state) => _fadeRoute(state, const RankingScreen()),
    ),
    GoRoute(
      path: '/privacy',
      pageBuilder: (context, state) =>
          _fadeRoute(state, const PrivacyPolicyScreen()),
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
              context.go('/gallery');
            case 3:
              context.go('/profile');
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
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'ギャラリー',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/saved')) return 1;
    if (location.startsWith('/gallery')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}
