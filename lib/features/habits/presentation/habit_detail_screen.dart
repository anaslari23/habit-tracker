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

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: CustomScrollView(
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
                ),
              ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.02),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.1), width: 1),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                  Text(
                    title,
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.02)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final date = DateTime.now().subtract(Duration(days: 34 - index));
              final log = logs.firstWhere(
                (l) => AppDateUtils.isSameDay(l.date, date),
                orElse: () => HabitLogModel(id: '', habitId: habit.id, userId: '', date: date, status: HabitStatus.pending),
              );
              
              final isCompleted = log.status == HabitStatus.completed;
              final isToday = AppDateUtils.isSameDay(date, DateTime.now());
              final isFuture = date.isAfter(DateTime.now());

              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  color: isFuture 
                      ? Colors.white.withOpacity(0.01)
                      : isCompleted ? AppColors.primary : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5) : null,
                  boxShadow: isCompleted ? [
                    BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 8, spreadRadius: -2)
                  ] : null,
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
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.02)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              final dayName = AppDateUtils.formatDayName(date).substring(0, 3).toUpperCase();
              final hasLog = logs.any((l) => AppDateUtils.isSameDay(l.date, date) && l.status == HabitStatus.completed);
              
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    width: 32,
                    height: hasLog ? 100 : 24,
                    decoration: BoxDecoration(
                      gradient: hasLog ? AppColors.activeGradient : null,
                      color: hasLog ? null : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: hasLog ? [
                        BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                      ] : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dayName,
                    style: TextStyle(
                      color: hasLog ? Colors.white : Colors.white.withOpacity(0.2),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
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
          'Detailed History',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        if (recentLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F26),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.02)),
            ),
            child: Column(
              children: [
                Icon(Icons.history_rounded, color: Colors.white.withOpacity(0.1), size: 40),
                const SizedBox(height: 12),
                Text(
                  'No activity recorded yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLogs.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final log = recentLogs[index];
              final isSuccess = log.status == HabitStatus.completed;
              final accentColor = isSuccess ? AppColors.primary : Colors.redAccent;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1F26),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.02)),
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.02), blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_rounded : Icons.block_rounded,
                        color: accentColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppDateUtils.formatDate(log.date),
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            log.status == HabitStatus.completed ? 'Goal Achieved' : 'Task Skipped',
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.1), size: 18),
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
