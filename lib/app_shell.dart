import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'providers/app_provider.dart';

// Pages
import 'pages/role_selection_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/space_setup_page.dart';
import 'pages/user_app_shell.dart';
import 'pages/admin_dashboard_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(
        children: [
          // ── Decorative background bubbles ──────────────────────────────
          _BackgroundBubbles(),
          // ── Screen router ──────────────────────────────────────────────
          Consumer<AppProvider>(
            builder: (context, app, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _buildScreen(app),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(AppProvider app) {
    switch (app.screen) {
      case AppScreen.roleSelect:
        return const RoleSelectionPage(key: ValueKey('role-select'));
      case AppScreen.signup:
        return SignupPage(
          key: const ValueKey('signup'),
          role: app.role ?? AppRole.user,
        );
      case AppScreen.login:
        return LoginPage(
          key: const ValueKey('login'),
          role: app.role ?? AppRole.user,
        );
      case AppScreen.spaceSetup:
        return const SpaceSetupPage(key: ValueKey('space-setup'));
      case AppScreen.userApp:
        return const UserAppShell(key: ValueKey('user-app'));
      case AppScreen.adminApp:
        return const AdminDashboardPage(key: ValueKey('admin-app'));
    }
  }
}

// ── Decorative background blobs ──────────────────────────────────────────────

class _BackgroundBubbles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        final isAdmin = app.role == AppRole.admin ||
            app.screen == AppScreen.adminApp ||
            app.screen == AppScreen.spaceSetup;

        final accent = isAdmin ? AppColors.adminAccent : AppColors.appAccent;
        final accent2 = isAdmin ? AppColors.adminAccent2 : AppColors.appAccent2;

        final bgColor = isAdmin ? AppColors.adminBg : AppTheme.bg(context);

        return Stack(
          children: [
            Positioned(
              top: -80,
              left: -100,
              child: _Blob(color: accent, size: 380),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -60,
              child: _Blob(color: accent2, size: 260),
            ),
            Positioned(
              bottom: -80,
              left: MediaQuery.of(context).size.width * 0.2,
              child: _Blob(color: accent, size: 320),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.10),
      ),
      child: const BackdropFilter(
        filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
        child: SizedBox(),
      ),
    );
  }
}