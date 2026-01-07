import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/habit_tile.dart';
import '../../auth/auth_controller.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../settings/settings_screen.dart';
import '../../tracking/habit_log_model.dart';
import '../../tracking/tracking_controller.dart';
import '../controller/habit_controller.dart';
import '../data/habit_model.dart';
import 'dashboard_screen.dart';
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'widgets/habit_grid_view.dart';
import '../../stats/presentation/stats_screen.dart';

class HabitListScreen extends ConsumerStatefulWidget {
  const HabitListScreen({super.key});

  @override
  ConsumerState<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends ConsumerState<HabitListScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final habitsStream = ref.watch(habitsStreamProvider);
    final today = DateTime.now();
    final List<Widget> screens = [
      const DashboardScreen(),
      const StatsScreen(),
      const NotesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.premiumBlack,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _currentIndex == 0 ? _buildFAB(context) : null,
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddEditHabitScreen()),
      ),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text('New Habit', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }



  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13151A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.03))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSmallNavItem(0, Icons.calendar_today_rounded, 'Today'),
            _buildSmallNavItem(1, Icons.insert_chart_rounded, 'Stats'),
            _buildSmallNavItem(2, Icons.description_rounded, 'Journal'),
            _buildSmallNavItem(3, Icons.settings_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
