import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../habits/data/habit_model.dart';
import '../../habits/controller/habit_controller.dart';
import '../../tracking/habit_log_model.dart';
import '../../tracking/tracking_controller.dart';
import '../../../../core/utils/date_utils.dart';

class GlobalStats {
  final int streak;
  final double completionRate;
  final int perfectDays;
  final int totalCompletions;
  final int totalActiveHabits;

  const GlobalStats({
    required this.streak,
    required this.completionRate,
    required this.perfectDays,
    required this.totalCompletions,
    required this.totalActiveHabits,
  });
}

final globalStatsProvider = AsyncNotifierProvider<StatsController, GlobalStats>(StatsController.new);

class StatsController extends AsyncNotifier<GlobalStats> {
  @override
  FutureOr<GlobalStats> build() async {
    final habits = await ref.watch(habitsStreamProvider.future);
    final logs = await ref.watch(allLogsProvider.future);
    return _calculateGlobalStats(habits, logs);
  }

  GlobalStats _calculateGlobalStats(List<HabitModel> habits, List<HabitLogModel> logs) {
    final today = DateTime.now();
    
    // 1. Total Completions
    final totalCompletions = logs.where((l) => l.status == HabitStatus.completed).length;

    // 2. Global Consistency Streak
    int streak = 0;
    DateTime current = today;
    
    if (logs.any((l) => AppDateUtils.isSameDay(l.date, current) && l.status == HabitStatus.completed)) {
      streak++;
    }
    
    current = current.subtract(const Duration(days: 1));
    while (true) {
      final hasActivity = logs.any((l) => AppDateUtils.isSameDay(l.date, current) && l.status == HabitStatus.completed);
      if (hasActivity) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // 3. Perfect Days (Last 30 days)
    int perfectDays = 0;
    for (int i = 0; i < 30; i++) {
        final d = today.subtract(Duration(days: i));
        final weekday = d.weekday;
        final habitsActiveOnDay = habits.where((h) => h.activeDays.contains(weekday)).length;
        if (habitsActiveOnDay == 0) continue;

        final completionsOnDay = logs.where((l) => AppDateUtils.isSameDay(l.date, d) && l.status == HabitStatus.completed).length;
        if (completionsOnDay >= habitsActiveOnDay) perfectDays++;
    }

    // 4. Completion Rate (All time)
    // Simple approx: Total Completions / (Total Active Habits * 30 days)? 
    // Let's stick to a simpler metric for now: Rate over last 30 days.
    double completionRate = 0.0;
    int totalOpportunities = 0;
    int completionsLast30 = 0;
    
    for (int i = 0; i < 30; i++) {
       final d = today.subtract(Duration(days: i));
       final weekday = d.weekday;
       final activeCount = habits.where((h) => h.activeDays.contains(weekday)).length;
       totalOpportunities += activeCount;
       
       final dailyCompletions = logs.where((l) => AppDateUtils.isSameDay(l.date, d) && l.status == HabitStatus.completed).length;
       completionsLast30 += dailyCompletions;
    }
    
    if (totalOpportunities > 0) {
      completionRate = completionsLast30 / totalOpportunities;
    }
    
    return GlobalStats(
      streak: streak,
      completionRate: completionRate,
      perfectDays: perfectDays,
      totalCompletions: totalCompletions,
      totalActiveHabits: habits.length,
    );
  }
}
