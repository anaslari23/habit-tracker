import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../tracking/habit_log_model.dart';
import '../../tracking/tracking_controller.dart';
import '../data/habit_model.dart';
import 'add_edit_habit_screen.dart';

class HabitDetailScreen extends ConsumerWidget {
  final HabitModel habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogsAsync = ref.watch(allLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.premiumBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditHabitScreen(habit: habit)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1F26), Color(0xFF0F1115)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: allLogsAsync.when(
          data: (allLogs) {
            final habitLogs = allLogs.where((l) => l.habitId == habit.id).toList();
            final stats = _calculateStats(habit, habitLogs);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        _buildStatsCards(context, stats),
                        const SizedBox(height: 32),
                        _buildContributionGrid(context, habit, habitLogs),
                        const SizedBox(height: 32),
                        _buildWeeklyProgress(context, habitLogs),
                        const SizedBox(height: 32),
                        _buildHistoryList(context, habit, habitLogs),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habit.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.repeat_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Daily • ${habit.activeDays.length}/7 days',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, _HabitStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildGlassCard(
            context,
            'Current Streak',
            '${stats.streak}',
            'Days',
            Icons.bolt_rounded,
            const Color(0xFFF8961E),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassCard(
            context,
            'Completion',
            '${(stats.completionRate * 100).toInt()}%',
            '+2% this wk',
            Icons.auto_graph_rounded,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionGrid(BuildContext context, HabitModel habit, List<HabitLogModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last 35 Days',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(24),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final date = DateTime.now().subtract(Duration(days: 34 - index));
              final log = logs.firstWhere(
                (l) => AppDateUtils.isSameDay(l.date, date),
                orElse: () => HabitLogModel(id: '', habitId: habit.id, userId: '', date: date, status: HabitStatus.pending),
              );
              
              final isCompleted = log.status == HabitStatus.completed;
              final isFuture = date.isAfter(DateTime.now());

              return Container(
                decoration: BoxDecoration(
                  color: isFuture 
                      ? Colors.white.withOpacity(0.02)
                      : isCompleted ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress(BuildContext context, List<HabitLogModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Activity',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              final dayName = AppDateUtils.formatDayName(date).substring(0, 1);
              final hasLog = logs.any((l) => AppDateUtils.isSameDay(l.date, date) && l.status == HabitStatus.completed);
              
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: hasLog ? 80 : 20,
                    decoration: BoxDecoration(
                      color: hasLog ? AppColors.primary : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dayName,
                    style: TextStyle(
                      color: hasLog ? Colors.white : Colors.white.withOpacity(0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context, HabitModel habit, List<HabitLogModel> logs) {
    final recentLogs = logs.where((l) => l.status != HabitStatus.pending).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Record History',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        if (recentLogs.isEmpty)
          Center(
            child: Text(
              'No logs yet',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLogs.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final log = recentLogs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1F26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.02)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: log.status == HabitStatus.completed ? AppColors.primary.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        log.status == HabitStatus.completed ? Icons.check_rounded : Icons.close_rounded,
                        color: log.status == HabitStatus.completed ? AppColors.primary : Colors.red,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.formatDate(log.date),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          log.status == HabitStatus.completed ? 'Achieved' : 'Skipped',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  _HabitStats _calculateStats(HabitModel habit, List<HabitLogModel> logs) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    int streak = 0;
    int totalActiveDays = 0;
    int completedActiveDays = 0;

    DateTime current = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
    while (current.isBefore(startOfDay.add(const Duration(days: 1)))) {
      final isActive = habit.activeDays.contains(current.weekday);
      if (isActive) {
        totalActiveDays++;
        final log = logs.firstWhere((l) => AppDateUtils.isSameDay(l.date, current), orElse: () => HabitLogModel(id: '', habitId: habit.id, userId: '', date: current, status: HabitStatus.pending));
        if (log.status == HabitStatus.completed) {
          completedActiveDays++;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    // Streak logic
    current = startOfDay;
    while (current.isAfter(habit.startDate.subtract(const Duration(days: 1)))) {
      final isActive = habit.activeDays.contains(current.weekday);
      if (isActive) {
        final log = logs.firstWhere((l) => AppDateUtils.isSameDay(l.date, current), orElse: () => HabitLogModel(id: '', habitId: habit.id, userId: '', date: current, status: HabitStatus.pending));
        if (log.status == HabitStatus.completed) {
          streak++;
        } else if (log.status == HabitStatus.pending && AppDateUtils.isSameDay(current, startOfDay)) {
          // Skip today if pending
        } else {
          break;
        }
      }
      current = current.subtract(const Duration(days: 1));
    }

    return _HabitStats(
      streak: streak,
      completionRate: totalActiveDays > 0 ? completedActiveDays / totalActiveDays : 0.0,
    );
  }
}

class _HabitStats {
  final int streak;
  final double completionRate;

  _HabitStats({
    required this.streak,
    required this.completionRate,
  });
}
