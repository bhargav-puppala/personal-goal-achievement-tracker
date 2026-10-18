import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/goal_provider.dart';

/// Filtering, search, and sorting controls for the dashboard goal list.
class GoalFilterChips extends StatelessWidget {
  const GoalFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<GoalProvider>();

    final allCategories = ['All', ...AppConstants.categories];
    final allStatuses = ['All', 'Active', 'Completed', 'Overdue'];
    final sortOptions = ['Deadline', 'Priority', 'Newest', 'Title'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar and Sort Selector
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search goals or milestones...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => provider.setSearchQuery(''),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Sort Dropdown
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceSubtle
                    : AppColors.lightSurfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: provider.sortBy,
                  icon: const Icon(Icons.sort_rounded, size: 18),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  dropdownColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  items: sortOptions.map((opt) {
                    return DropdownMenuItem(
                      value: opt,
                      child: Text('Sort: $opt'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) provider.setSortBy(val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Status Segment / Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: allStatuses.map((status) {
              final isSelected = provider.selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                  ),
                  selectedColor: isDark ? AppColors.darkAccent : AppColors.sage,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? AppColors.darkAccent : AppColors.sage)
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                    ),
                  ),
                  onSelected: (_) => provider.setSelectedStatus(status),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: allCategories.map((category) {
              final isSelected = provider.selectedCategory == category;
              final catColor = category == 'All'
                  ? (isDark ? AppColors.darkAccent : AppColors.sage)
                  : AppConstants.getCategoryColor(category);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: category == 'All'
                      ? null
                      : Icon(
                          AppConstants.getCategoryIcon(category),
                          size: 14,
                          color: isSelected ? Colors.white : catColor,
                        ),
                  label: Text(category),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                  ),
                  backgroundColor: isSelected
                      ? catColor
                      : (isDark
                            ? AppColors.darkSurfaceSubtle
                            : AppColors.lightSurfaceSubtle),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? catColor
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                    ),
                  ),
                  onPressed: () => provider.setSelectedCategory(category),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
