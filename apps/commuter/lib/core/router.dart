import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/map/map_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/routes/route_search_screen.dart';
import '../features/routes/route_detail_screen.dart';
import '../features/crowding/crowding_report_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Dev mode: skip auth redirect when Supabase isn't initialized
      try {
        final session = Supabase.instance.client.auth.currentSession;
        final onAuthPage = state.matchedLocation == '/login';

        if (session == null && !onAuthPage) return '/login';
        if (session != null && onAuthPage) return '/';
      } catch (_) {
        // Supabase not initialized — allow all routes through
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MapScreen(),
        routes: [
          GoRoute(
            path: 'routes',
            builder: (context, state) => const RouteSearchScreen(),
          ),
          GoRoute(
            path: 'routes/:id',
            builder: (context, state) =>
                RouteDetailScreen(routeId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'crowding/:beaconId',
            builder: (context, state) =>
                CrowdingReportScreen(beaconId: state.pathParameters['beaconId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
