import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/app_date_utils.dart';
import 'custom_badge.dart';

/// Reusable card component displaying a Goal's category, progress, priority, and deadline.
class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categoryColor = AppConstants.getCategoryColor(goal.category);
    final priorityColor = AppColors.getPriorityColor(goal.priority);
    final isCompleted = goal.effectiveIsCompleted;
    final isOverdue = goal.isOverdue();
    final progress = goal.normalizedProgress;
    final progressPct = goal.progressPercentage.toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category Badge, Priority Badge, Status
              Row(
                children: [
                  CustomBadge(
                    label: goal.category,
                    color: categoryColor,
                    icon: AppConstants.getCategoryIcon(goal.category),
                  ),
                  const SizedBox(width: 8),
                  CustomBadge(label: goal.priority, color: priorityColor),
                  const Spacer(),
                  if (isCompleted)
                    const CustomBadge(
                      label: 'Completed',
                      color: AppColors.accent,
                      icon: Icons.check_circle_rounded,
                      isFilled: true,
                    )
                  else if (isOverdue)
                    const CustomBadge(
                      label: 'Overdue',
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                      isFilled: true,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                goal.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.25,
                ),
              ),

              if (goal.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  goal.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.3,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.lightSurfaceSubtle,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.accent : categoryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Footer: Progress % & Milestones count vs Deadline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '$progressPct%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppColors.accent
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${goal.completedMilestonesCount}/${goal.totalMilestonesCount} milestones)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (goal.targetDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: isOverdue
                              ? AppColors.error
                              : (isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.getRelativeDeadlineText(
                            goal.targetDate!,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isOverdue
                                ? AppColors.error
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
