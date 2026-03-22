import 'package:flutter/material.dart';
import 'package:reels_assignment/features/reels/presentation/pages/reels_page.dart';

class AppRouter {
  static const String home = '/';

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Current app scope keeps only the reels experience as home.
    // Unknown routes are redirected to the same page so navigation stays safe.
    final resolvedSettings =
        settings.name == home ? settings : const RouteSettings(name: home);
    return _materialRoute(const ReelsPage(), resolvedSettings);
  }

  MaterialPageRoute<dynamic> _materialRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
