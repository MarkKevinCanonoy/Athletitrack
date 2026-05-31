import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/screens/auth_screen.dart';
import '../ui/screens/otp_screen.dart';
import 'providers/auth_provider.dart';

import '../ui/screens/coach_dashboard_screen.dart';
import '../ui/screens/team_detail_screen.dart';
import '../ui/screens/coach_calendar_screen.dart';
import '../ui/screens/athlete_dashboard_screen.dart';
import '../ui/screens/athlete_team_feed_screen.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref ref;
}

// Create a router provider so it can react to auth state changes
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    // Redirect logic acts as our Auth Guard
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/otp';
      
      if (!authState.isAuthenticated) {
        // If not logged in, they must be on login or otp page
        return isLoggingIn ? null : '/login';
      }

      // If they are logged in and try to go to login, send them to their dashboard
      if (isLoggingIn) {
        return authState.role == 'Coach' ? '/coach/dashboard' : '/athlete/dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/coach/dashboard',
        builder: (context, state) => const CoachDashboardScreen(),
      ),
      GoRoute(
        path: '/coach/calendar',
        builder: (context, state) => const CoachCalendarScreen(),
      ),
      GoRoute(
        path: '/coach/team/:teamName',
        builder: (context, state) {
          final teamName = state.pathParameters['teamName'] ?? 'Team';
          final teamData = state.extra as Map<String, dynamic>? ?? {};
          return TeamDetailScreen(teamName: teamName, teamData: teamData);
        },
      ),
      GoRoute(
        path: '/athlete/dashboard',
        builder: (context, state) => const AthleteDashboardScreen(),
      ),
      GoRoute(
        path: '/athlete/team/:teamName',
        builder: (context, state) {
          final teamName = state.pathParameters['teamName'] ?? 'Team';
          final teamData = state.extra as Map<String, dynamic>? ?? {};
          return AthleteTeamFeedScreen(teamName: teamName, teamData: teamData);
        },
      ),
    ],
  );
});
