import 'package:flutter/material.dart';
import 'package:runvibe_mobile/app/router.dart';
import 'package:runvibe_mobile/app/theme.dart';

class RunVibeApp extends StatelessWidget {
  const RunVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RunVibe',
      debugShowCheckedModeBanner: false,
      theme: RunVibeTheme.light,
      darkTheme: RunVibeTheme.dark,
      routerConfig: appRouter,
    );
  }
}
