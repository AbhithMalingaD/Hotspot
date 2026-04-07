import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Branding ─────────────────────────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, child) =>
                    Opacity(opacity: v, child: child),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.20)),
                      ),
                      child: const Icon(Icons.wifi_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('HOTSPOT', style: AppTextStyles.brandTitle),
                    const SizedBox(height: 8),
                    Text(
                      'The ultimate co-working space platform.\nHow would you like to proceed?',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── User Card ─────────────────────────────────────────────
              _RoleCard(
                title: 'I need a workspace',
                subtitle: 'Find and book desks or rooms',
                icon: Icons.search_rounded,
                accentColor: AppColors.appAccent,
                glowColor: AppColors.appAccent.withOpacity(0.15),
                onTap: () => context
                    .read<AppProvider>()
                    .selectRole(AppRole.user),
              ),

              const SizedBox(height: 16),

              // ── Admin Card ────────────────────────────────────────────
              _RoleCard(
                title: 'I manage a space',
                subtitle: 'Access your admin dashboard',
                icon: Icons.dashboard_rounded,
                accentColor: AppColors.adminAccent,
                glowColor: AppColors.adminAccent.withOpacity(0.15),
                onTap: () => context
                    .read<AppProvider>()
                    .selectRole(AppRole.admin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color glowColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.appCard.withOpacity(0.80),
            border: Border.all(
                color: widget.accentColor.withOpacity(0.30)),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor,
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: widget.accentColor.withOpacity(0.30)),
                ),
                child: Icon(widget.icon,
                    color: widget.accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(widget.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: widget.accentColor
                                .withOpacity(0.80))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: widget.accentColor.withOpacity(0.60),
                  size: 16),
            ],
          ),
        ),
      ),
    );
  }
}