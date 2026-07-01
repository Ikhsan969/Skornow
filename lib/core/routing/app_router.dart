import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/news_detail_page.dart';
import '../../features/home/data/models/news_article_model.dart';
import '../../features/bookmark/presentation/pages/bookmark_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'root_shell_page.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final index = _locationToIndex(state.uri.toString());
          return RootShellPage(
            currentIndex: index,
            onTap: (i) => context.go(_indexToLocation(i)),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/bookmarks',
            builder: (context, state) => const BookmarkPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final article = state.extra as NewsArticleModel;
          return NewsDetailPage(article: article);
        },
      ),
    ],
  );

  static int _locationToIndex(String location) {
    if (location.startsWith('/bookmarks')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  static String _indexToLocation(int index) {
    switch (index) {
      case 1:
        return '/bookmarks';
      case 2:
        return '/settings';
      default:
        return '/';
    }
  }
}
