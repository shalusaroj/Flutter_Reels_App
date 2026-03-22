import 'package:flutter/material.dart';
import 'package:reels_assignment/injection_container.dart';
import 'package:reels_assignment/presentation/route/app_router.dart';
import 'package:reels_assignment/presentation/theme/app_slide_transition_builder.dart';
import 'package:reels_assignment/presentation/theme/app_theme.dart';

class ReelsAssignmentApp extends StatelessWidget {
  const ReelsAssignmentApp({
    super.key,
    this.appRouter,
    this.initialRoute = AppRouter.home,
  });

  final AppRouter? appRouter;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final resolvedRouter =
        appRouter ??
        (getIt.isRegistered<AppRouter>() ? getIt<AppRouter>() : AppRouter());
    final transitionTheme = PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const AppSlideTransitionBuilder(),
      },
    );

    return MaterialApp(
      title: 'Reels Assignment',
      debugShowCheckedModeBanner: false,
      navigatorKey: resolvedRouter.navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: resolvedRouter.onGenerateRoute,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: transitionTheme,
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        pageTransitionsTheme: transitionTheme,
      ),
    );
  }
}
