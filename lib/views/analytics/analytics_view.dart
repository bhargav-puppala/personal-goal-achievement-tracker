import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/goal_provider.dart';
import 'widgets/weekly_completion_chart.dart';
import 'widgets/category_distribution_chart.dart';
import 'widgets/achievements_list.dart';

/// Analytics & Insights screen showing live progress, streaks, weekly activity, and category distribution.
class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<GoalProvider>();

    final streak = provider.streak;
    final milestoneRate = provider.overallMilestoneCompletionRate;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Progress')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.initialize(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header text
              Text(
                'Performance Insights',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Live metrics derived from your stored milestones and completed actions.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Streak & Milestone Completion Rate Banner
              Row(
                children: [
                  // Streak Card
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.fireStreak,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Current Streak',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${streak.currentStreak} Days',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.fireStreak,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Best: ${streak.longestStreak} days (${streak.totalActiveDays} active)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Overall Milestone Completion Rate
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.task_alt_rounded,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Milestone Rate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${milestoneRate.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${provider.completedMilestonesCount} of ${provider.totalMilestonesCount} done',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Goals Breakdown Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryCountPill(
                        label: 'Total Goals',
                        count: provider.totalGoalsCount,
                        color: AppColors.primary,
                      ),
                      _SummaryCountPill(
                        label: 'Active',
                        count: provider.activeGoalsCount,
                        color: AppColors.info,
                      ),
                      _SummaryCountPill(
                        label: 'Completed',
                        count: provider.completedGoalsCount,
                        color: AppColors.accent,
                      ),
                      _SummaryCountPill(
                        label: 'Overdue',
                        count: provider.overdueGoalsCount,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weekly Milestone Activity Chart
              WeeklyCompletionChart(data: provider.weeklyMilestoneActivity),
              const SizedBox(height: 16),

              // Category Distribution
              CategoryDistributionChart(
                distribution: provider.categoryGoalDistribution,
                totalGoals: provider.totalGoalsCount,
              ),
              const SizedBox(height: 16),

              // Recent Achievements Timeline
              AchievementsList(achievements: provider.recentAchievements),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCountPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryCountPill({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
