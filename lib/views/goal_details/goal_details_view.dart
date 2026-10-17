import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../models/goal.dart';
import '../../viewmodels/goal_provider.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/milestone_tile.dart';
import '../../widgets/confirm_dialog.dart';
import '../goal_form/goal_form_view.dart';

/// Comprehensive Goal Details screen showing progress, milestone checklist, and management actions.
class GoalDetailsView extends StatelessWidget {
  final String goalId;

  const GoalDetailsView({super.key, required this.goalId});

  void _showAddMilestoneSheet(BuildContext context, Goal goal) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Milestone',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Complete chapter review quiz',
                  prefixIcon: Icon(Icons.check_box_outlined, size: 20),
                ),
                onSubmitted: (val) {
                  final text = val.trim();
                  if (text.isNotEmpty) {
                    context.read<GoalProvider>().addMilestone(goal.id, text);
                    Navigator.of(ctx).pop();
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        context.read<GoalProvider>().addMilestone(
                          goal.id,
                          text,
                        );
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditMilestoneDialog(
    BuildContext context,
    String goalId,
    String milestoneId,
    String initialTitle,
  ) {
    final controller = TextEditingController(text: initialTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Edit Milestone',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter milestone title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<GoalProvider>().editMilestone(
                  goalId,
                  milestoneId,
                  text,
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteGoal(BuildContext context, Goal goal) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Goal',
      message:
          'Are you sure you want to delete "${goal.title}"? All associated milestones and focus records will be removed.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.error,
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed && context.mounted) {
      await context.read<GoalProvider>().deleteGoal(goal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal deleted successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<GoalProvider>();

    // Retrieve active goal from provider
    final goalMatches = provider.goals.where((g) => g.id == goalId);
    if (goalMatches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal Details')),
        body: const Center(child: Text('Goal not found or was deleted.')),
      );
    }

    final goal = goalMatches.first;
    final categoryColor = AppConstants.getCategoryColor(goal.category);
    final priorityColor = AppColors.getPriorityColor(goal.priority);
    final isDone = goal.effectiveIsCompleted;
    final isOverdue = goal.isOverdue();
    final progress = goal.normalizedProgress;
    final progressPct = goal.progressPercentage.toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Goal',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GoalFormView(initialGoal: goal),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            tooltip: 'Delete Goal',
            onPressed: () => _confirmDeleteGoal(context, goal),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card with category, badges, title, description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      if (isDone)
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
                        )
                      else
                        const CustomBadge(
                          label: 'In Progress',
                          color: AppColors.info,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    goal.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      height: 1.25,
                    ),
                  ),
                  if (goal.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      goal.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Dates information row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.lightSurfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DateInfoPill(
                          label: 'Created',
                          value: AppDateUtils.formatShortDate(goal.createdAt),
                          icon: Icons.calendar_today_outlined,
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        _DateInfoPill(
                          label: 'Deadline',
                          value: goal.targetDate != null
                              ? AppDateUtils.getRelativeDeadlineText(
                                  goal.targetDate!,
                                )
                              : 'None set',
                          icon: Icons.alarm_rounded,
                          isHighlight: isOverdue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress Overview Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Milestone Progress',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$progressPct%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDone ? AppColors.accent : categoryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.lightSurfaceSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? AppColors.accent : categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${goal.completedMilestonesCount} of ${goal.totalMilestonesCount} milestones completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Milestones List Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Milestones (${goal.milestones.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMilestoneSheet(context, goal),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'Add Milestone',
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Milestone Items
          if (goal.milestones.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceSubtle
                    : AppColors.lightSurfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.checklist_rounded,
                    size: 36,
                    color: AppColors.lightTextMuted,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No milestones defined yet.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "Add Milestone" to break this goal into manageable steps.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            ...goal.milestones.map((milestone) {
              return MilestoneTile(
                milestone: milestone,
                onToggleCompletion: (_) {
                  provider.toggleMilestoneCompletion(goal.id, milestone.id);
                },
                onToggleDailyFocus: () {
                  provider.toggleDailyFocus(goal.id, milestone.id);
                },
                onEdit: () {
                  _showEditMilestoneDialog(
                    context,
                    goal.id,
                    milestone.id,
                    milestone.title,
                  );
                },
                onDelete: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: 'Delete Milestone',
                    message: 'Delete "${milestone.title}"?',
                  );
                  if (confirmed) {
                    provider.deleteMilestone(goal.id, milestone.id);
                  }
                },
              );
            }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DateInfoPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _DateInfoPill({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlight
              ? AppColors.error
              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isHighlight
                    ? AppColors.error
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
