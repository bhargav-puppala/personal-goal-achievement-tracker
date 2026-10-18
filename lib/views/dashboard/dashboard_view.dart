import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/goal_provider.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/empty_state.dart';
import '../goal_details/goal_details_view.dart';
import '../goal_form/goal_form_view.dart';
import 'widgets/overview_cards.dart';
import 'widgets/daily_focus_section.dart';
import 'widgets/goal_filter_chips.dart';

/// Main Home Dashboard view showing overview statistics, Daily Focus, and filterable goals.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  Widget _buildSdgBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccentSubtle : AppColors.sagePale,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_rounded,
            size: 14,
            color: isDark ? AppColors.darkAccent : AppColors.sage,
          ),
          const SizedBox(width: 5),
          Text(
            'SDG 3 & 4',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkAccent : AppColors.sageDark,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewGoalButton(BuildContext context, {bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GoalFormView()),
          );
        },
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'New Goal',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<GoalProvider>();
    final goals = provider.filteredGoals;

    final now = DateTime.now();
    final dateString = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.initialize(),
          child: CustomScrollView(
            slivers: [
              // Dashboard App Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Responsive Header Block
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 600;

                          if (!isCompact) {
                            // Desktop / Tablet Layout (>= 600px):
                            // Title & subtitle on left; SDG Badge and New Goal button aligned on right
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateString.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: isDark
                                              ? AppColors.darkTextMuted
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Personal Goal Tracker',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22,
                                          letterSpacing: -0.4,
                                          height: 1.2,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Convert your long-term ambitions into manageable daily actions.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildSdgBadge(isDark),
                                    const SizedBox(width: 10),
                                    _buildNewGoalButton(context),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // Mobile Compact Layout (< 600px):
                            // Row 1: Date & Title on left, SDG Badge on right
                            // Row 2: Subtitle
                            // Row 3: New Goal button spanning width with centered icon and label
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dateString.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                              color: isDark
                                                  ? AppColors.darkTextMuted
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Personal Goal Tracker',
                                            style: theme.textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              letterSpacing: -0.4,
                                              height: 1.2,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSdgBadge(isDark),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Convert your long-term ambitions into manageable daily actions.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildNewGoalButton(context, isFullWidth: true),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Overview Cards
                      const OverviewCards(),
                      const SizedBox(height: 16),

                      // Daily Focus Checklist
                      const DailyFocusSection(),
                      const SizedBox(height: 20),

                      // Section Title & Goal Filters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Goals (${provider.goals.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const GoalFilterChips(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Goals List / Empty State
              if (provider.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (goals.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: provider.goals.isEmpty
                        ? Icons.flag_outlined
                        : Icons.search_off_rounded,
                    title: provider.goals.isEmpty
                        ? 'No Goals Created Yet'
                        : 'No Matching Goals',
                    description: provider.goals.isEmpty
                        ? 'Create your first goal to begin tracking milestones and building consistency.'
                        : 'Try adjusting your search query, status, or category filter.',
                    actionLabel: provider.goals.isEmpty ? 'Create Goal' : null,
                    onAction: provider.goals.isEmpty
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GoalFormView(),
                              ),
                            );
                          }
                        : null,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final goal = goals[index];
                      return GoalCard(
                        goal: goal,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GoalDetailsView(goalId: goal.id),
                            ),
                          );
                        },
                      );
                    }, childCount: goals.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
