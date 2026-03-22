import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reels_assignment/presentation/route/app_router.dart';

void main() {
  test('keeps home route as reels home', () {
    final router = AppRouter();
    final route = router.onGenerateRoute(
      const RouteSettings(name: AppRouter.home),
    );

    expect(route.settings.name, AppRouter.home);
  });

  test('redirects unknown route to reels home', () {
    final router = AppRouter();
    final route = router.onGenerateRoute(
      const RouteSettings(name: '/some-future-route'),
    );

    expect(route.settings.name, AppRouter.home);
  });
}
