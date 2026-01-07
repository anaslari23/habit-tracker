import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../tracking/habit_log_model.dart';

class AnalyticsDashboard extends StatelessWidget {
  final List<HabitLogModel> logs;
  final DateTime selectedMonth;

  const AnalyticsDashboard({
    super.key,
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
              const Icon(Icons.insights_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'ACTIVITY INSIGHTS',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: _buildChart(context),
          ),
          const SizedBox(height: 40),
          _buildStatsGrid(context),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final spots = <FlSpot>[];

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, i);
      final completedCount = logs.where((l) => 
        l.date.year == date.year && 
        l.date.month == date.month && 
        l.date.day == date.day && 
        l.status == HabitStatus.completed
      ).length;
      spots.add(FlSpot(i.toDouble(), completedCount.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > daysInMonth) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final totalCompleted = logs.where((l) => l.status == HabitStatus.completed).length;
    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final avgRate = daysInMonth > 0 ? (totalCompleted / daysInMonth) : 0.0;
    
    int maxInDay = 0;
    for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(selectedMonth.year, selectedMonth.month, i);
        final count = logs.where((l) => 
            l.date.year == date.year && 
            l.date.month == date.month && 
            l.date.day == date.day && 
            l.status == HabitStatus.completed
        ).length;
        if (count > maxInDay) maxInDay = count;
    }

    final activeDays = <String>{};
    for (final log in logs) {
        if (log.status == HabitStatus.completed) {
            activeDays.add("${log.date.year}-${log.date.month}-${log.date.day}");
        }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final double cardWidth = isMobile 
            ? (constraints.maxWidth - 16) / 2 
            : (constraints.maxWidth - 48) / 4;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(context, 'TOTAL COMPLETE', '$totalCompleted', AppColors.primary.withOpacity(0.1), cardWidth),
            _buildStatCard(context, 'AVG RATE', '${(avgRate * 100).toInt()}%', AppColors.activeGradient.colors[1].withOpacity(0.1), cardWidth),
            _buildStatCard(context, 'BEST DAY', '$maxInDay', AppColors.accent.withOpacity(0.1), cardWidth),
            _buildStatCard(context, 'ACTIVE DAYS', '${activeDays.length}', AppColors.goal.withOpacity(0.1), cardWidth),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color bgColor, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 26,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              letterSpacing: 0.5,
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.textOnDarkSecondary 
                : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
