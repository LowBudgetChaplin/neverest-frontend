import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/screens/auth_menu_screen.dart';
import '../../shell/presentation/main_shell_screen.dart';
import 'onboarding_screen.dart';

class LaunchGateScreen extends StatefulWidget {
  const LaunchGateScreen({super.key});

  @override
  State<LaunchGateScreen> createState() => _LaunchGateScreenState();
}

class _LaunchGateScreenState extends State<LaunchGateScreen> {
  static const _prefsKey = 'neverest_onboarding_completed';

  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _loadLaunchState();
  }

  Future<void> _loadLaunchState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_prefsKey) ?? false;
    if (!mounted) {
      return;
    }
    setState(() {
      _showOnboarding = !completed;
      _isLoading = false;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    if (!mounted) {
      return;
    }
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _launchLoading();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _showOnboarding
              ? OnboardingScreen(
                  key: const ValueKey('onboarding'),
                  onFinished: _finishOnboarding,
                  onOpenAuth: _finishOnboarding,
                )
              : _childForAuthState(authState),
        );
      },
    );
  }

  Widget _childForAuthState(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.authenticated:
        return const MainShellScreen(
          key: ValueKey('main-shell'),
        );
      case AuthStatus.initial:
      case AuthStatus.loading:
        return _launchLoading(key: const ValueKey('auth-loading'));
      case AuthStatus.unauthenticated:
      case AuthStatus.unavailable:
      case AuthStatus.failure:
        return const AuthMenuScreen(
          key: ValueKey('auth-menu'),
          initialMode: AuthMenuMode.login,
        );
    }
  }

  Widget _launchLoading({Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: const Color(0xFF0A0A0B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  color: const Color(0xFFFF5A1F),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5A1F).withOpacity(0.35),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(26),
              child: Image.asset(
                'assets/images/nvr_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.terrain_rounded,
                  color: Color(0xFFFF5A1F),
                  size: 72,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5A1F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
