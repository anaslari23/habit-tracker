import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/permission_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: AppColors.premiumBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.premiumBlack,
            expandedHeight: 90,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage daily smart reminders',
                    onTap: () async => await PermissionService.requestNotificationPermission(),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('ACCOUNT'),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out of your account',
                    onTap: () => ref.read(authControllerProvider.notifier).signOut(),
                    isDestructive: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('INFO'),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    icon: Icons.auto_awesome_rounded,
                    title: 'App Version',
                    subtitle: 'v1.0.4 Premium',
                    onTap: null,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    icon: Icons.code_rounded,
                    title: 'Crafted By',
                    subtitle: 'Anas Lari',
                    onTap: null,
                  ),
                  const SizedBox(height: 32),
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
    final accentColor = isDestructive ? Colors.redAccent : AppColors.primary;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withOpacity(0.1), width: 1.5),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.1), size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
