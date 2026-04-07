import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF6B7380).withOpacity(0.28),
                  const Color(0xFF303A4B).withOpacity(0.88),
                  const Color(0xFF182337).withOpacity(0.96),
                ],
                stops: const [0, 0.34, 1],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.32),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 28,
                  right: 28,
                  top: 6,
                  child: _BottomNavGlassStreak(
                    height: 28,
                    colors: [
                      Color(0x18FFFFFF),
                      Color(0x142FD0BD),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 24,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.appAccent.withOpacity(0.10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: AppTab.values.map((tab) {
                    final isActive = app.activeTab == tab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => app.setTab(tab),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.appAccent,
                                      Color(0xFF10C7BE),
                                    ],
                                  )
                                : null,
                            color: isActive ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.appAccent.withOpacity(0.28)
                                  : Colors.transparent,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.appAccent.withOpacity(0.38),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _icon(tab),
                                size: 18,
                                color: isActive
                                    ? Colors.white
                                    : AppTheme.textSecondary(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _label(tab),
                                style: AppTextStyles.label.copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : AppTheme.textSecondary(context),
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _icon(AppTab tab) {
    switch (tab) {
      case AppTab.map:      return Icons.map_outlined;
      case AppTab.space:    return Icons.grid_view_rounded;
      case AppTab.activity: return Icons.bar_chart_rounded;
      case AppTab.saved:    return Icons.bookmark_outline_rounded;
    }
  }

  String _label(AppTab tab) {
    switch (tab) {
      case AppTab.map:      return 'Map';
      case AppTab.space:    return 'Space';
      case AppTab.activity: return 'Activity';
      case AppTab.saved:    return 'Saved';
    }
  }
}

class _BottomNavGlassStreak extends StatelessWidget {
  final double height;
  final List<Color> colors;

  const _BottomNavGlassStreak({
    required this.height,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}
