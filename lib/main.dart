import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_shell.dart';
import 'providers/app_provider.dart';
import 'theme.dart';

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
          brightness: brightness,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: isDarkMode ? AppColors.appBgDark : AppColors.appBgLight,
    colorScheme: colorScheme,
    textTheme: isDarkMode
        ? GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
        : GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Hotspot',
            theme: buildAppTheme(appProvider.isDarkMode),
            debugShowCheckedModeBanner: false,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}