import 'package:flutter/material.dart';
import '../models/milestone.dart';
import '../core/theme/app_colors.dart';

/// Interactive tile displaying milestone progress, daily focus status, and actions.
class MilestoneTile extends StatelessWidget {
  final Milestone milestone;
  final ValueChanged<bool?> onToggleCompletion;
  final VoidCallback onToggleDailyFocus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDailyFocusAction;

  const MilestoneTile({
    super.key,
    required this.milestone,
    required this.onToggleCompletion,
    required this.onToggleDailyFocus,
    required this.onEdit,
    required this.onDelete,
    this.showDailyFocusAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isDone = milestone.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone
            ? (isDark
                  ? AppColors.accent.withValues(alpha: 0.08)
                  : AppColors.accent.withValues(alpha: 0.05))
            : (isDark
                  ? AppColors.darkSurfaceSubtle
                  : AppColors.lightSurfaceSubtle),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? AppColors.accent.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Completion Checkbox
          SizedBox(
            width: 32,
            height: 32,
            child: Checkbox(
              value: milestone.isCompleted,
              activeColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: onToggleCompletion,
            ),
          ),
          const SizedBox(width: 8),

          // Milestone title & details
          Expanded(
            child: Text(
              milestone.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isDone ? FontWeight.w400 : FontWeight.w500,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone
                    ? (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted)
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
              ),
            ),
          ),

          // Daily Focus toggle button
          if (showDailyFocusAction)
            IconButton(
              icon: Icon(
                milestone.isDailyFocus
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 20,
                color: milestone.isDailyFocus
                    ? AppColors.warning
                    : (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
              ),
              tooltip: milestone.isDailyFocus
                  ? 'Remove from Daily Focus'
                  : 'Add to Daily Focus',
              onPressed: onToggleDailyFocus,
            ),

          // Actions Menu (Edit / Delete)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Edit Title', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(fontSize: 13, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
