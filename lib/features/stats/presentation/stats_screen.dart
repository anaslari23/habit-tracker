import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../habits/controller/habit_controller.dart'; // Still needed for habits if we need list but controller handles aggregation
import '../../tracking/habit_log_model.dart';
import '../../tracking/tracking_controller.dart';
import '../controller/stats_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(globalStatsProvider);
    final allLogsAsync = ref.watch(allLogsProvider); // Still need logs for charts

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: statsAsync.when(
        data: (stats) {
          return allLogsAsync.when(
            data: (allLogs) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Global Insights',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your consistency across all habits',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Hero Stat Card (Flame)
                              _buildHeroStatCard(context, stats),
                              const SizedBox(height: 32),
                              _buildSummaryRow(context, stats),
                              const SizedBox(height: 32),
                              _buildWeeklyOverview(context, allLogs),
                              const SizedBox(height: 32),
                              _buildMonthlyHeatmap(context, allLogs),
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
            error: (e, _) => Center(child: Text('Error loading logs: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading stats: $e')),
      ),
    );
  }

  Widget _buildHeroStatCard(BuildContext context, GlobalStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8961E).withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF8961E).withOpacity(0.05),
            Colors.transparent,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8961E).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF8961E).withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(color: const Color(0xFFF8961E).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: const Icon(Icons.local_fire_department_rounded, size: 48, color: Color(0xFFF8961E)),
          ),
          const SizedBox(height: 24),
          Text(
            '${stats.streak} Days',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          Text(
            'Consistency Streak',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('Completion Rate', '${(stats.completionRate * 100).toInt()}%'),
              _buildMiniStat('Total Clean Days', '${stats.perfectDays}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, GlobalStats stats) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard('Active Habits', '${stats.totalActiveHabits}', Icons.topic_rounded, AppColors.primary)),
        const SizedBox(width: 16),
        Expanded(child: _buildInfoCard('Total Done', '${stats.totalCompletions}', Icons.check_circle_rounded, const Color(0xFF4ADE80))),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview(BuildContext context, List<HabitLogModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Volume',
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
              
              final completions = logs.where((l) => AppDateUtils.isSameDay(l.date, date) && l.status == HabitStatus.completed).length;
              final maxDaily = 10.0; // Assume max 10 for scaling visual
              final height = (completions / maxDaily * 100).clamp(10.0, 120.0);

              final isToday = AppDateUtils.isSameDay(date, DateTime.now());

              return Column(
                children: [
                  Text(
                    '$completions',
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white.withOpacity(0.3), 
                      fontSize: 10, 
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 32,
                    height: height,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isToday ? AppColors.primary : Colors.white.withOpacity(0.2),
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

  Widget _buildMonthlyHeatmap(BuildContext context, List<HabitLogModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text(
          'Activity Heatmap',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
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
            itemCount: 35, // 5 weeks
            itemBuilder: (context, index) {
              final date = DateTime.now().subtract(Duration(days: 34 - index));
              final completions = logs.where((l) => AppDateUtils.isSameDay(l.date, date) && l.status == HabitStatus.completed).length;
              
              Color color = Colors.white.withOpacity(0.04);
              if (completions > 0) color = AppColors.primary.withOpacity(0.2);
              if (completions > 2) color = AppColors.primary.withOpacity(0.5);
              if (completions > 4) color = AppColors.primary;

              final isFuture = date.isAfter(DateTime.now());
              if (isFuture) color = Colors.transparent;

              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: isFuture ? Border.all(color: Colors.white.withOpacity(0.02)) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
