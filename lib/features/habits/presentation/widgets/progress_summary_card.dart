import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../tracking/habit_log_model.dart';
import '../../data/habit_model.dart';

class ProgressSummaryCard extends StatelessWidget {
  final List<HabitModel> habits;
  final List<HabitLogModel> logs;
  final DateTime selectedMonth;

  const ProgressSummaryCard({
    super.key,
    required this.habits,
    required this.logs,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'GOAL PROGRESS',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (habits.isEmpty)
             const Text('No habits to track', style: TextStyle(color: Colors.grey))
          else
            Column(
              children: habits.map((habit) => _buildHabitProgress(context, habit)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHabitProgress(BuildContext context, HabitModel habit) {
    final habitLogs = logs.where((l) => l.habitId == habit.id).toList();
    final completedLogs = habitLogs.where((l) => l.status == HabitStatus.completed).length;
    final totalDaysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    
    final progress = totalDaysInMonth > 0 ? completedLogs / totalDaysInMonth : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  habit.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: AppColors.activeGradient,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$completedLogs of $totalDaysInMonth days completed',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
