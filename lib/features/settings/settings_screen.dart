import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/permission_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColors.premiumBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -1,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('PREFERENCES'),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage daily smart reminders',
                    onTap: () async => await PermissionService.requestNotificationPermission(),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeSelector(context, ref, themeMode),
                  const SizedBox(height: 40),
                  _buildSectionTitle('ACCOUNT'),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out of your account',
                    onTap: () => ref.read(authControllerProvider.notifier).signOut(),
                    isDestructive: true,
                  ),
                  const SizedBox(height: 40),
                  _buildSectionTitle('INFO'),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    icon: Icons.auto_awesome_rounded,
                    title: 'App Version',
                    subtitle: 'v1.0.4 Premium',
                    onTap: null,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingItem(
                    icon: Icons.code_rounded,
                    title: 'Crafted By',
                    subtitle: 'The Antigravity Team',
                    onTap: null,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.3),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.redAccent.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDestructive ? Colors.redAccent : AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: onTap != null ? Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.2)) : null,
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              const Text('Visual Theme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildThemeToggle(ref, 'Light', Icons.light_mode_rounded, ThemeMode.light, currentMode == ThemeMode.light),
              _buildThemeToggle(ref, 'Dark', Icons.dark_mode_rounded, ThemeMode.dark, currentMode == ThemeMode.dark),
              _buildThemeToggle(ref, 'Auto', Icons.settings_brightness_rounded, ThemeMode.system, currentMode == ThemeMode.system),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(WidgetRef ref, String label, IconData icon, ThemeMode mode, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white.withOpacity(0.4), size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
