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
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isCompleted 
              ? AppColors.primary.withOpacity(0.1) 
              : Colors.white.withOpacity(0.02),
        ),
        boxShadow: isCompleted ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          )
        ] : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Subtle Glossy Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.02),
                      Colors.transparent,
                      Colors.black.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
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
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: isCompleted ? Colors.white.withOpacity(0.2) : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                              child: Text(habit.title),
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
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.05), size: 20),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isActive ? 1.1 : 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
                boxShadow: isActive ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
                size: 18,
              ),
            ),
          );
        },
      ),
    );
  }
}
