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
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'widgets/habit_grid_view.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/analytics_dashboard.dart';

class HabitListScreen extends ConsumerStatefulWidget {
  const HabitListScreen({super.key});

  @override
  ConsumerState<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends ConsumerState<HabitListScreen> {
  int _currentIndex = 0;
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final habitsStream = ref.watch(habitsStreamProvider);
    final today = DateTime.now();
    final List<Widget> screens = [
      _buildDashboard(habitsStream, today),
      const NotesScreen(),
      const SettingsScreen(),
      const Center(child: Text('Community (Coming Soon)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      const Center(child: Text('Analytics (Coming Soon)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Scaffold(
          backgroundColor: AppColors.premiumBlack,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C1F26), Color(0xFF0F1115)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                if (!isMobile) _buildTopNav(context) else _buildMobileHeader(context),
                Expanded(
                  child: screens[_currentIndex],
                ),
              ],
            ),
          ),
          bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
          floatingActionButton: _currentIndex == 0 ? _buildFAB(context) : null,
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddEditHabitScreen()),
      ),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text('New Habit', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, bottom: 12, left: 24, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    ref.watch(authStateProvider).value?.displayName?.split(' ').first ?? 'Anas',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF94A3B8)),
            ),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
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
            _buildSmallNavItem(4, Icons.bar_chart_rounded, 'Stats'),
            _buildSmallNavItem(2, Icons.settings_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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
    );
  }

  Widget _buildDashboard(
    AsyncValue<List<HabitModel>> habitsStream,
    DateTime today,
  ) {
    final todayFormatted = AppDateUtils.formatFullDate(today);
    
    return habitsStream.when(
      data: (habits) {
        final logsStream = ref.watch(allLogsProvider);
        
        return logsStream.when(
          data: (allLogs) {
            final todayHabits = habits.where((h) => h.activeDays.contains(today.weekday)).toList();
            final completedCount = todayHabits.where((h) {
              final log = allLogs.firstWhere(
                (l) => l.habitId == h.id && AppDateUtils.isSameDay(l.date, today),
                orElse: () => HabitLogModel(id: '', habitId: '', userId: '', date: today, status: HabitStatus.pending)
              );
              return log.status == HabitStatus.completed;
            }).length;

            final progress = todayHabits.isEmpty ? 0.0 : completedCount / todayHabits.length;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                                Text(
                                  todayFormatted,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                  color: AppColors.primary,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${(progress * 100).toInt()}% Done',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = todayHabits[index];
                        final log = allLogs.firstWhere(
                          (l) => l.habitId == habit.id && AppDateUtils.isSameDay(l.date, today),
                          orElse: () => HabitLogModel(id: '', habitId: habit.id, userId: '', date: today, status: HabitStatus.pending),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildStadiumHabitTile(habit, log.status, today),
                        );
                      },
                      childCount: todayHabits.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStadiumHabitTile(HabitModel habit, HabitStatus status, DateTime today) {
    final isCompleted = status == HabitStatus.completed;
    final isSkipped = status == HabitStatus.skipped;

    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(42), // Full stadium
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(42),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HabitDetailScreen(habit: habit)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (isCompleted ? AppColors.primary : Colors.white).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getHabitIcon(habit.title),
                    color: isCompleted ? AppColors.primary : Colors.white.withOpacity(0.6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted ? 'Completed' : 'Pending',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final newStatus = isCompleted ? HabitStatus.pending : HabitStatus.completed;
                    ref.read(trackingControllerProvider.notifier).toggleHabitStatus(habit.id, today, newStatus);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? AppColors.primary : Colors.white.withOpacity(0.1),
                        width: 2.5,
                      ),
                      color: isCompleted ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getHabitIcon(String title) {
    title = title.toLowerCase();
    if (title.contains('meditation')) return Icons.self_improvement_rounded;
    if (title.contains('water') || title.contains('drink')) return Icons.water_drop_rounded;
    if (title.contains('run') || title.contains('walk')) return Icons.directions_run_rounded;
    if (title.contains('read') || title.contains('book')) return Icons.menu_book_rounded;
    if (title.contains('sleep')) return Icons.nightlight_round;
    if (title.contains('workout') || title.contains('gym')) return Icons.fitness_center_rounded;
    return Icons.auto_awesome_rounded;
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_box_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'HabitTracker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(width: 64),
          _buildNavItem(0, Icons.check_box_outlined, 'Habits'),
          _buildNavItem(1, Icons.description_outlined, 'Notes'),
          _buildNavItem(4, Icons.bar_chart_outlined, 'Analytics'),
          _buildNavItem(2, Icons.settings_outlined, AppStrings.settings),
          const Spacer(),
          Row(
            children: [
              Text(
                'Welcome, ${ref.watch(authStateProvider).value?.displayName ?? 'Anas'}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, size: 16, color: AppColors.primary),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: Colors.grey),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 40),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade400, size: 22),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(List<HabitModel> habits, List<HabitLogModel> logs) {
    final today = DateTime.now();
    final todayHabits = habits.where((h) => h.activeDays.contains(today.weekday)).toList();
    final completedCount = todayHabits.where((h) {
      final log = logs.firstWhere((l) => l.habitId == h.id, orElse: () => HabitLogModel(id: '', habitId: '', userId: '', date: today, status: HabitStatus.pending));
      return log.status == HabitStatus.completed;
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Remaining',
            '${todayHabits.length - completedCount}',
            Icons.pending_actions_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ref.watch(allLogsProvider).when(
            data: (allLogs) {
              int maxStreak = 0;
              for (final habit in habits) {
                final habitLogs = allLogs.where((l) => l.habitId == habit.id).toList();
                final streak = _calculateCurrentStreak(habitLogs);
                if (streak > maxStreak) maxStreak = streak;
              }
              return _buildStatCard(
                'Best Streak',
                '$maxStreak ⚡',
                Icons.bolt_rounded,
                Colors.orange,
              );
            },
            loading: () => _buildStatCard('Best Streak', '--', Icons.bolt_rounded, Colors.orange),
            error: (_, __) => _buildStatCard('Best Streak', '0', Icons.bolt_rounded, Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateCurrentStreak(List<HabitLogModel> logs) {
    if (logs.isEmpty) return 0;
    
    final sortedLogs = [...logs]..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Normalize checkDate to midnight
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (int i = 0; i < sortedLogs.length; i++) {
      final logDate = DateTime(sortedLogs[i].date.year, sortedLogs[i].date.month, sortedLogs[i].date.day);
      
      if (sortedLogs[i].status == HabitStatus.completed) {
        if (logDate.isAtSameMomentAs(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (logDate.isBefore(checkDate)) {
          // If we missed a day, stop streak unless it's today and we haven't completed it yet
          if (i == 0 && AppDateUtils.isSameDay(DateTime.now(), checkDate)) {
             // Still potentially a streak if we complete today
             checkDate = checkDate.subtract(const Duration(days: 1));
             continue; 
          }
          break;
        }
      } else if (sortedLogs[i].status == HabitStatus.skipped) {
         // Skip doesn't break streak but doesn't increment it
         if (logDate.isAtSameMomentAs(checkDate)) {
           checkDate = checkDate.subtract(const Duration(days: 1));
         }
      } else if (logDate.isAtSameMomentAs(checkDate)) {
         if (AppDateUtils.isSameDay(DateTime.now(), checkDate)) {
           // Not completed today yet, check yesterday
           checkDate = checkDate.subtract(const Duration(days: 1));
         } else {
           break;
         }
      }
    }
    return streak;
  }

  Widget _buildHabitList(
    AsyncValue<List<HabitModel>> habitsStream,
    AsyncValue<List<HabitLogModel>> logsStream,
    DateTime today,
  ) {
    return habitsStream.when(
      data: (habits) {
        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, size: 64, color: AppColors.primary.withOpacity(0.3)),
                ),
                const SizedBox(height: 24),
                Text(
                  'No habits yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Start your journey by adding a habit!', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditHabitScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add My First Habit'),
                ),
              ],
            ),
          );
        }

        final todayHabits = habits.where((h) => h.activeDays.contains(today.weekday)).toList();

        if (todayHabits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.wb_sunny_rounded, size: 64, color: Colors.orange.withOpacity(0.3)),
                ),
                const SizedBox(height: 24),
                Text(
                  'No habits for today',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Take it easy and enjoy your day!', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return logsStream.when(
          data: (logs) {
            final pendingHabits = todayHabits.where((h) {
              final log = logs.firstWhere((l) => l.habitId == h.id, orElse: () => HabitLogModel(id: '', habitId: h.id, userId: '', date: today, status: HabitStatus.pending));
              return log.status == HabitStatus.pending;
            }).toList();

            final completedHabits = todayHabits.where((h) {
              final log = logs.firstWhere((l) => l.habitId == h.id, orElse: () => HabitLogModel(id: '', habitId: h.id, userId: '', date: today, status: HabitStatus.pending));
              return log.status != HabitStatus.pending;
            }).toList();

            if (pendingHabits.isEmpty && completedHabits.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.completed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.completed),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'All Done for Today!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('You\'ve completed all your habits. Great job!', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                if (pendingHabits.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Text('Remaining', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  ...pendingHabits.map((habit) => _buildHabitTile(habit, logs, today)),
                ],
                if (completedHabits.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    child: Text('Completed', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  ...completedHabits.map((habit) => Opacity(
                    opacity: 0.6,
                    child: _buildHabitTile(habit, logs, today),
                  )),
                ],
                const SizedBox(height: 100), // Space for FAB
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHabitTile(HabitModel habit, List<HabitLogModel> logs, DateTime today) {
    final log = logs.firstWhere(
      (l) => l.habitId == habit.id,
      orElse: () => HabitLogModel(
        id: '',
        habitId: habit.id,
        userId: '',
        date: today,
        status: HabitStatus.pending,
      ),
    );

    return HabitTile(
      habit: habit,
      status: log.status,
      onStatusChanged: (newStatus) {
        ref.read(trackingControllerProvider.notifier).toggleHabitStatus(
              habit.id,
              today,
              newStatus,
            );
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habit: habit),
          ),
        );
      },
      onDelete: () {
        ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
      },
    );
  }
}
