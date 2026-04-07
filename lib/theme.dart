import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

class AppColors {
  // Dark mode colours
  static const Color appBgDark     = Color(0xFF0B1426);
  static const Color appCardDark   = Color(0xFF152238);
  static const Color appBorderDark = Color(0xFF1E3354);

  // Light mode colours
  static const Color appBgLight     = Color(0xFFEFF2F7);
  static const Color appCardLight   = Color(0xFFFFFFFF);
  static const Color appBorderLight = Color(0xFFCCD3DE);

  // Legacy aliases
  static const Color appBg   = appBgDark;
  static const Color appCard = appCardDark;

  // Shared accent colours
  static const Color appAccent   = Color(0xFF00C9A7);
  static const Color appAccent2  = Color(0xFF4DD0E1);
  static const Color adminBg      = Color(0xFF0F0C29);
  static const Color adminCard    = Color(0xFF1A1638);
  static const Color adminBorder  = Color(0xFF2D2442);
  static const Color adminBgLight   = Color(0xFFF8FAFC);
  static const Color adminCardLight = Color(0xFFFFFFFF);
  static const Color adminBorderLight = Color(0xFFE2E8F0);
  static const Color adminAccent  = Color(0xFF8B5CF6);
  static const Color adminAccent2 = Color(0xFF6366F1);
  static const Color white        = Colors.white;
  static const Color grey400      = Color(0xFF9CA3AF);
  static const Color grey500      = Color(0xFF6B7280);
  static const Color red400       = Color(0xFFF87171);
  static const Color orange400    = Color(0xFFFB923C);
  static const Color orange500    = Color(0xFFF97316);

  // Light mode text colours
  static const Color lightTextPrimary   = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted     = Color(0xFF64748B);
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME‑AWARE ACCESSOR
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  static bool isDark(BuildContext context) =>
      context.watch<AppProvider>().isDarkMode;

  static Color bg(BuildContext context) =>
      isDark(context) ? AppColors.appBgDark : AppColors.appBgLight;

  static Color cardBg(BuildContext context) =>
      isDark(context) ? AppColors.appCardDark : AppColors.appCardLight;

  static Color borderColor(BuildContext context) =>
      isDark(context) ? AppColors.appBorderDark : AppColors.appBorderLight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : AppColors.lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? AppColors.grey400 : AppColors.lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? AppColors.grey500 : AppColors.lightTextMuted;

  static Color surfaceVariant(BuildContext context) =>
      isDark(context)
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.06);

  static Color dividerColor(BuildContext context) =>
      isDark(context)
          ? Colors.white.withOpacity(0.10)
          : Colors.black.withOpacity(0.12);

  static Color iconColor(BuildContext context) =>
      isDark(context) ? Colors.white : AppColors.lightTextPrimary;

  static Color inputFill(BuildContext context) =>
      isDark(context)
          ? Colors.white.withOpacity(0.05)
          : Colors.white;

  static Color inputBorder(BuildContext context) =>
      isDark(context)
          ? Colors.white.withOpacity(0.10)
          : AppColors.appBorderLight;

  // Admin‑aware colours (use these in admin pages)
  static Color adminBg(BuildContext context) =>
      isDark(context) ? AppColors.adminBg : AppColors.adminBgLight;

  static Color adminCardBg(BuildContext context) =>
      isDark(context) ? AppColors.adminCard : AppColors.adminCardLight;

  static Color adminBorderColor(BuildContext context) =>
      isDark(context) ? AppColors.adminBorder : AppColors.adminBorderLight;

  static Color adminTextPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF1E293B);

  static Color adminTextSecondary(BuildContext context) =>
      isDark(context) ? AppColors.grey400 : const Color(0xFF475569);
}

// ── Dynamic decorations ────────────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration get glassCard => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withOpacity(0.10)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.30),
        blurRadius: 32,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get glassBubble => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withOpacity(0.20)),
    boxShadow: [
      BoxShadow(
        color: AppColors.appAccent.withOpacity(0.15),
        blurRadius: 32,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get adminGlassBubble => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withOpacity(0.20)),
    boxShadow: [
      BoxShadow(
        color: AppColors.adminAccent.withOpacity(0.20),
        blurRadius: 32,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get adminCard => BoxDecoration(
    color: Colors.white.withOpacity(0.03),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
    boxShadow: [
      BoxShadow(
        color: AppColors.adminAccent.withOpacity(0.05),
        blurRadius: 32,
        offset: const Offset(0, 8),
      ),
    ],
  );
}



// ── Text Styles ─────────────────────────────────────────────────────────────
// NOTE: All text styles default to white for dark mode backwards compatibility.
// For light-mode-aware text, use AppTheme.textPrimary(context) on Text widgets.
class AppTextStyles {
  // Default getters (dark mode)
  static TextStyle get heading1 => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white);
  static TextStyle get heading2 => GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white);
  static TextStyle get heading3 => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle get body => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.grey400);
  static TextStyle get label => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.grey400, letterSpacing: 0.5);
  static TextStyle get accent => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.appAccent);
  static TextStyle get brandTitle => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 4.0);

  // Theme-aware text styles — call these when you have a BuildContext
  static TextStyle adaptive(BuildContext context,
      {double fontSize = 14,
      FontWeight fontWeight = FontWeight.w400}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppTheme.textPrimary(context),
      );

  static TextStyle adaptiveSecondary(BuildContext context,
      {double fontSize = 12,
      FontWeight fontWeight = FontWeight.w400}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppTheme.textSecondary(context),
      );
}

extension BoxDecorationCopyWith on BoxDecoration {
  BoxDecoration copyWith({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border,
      boxShadow: boxShadow,
    );
  }
}

// ── ThemeData builder ───────────────────────────────────────────────────────
ThemeData buildAppTheme(bool isDarkMode) {
  final brightness = isDarkMode ? Brightness.dark : Brightness.light;

  final colorScheme = isDarkMode
      ? const ColorScheme.dark(
          primary: AppColors.appAccent,
          secondary: AppColors.appAccent2,
          surface: AppColors.appCardDark,
        )
      : ColorScheme.light(
          primary: AppColors.appAccent,
          secondary: AppColors.appAccent2,
          surface: AppColors.appCardLight,
          onSurface: AppColors.lightTextPrimary,
          brightness: brightness,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor:
        isDarkMode ? AppColors.appBgDark : AppColors.appBgLight,
    colorScheme: colorScheme,
    textTheme: isDarkMode
        ? GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
        : GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
            bodyColor: AppColors.lightTextPrimary,
            displayColor: AppColors.lightTextPrimary,
          ),
    iconTheme: IconThemeData(
      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.appAccent;
        return isDarkMode ? Colors.white54 : Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.appAccent.withOpacity(0.35);
        }
        return isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.grey.withOpacity(0.30);
      }),
    ),
    dividerColor: isDarkMode
        ? Colors.white.withOpacity(0.10)
        : AppColors.appBorderLight,
  );
}