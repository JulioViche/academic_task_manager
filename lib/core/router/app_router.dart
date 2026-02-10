import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/pages/home_screen.dart';
import '../../presentation/pages/login_screen.dart';
import '../../presentation/pages/onboarding_screen.dart';

import '../../presentation/pages/grades/grades_screen.dart';
import '../../presentation/pages/subjects_screen.dart';
import '../../presentation/pages/tasks_screen.dart';
import '../../presentation/pages/calendar/calendar_screen.dart';
import '../../presentation/pages/auth/register_screen.dart';
import '../../presentation/pages/auth/forgot_password_screen.dart';
import '../../presentation/pages/profile/profile_screen.dart';
import '../../presentation/pages/profile/edit_profile_screen.dart';
import '../../presentation/pages/profile/notifications_screen.dart';
import '../../presentation/pages/profile/help_screen.dart';
import '../../presentation/pages/settings_screen.dart';
import '../../presentation/widgets/organisms/navigation_shell.dart';
import '../../presentation/pages/sync/sync_history_screen.dart';
import '../../presentation/pages/pdf/readings_screen.dart';
import '../../presentation/pages/pdf/pdf_reader_screen.dart';
import '../../presentation/pages/subjects/subject_detail_screen.dart';
import '../../presentation/pages/privacy_policy_screen.dart';
import '../../domain/entities/reading_entity.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return NavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/subjects',
            builder: (context, state) => const SubjectsScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/grades',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GradesScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/sync-history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SyncHistoryScreen(),
      ),
      GoRoute(
        path: '/readings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReadingsScreen(),
      ),
      GoRoute(
        path: '/pdf-reader',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final reading = state.extra as Reading;
          return PDFReaderScreen(reading: reading);
        },
      ),
      GoRoute(
        path: '/subjects/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubjectDetailScreen(subjectId: id);
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
}
