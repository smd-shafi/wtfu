import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wtfu/dependency_injection/injection.dart';
import 'package:wtfu/features/alarm/presentation/screens/home_screen.dart';
import 'package:wtfu/features/alarm/presentation/screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: sl<GlobalKey<NavigatorState>>(),
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
