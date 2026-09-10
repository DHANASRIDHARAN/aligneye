import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/vehicle/vehicle_screen.dart';
import '../screens/live_sensors/live_sensors_screen.dart';
import '../screens/alignment/alignment_analysis_screen.dart';
import '../screens/calibration/calibration_screen.dart';
import '../screens/sensor_health/sensor_health_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return BottomNavScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/vehicle',
          builder: (context, state) => const VehicleScreen(),
        ),
        GoRoute(
          path: '/sensors',
          builder: (context, state) => const LiveSensorsScreen(),
        ),
        GoRoute(
          path: '/analysis',
          builder: (context, state) => const AlignmentAnalysisScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Overlay routes (full screen without bottom nav)
    GoRoute(
      path: '/calibration',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CalibrationScreen(),
    ),
    GoRoute(
      path: '/sensor-health',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SensorHealthScreen(),
    ),
    GoRoute(
      path: '/history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/alerts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
