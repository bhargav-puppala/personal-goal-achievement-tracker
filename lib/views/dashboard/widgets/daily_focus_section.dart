import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../viewmodels/goal_provider.dart';

/// Daily Focus checklist section on the home dashboard.
class DailyFocusSection extends StatelessWidget {
  const DailyFocusSection({super.key});

  void _showAddFocusDialog(BuildContext context) {
    final provider = context.read<GoalProvider>();
    final activeGoals = provider.goals
        .where((g) => !g.effectiveIsCompleted)
        .toList();

    // Flatten all uncompleted milestones
    final available = <Map<String, dynamic>>[];
    final focusSet = provider.dailyFocusIds.toSet();

    for (final goal in activeGoals) {
      for (final m in goal.milestones) {
        if (!m.isCompleted && !focusSet.contains(m.id) && !m.isDailyFocus) {
          available.add({'goal': goal, 'milestone': m});
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    "Select Today's Focus Milestone",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a milestone from your active goals to focus on today.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (available.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No pending milestones available.\nCreate a goal or add milestones first!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.lightTextMuted),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: available.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = available[index];
                          final goal = item['goal'];
                          final milestone = item['milestone'];
                          final catColor = AppConstants.getCategoryColor(
                            goal.category,
                          );

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                AppConstants.getCategoryIcon(goal.category),
                                color: catColor,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              milestone.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              goal.title,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.accent,
                              ),
                              onPressed: () {
                                provider.toggleDailyFocus(
                                  goal.id,
                                  milestone.id,
                                );
                                Navigator.of(ctx).pop();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<GoalProvider>();
    final focusItems = provider.dailyFocusItems;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Focus",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Prioritize high-impact actions for today',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddFocusDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    'Add Focus',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Daily Focus Checklist
            if (focusItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 28,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No focus milestones selected for today',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap "Add Focus" or star any milestone to prioritize it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: focusItems.length,
                separatorBuilder: (_, i) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = focusItems[index];
                  final isDone = item.milestone.isCompleted;
                  final catColor = AppConstants.getCategoryColor(
                    item.goal.category,
                  );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.accent.withValues(alpha: 0.08)
                          : (isDark
                                ? AppColors.darkSurfaceSubtle
                                : AppColors.lightSurfaceSubtle),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDone
                            ? AppColors.accent.withValues(alpha: 0.3)
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isDone,
                          activeColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (_) {
                            provider.toggleMilestoneCompletion(
                              item.goal.id,
                              item.milestone.id,
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.milestone.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isDone
                                      ? (isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted)
                                      : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    item.goal.title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: catColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.goal.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: catColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.lightTextMuted,
                          ),
                          tooltip: 'Remove from Today',
                          onPressed: () {
                            provider.toggleDailyFocus(
                              item.goal.id,
                              item.milestone.id,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
