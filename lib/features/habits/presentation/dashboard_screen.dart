import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/habit_tile.dart';
import '../../tracking/habit_log_model.dart';
import '../../tracking/tracking_controller.dart';
import '../../habits/controller/habit_controller.dart';
import '../../auth/auth_controller.dart';
import '../../habits/data/habit_model.dart';
import 'habit_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final userName = ref.watch(userNameProvider);
    final today = DateTime.now();

    return habitsAsync.when(
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
            final todayFormatted = AppDateUtils.formatFullDate(today);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SafeArea(
                  child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
                                    Text(
                                      userName != null && userName.isNotEmpty ? 'Hi, $userName' : 'Daily Habits',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary.withValues(alpha: 0.6)),
                                        const SizedBox(width: 6),
                                        Text(
                                          todayFormatted.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                _buildProgressRing(progress),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildInsightSnippet(todayHabits, completedCount),
                          ],
                        ),
                      ),
                    ),
                    if (todayHabits.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wb_sunny_rounded, size: 64, color: Colors.white.withOpacity(0.05)),
                              const SizedBox(height: 16),
                              Text(
                                'No habits scheduled for today',
                                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final habit = todayHabits[index];
                              final log = allLogs.firstWhere(
                                (l) => l.habitId == habit.id && AppDateUtils.isSameDay(l.date, today),
                                orElse: () => HabitLogModel(id: '', habitId: habit.id, userId: '', date: today, status: HabitStatus.pending),
                              );
                              return HabitTile(
                                habit: habit,
                                status: log.status,
                                onStatusChanged: (newStatus) {
                                  ref.read(trackingControllerProvider.notifier).toggleHabitStatus(habit.id, today, newStatus);
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => HabitDetailScreen(habit: habit)),
                                  );
                                },
                                onDelete: () {
                                  ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
                                },
                              );
                            },
                            childCount: todayHabits.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 100),
                        child: Center(
                          child: Text(
                            'Keep going!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
    );
  }

  Widget _buildProgressRing(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 54,
          height: 54,
          child: CircularProgressIndicator(
          value: 1.0,
            strokeWidth: 4,
            color: Colors.white.withOpacity(0.03),
          ),
        ),
        SizedBox(
          width: 54,
          height: 54,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            color: AppColors.primary,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildInsightSnippet(List<HabitModel> todayHabits, int completedCount) {
    if (todayHabits.isEmpty) return const SizedBox.shrink();

    final remaining = todayHabits.length - completedCount;
    final message = remaining == 0 
        ? "Excellent! You've crushed all targets." 
        : "$remaining habits left for today.";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Insights',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
