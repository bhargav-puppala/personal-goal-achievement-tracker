import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/goal_provider.dart';

/// Interactive bar chart presenting milestone completion counts over the past 7 days.
class WeeklyCompletionChart extends StatelessWidget {
  final List<DayActivityCount> data;

  const WeeklyCompletionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxVal = data.isEmpty
        ? 1
        : max(1, data.map((d) => d.count).reduce(max));

    final totalCompletedThisWeek = data.fold(0, (sum, d) => sum + d.count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Milestone Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actions completed over the past 7 days',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCompletedThisWeek Done',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bar chart rows
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.map((item) {
                  final ratio = item.count / maxVal;
                  final barHeight = max(6.0, ratio * 90);
                  final isToday = item == data.last;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item.count > 0)
                            Text(
                              '${item.count}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? AppColors.accent
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                              ),
                            )
                          else
                            const SizedBox(height: 14),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight,
                            width: 20,
                            decoration: BoxDecoration(
                              color: item.count == 0
                                  ? (isDark
                                        ? AppColors.darkSurfaceSubtle
                                        : AppColors.lightSurfaceSubtle)
                                  : (isToday
                                        ? AppColors.accent
                                        : AppColors.primary),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.dayLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isToday
                                  ? AppColors.accent
                                  : (isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
