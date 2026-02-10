import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Give a minimum splash duration for branding/User experience
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if onboarding has been seen
    final prefs = ref.read(sharedPreferencesProvider);
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!seenOnboarding) {
      context.go('/onboarding');
      return;
    }

    // Check authentication status
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (authState.user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
