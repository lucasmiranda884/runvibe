import 'package:flutter/material.dart';
import 'package:runvibe_mobile/app/router.dart';
import 'package:runvibe_mobile/app/theme.dart';
import 'package:runvibe_mobile/app/theme_controller.dart';

class RunVibeApp extends StatelessWidget {
  const RunVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeController,
      builder: (context, themeMode, _) => MaterialApp.router(
        title: 'RunVibe',
        debugShowCheckedModeBanner: false,
        theme: RunVibeTheme.light,
        darkTheme: RunVibeTheme.dark,
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
