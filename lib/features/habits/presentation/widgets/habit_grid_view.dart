import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../tracking/habit_log_model.dart';
import '../../../tracking/tracking_controller.dart';
import '../../data/habit_model.dart';

class HabitGridView extends ConsumerWidget {
  final List<HabitModel> habits;
  final List<HabitLogModel> logs;
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;

  const HabitGridView({
    super.key,
    required this.habits,
    required this.logs,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final isMobile = MediaQuery.of(context).size.width < 768;
    final habitColumnWidth = isMobile ? 120.0 : 160.0;

    return Column(
      children: [
        _buildMonthHeader(context),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F26),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.02)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _buildScrollableGrid(context, ref, daysInMonth, habitColumnWidth),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white, size: 28),
            onPressed: () => onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month - 1)),
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white, size: 28),
            onPressed: () => onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableGrid(BuildContext context, WidgetRef ref, int daysInMonth, double habitColumnWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Days Header
          Row(
            children: [
              Container(
                width: habitColumnWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
                ),
                child: const Text('HABIT', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
              ),
              for (int i = 1; i <= daysInMonth; i++)
                Container(
                  width: 44,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
                  ),
                  child: Text('$i', style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 11)),
                ),
            ],
          ),
          // Habit Rows
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: habits.map((habit) => _buildHabitRow(context, ref, habit, daysInMonth, habitColumnWidth)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitRow(BuildContext context, WidgetRef ref, HabitModel habit, int daysInMonth, double habitColumnWidth) {
    return Row(
      children: [
        Container(
          width: habitColumnWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.02)),
              right: BorderSide(color: Colors.white.withOpacity(0.02)),
            ),
          ),
          child: Text(
            habit.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        for (int i = 1; i <= daysInMonth; i++)
          _buildDayCell(ref, habit, i),
      ],
    );
  }

  Widget _buildDayCell(WidgetRef ref, HabitModel habit, int day) {
    final date = DateTime(selectedMonth.year, selectedMonth.month, day);
    final log = logs.firstWhere(
      (l) => AppDateUtils.isSameDay(l.date, date) && l.habitId == habit.id,
      orElse: () => HabitLogModel(id: '', habitId: habit.id, userId: '', date: date, status: HabitStatus.pending),
    );

    final isCompleted = log.status == HabitStatus.completed;
    final isActive = habit.activeDays.contains(date.weekday);

    return InkWell(
      onTap: isActive ? () {
        HapticFeedback.lightImpact();
        final newStatus = isCompleted ? HabitStatus.pending : HabitStatus.completed;
        ref.read(trackingControllerProvider.notifier).toggleHabitStatus(habit.id, date, newStatus);
      } : null,
      child: Container(
        width: 44,
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.02)),
            right: BorderSide(color: Colors.white.withOpacity(0.02)),
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: !isActive 
                  ? Colors.white.withOpacity(0.01) 
                  : (isCompleted ? AppColors.primary : Colors.white.withOpacity(0.03)),
              borderRadius: BorderRadius.circular(6),
              boxShadow: isCompleted ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
            ),
            child: isCompleted ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
          ),
        ),
      ),
    );
  }
}
