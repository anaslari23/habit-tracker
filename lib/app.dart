import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_screen.dart';
import 'features/habits/presentation/habit_list_screen.dart';

class HabitTrackerApp extends ConsumerWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const HabitListScreen();
          }
          return const AuthScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
