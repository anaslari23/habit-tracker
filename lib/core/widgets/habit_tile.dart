import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../../features/habits/data/habit_model.dart';
import '../../features/tracking/habit_log_model.dart';

class HabitTile extends StatelessWidget {
  final HabitModel habit;
  final HabitStatus status;
  final Function(HabitStatus) onStatusChanged;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.status,
    required this.onStatusChanged,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == HabitStatus.completed;
    final isSkipped = status == HabitStatus.skipped;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  icon: isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                  color: AppColors.primary,
                  isActive: isCompleted,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onStatusChanged(isCompleted ? HabitStatus.pending : HabitStatus.completed);
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: isSkipped ? Icons.close_rounded : Icons.remove_circle_outline_rounded,
                  color: AppColors.skipped,
                  isActive: isSkipped,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onStatusChanged(isSkipped ? HabitStatus.pending : HabitStatus.skipped);
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: TextStyle(
                          color: isCompleted ? Colors.white.withOpacity(0.3) : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (habit.description?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description!,
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.1), size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white.withOpacity(0.03),
          shape: BoxShape.circle,
          boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          size: 18,
        ),
      ),
    );
  }
}
