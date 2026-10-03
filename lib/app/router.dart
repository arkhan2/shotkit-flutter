import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../features/account/account_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/brand_kits/brand_kit_editor_screen.dart';
import '../features/brand_kits/brand_kits_screen.dart';
import '../features/composer/composer_review_screen.dart';
import '../features/composer/composer_wizard_screen.dart';
import '../features/preview/design_preview_screen.dart';
import '../features/projects/project_detail_screen.dart';
import '../features/projects/project_form_screen.dart';
import '../features/projects/project_setup_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/shell/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(supabaseProvider).auth.currentSession;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      if (session == null) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) return '/app';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app',
                builder: (_, __) => const ProjectsScreen(),
                routes: [
                  GoRoute(
                    path: 'projects/new',
                    builder: (_, __) => const ProjectFormScreen(),
                  ),
                  GoRoute(
                    path: 'projects/:projectId',
                    builder: (_, state) => ProjectDetailScreen(
                      projectId: state.pathParameters['projectId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'setup',
                        builder: (_, state) => ProjectSetupScreen(
                          projectId: state.pathParameters['projectId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'compose',
                        builder: (_, state) => ComposerWizardScreen(
                          projectId: state.pathParameters['projectId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/brand-kits',
                builder: (_, __) => const BrandKitsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, __) => const NewBrandKitScreen(),
                  ),
                  GoRoute(
                    path: ':kitId',
                    builder: (_, state) => BrandKitEditorScreen(
                      kitId: state.pathParameters['kitId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/account',
                builder: (_, __) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/app/designs/:designId',
        builder: (_, state) => DesignPreviewScreen(
          designId: state.pathParameters['designId']!,
        ),
        routes: [
          GoRoute(
            path: 'compose',
            builder: (_, state) => ComposerReviewScreen(
              designId: state.pathParameters['designId']!,
            ),
          ),
        ],
      ),
    ],
  );
});
