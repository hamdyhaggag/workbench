import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/items/presentation/screens/item_detail_screen.dart';
import '../../features/items/presentation/screens/add_edit_item_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/items/presentation/screens/archive_screen.dart';
import '../../features/items/presentation/screens/trash_screen.dart';
import '../widgets/shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (_, __) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/projects/:id',
            builder: (_, state) => ProjectDetailScreen(
              projectId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/items/:id',
            builder: (_, state) => ItemDetailScreen(
              itemId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/items/:id/edit',
            builder: (_, state) => AddEditItemScreen(
              itemId: state.pathParameters['id'],
              initialType: null,
              initialProjectId: null,
            ),
          ),
          GoRoute(
            path: '/add',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddEditItemScreen(
                itemId: null,
                initialType: extra?['type'],
                initialProjectId: extra?['projectId'],
              );
            },
          ),
          GoRoute(
            path: '/search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/archive',
            builder: (_, __) => const ArchiveScreen(),
          ),
          GoRoute(
            path: '/trash',
            builder: (_, __) => const TrashScreen(),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
