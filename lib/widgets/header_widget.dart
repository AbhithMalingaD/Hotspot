import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Brand ────────────────────────────────────────────────────
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.appAccent.withOpacity(0.20),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.appAccent.withOpacity(0.30)),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: AppColors.appAccent, size: 16),
            ),
            const SizedBox(width: 8),
            Text('HOTSPOT', style: AppTextStyles.brandTitle),
          ]),

          // ── Actions ──────────────────────────────────────────────────
          Row(children: [
            _HeaderButton(
              icon: Icons.notifications_none_rounded,
              hasUnread: true,
              onTap: () => context
                  .read<AppProvider>()
                  .setNotificationOpen(true),
            ),
            const SizedBox(width: 10),
            _HeaderButton(
              icon: Icons.person_outline_rounded,
              onTap: () =>
                  context.read<AppProvider>().setProfileOpen(true),
              filled: true,
            ),
          ]),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasUnread;
  final bool filled;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.hasUnread = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? AppColors.appAccent
                : Colors.white.withOpacity(0.08),
            border: filled
                ? null
                : Border.all(
                    color: Colors.white.withOpacity(0.20)),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color:
                          AppColors.appAccent.withOpacity(0.40),
                      blurRadius: 15,
                    )
                  ]
                : [],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (hasUnread)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.appBg, width: 2),
              ),
            ),
          ),
      ]),
    );
  }
}