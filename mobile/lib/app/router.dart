import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runvibe_mobile/core/di/injection.dart';
import 'package:runvibe_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:runvibe_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:runvibe_mobile/features/home/presentation/pages/home_shell.dart';
import 'package:runvibe_mobile/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:runvibe_mobile/features/tracking/presentation/pages/tracking_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
    GoRoute(
      path: '/tracking',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<TrackingBloc>(),
        child: const TrackingPage(),
      ),
    ),
  ],
);
