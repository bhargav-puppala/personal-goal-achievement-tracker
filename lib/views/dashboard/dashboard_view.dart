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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Personal Goal Tracker',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'SDG 3 & 4',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Convert your long-term ambitions into manageable daily actions.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const GoalFormView()));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Goal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
