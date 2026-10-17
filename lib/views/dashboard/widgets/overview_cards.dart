import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/goal_provider.dart';

/// Top live statistics overview cards displaying key metrics.
class OverviewCards extends StatelessWidget {
  const OverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final streak = provider.streak;

    return Column(
      children: [
        // Top streak banner if active
        if (streak.currentStreak > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.fireStreak.withValues(alpha: 0.15),
                  AppColors.warning.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.fireStreak.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.fireStreak,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${streak.currentStreak} Day Streak!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.fireStreak,
                        ),
                      ),
                      Text(
                        streak.completedToday
                            ? 'Great job! You made progress today.'
                            : 'Complete any milestone today to extend your streak!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Grid of 4 live overview metric cards
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Active Goals',
                value: provider.activeGoalsCount.toString(),
                icon: Icons.flag_rounded,
                iconColor: AppColors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'Completed',
                value: provider.completedGoalsCount.toString(),
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Overdue',
                value: provider.overdueGoalsCount.toString(),
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.error,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: "Today's Actions",
                value: provider.todayMilestoneCompletionCount.toString(),
                icon: Icons.bolt_rounded,
                iconColor: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
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
}
