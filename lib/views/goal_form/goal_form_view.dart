import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../models/goal.dart';
import '../../viewmodels/goal_provider.dart';

/// Form screen for creating or editing a Goal.
class GoalFormView extends StatefulWidget {
  final Goal? initialGoal;

  const GoalFormView({super.key, this.initialGoal});

  @override
  State<GoalFormView> createState() => _GoalFormViewState();
}

class _GoalFormViewState extends State<GoalFormView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedPriority;
  DateTime? _selectedTargetDate;
  bool _isSubmitting = false;

  // For dynamically adding initial milestones during creation
  final List<TextEditingController> _milestoneControllers = [];

  bool get isEditing => widget.initialGoal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.initialGoal;

    _titleController = TextEditingController(text: goal?.title ?? '');
    _descController = TextEditingController(text: goal?.description ?? '');
    _selectedCategory = goal?.category ?? 'Academic';
    _selectedPriority = goal?.priority ?? 'Medium';
    _selectedTargetDate = goal?.targetDate;

    if (!isEditing) {
      // Provide two default empty milestone fields for new goal creation
      _milestoneControllers.add(TextEditingController());
      _milestoneControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final c in _milestoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addMilestoneRow() {
    setState(() {
      _milestoneControllers.add(TextEditingController());
    });
  }

  void _removeMilestoneRow(int index) {
    if (_milestoneControllers.length > 1) {
      setState(() {
        final c = _milestoneControllers.removeAt(index);
        c.dispose();
      });
    }
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final initial = _selectedTargetDate ?? now.add(const Duration(days: 7));
    final firstDate = now.subtract(const Duration(days: 365));
    final lastDate = now.add(const Duration(days: 365 * 5));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.getCategoryColor(_selectedCategory),
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<GoalProvider>();
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    try {
      if (isEditing) {
        final current = widget.initialGoal!;
        final updated = current.copyWith(
          title: title,
          description: description,
          category: _selectedCategory,
          priority: _selectedPriority,
          targetDate: _selectedTargetDate,
          clearTargetDate: _selectedTargetDate == null,
        );
        await provider.updateGoal(updated);
      } else {
        final milestoneTitles = _milestoneControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();

        await provider.createGoal(
          title: title,
          description: description,
          category: _selectedCategory,
          priority: _selectedPriority,
          targetDate: _selectedTargetDate,
          initialMilestoneTitles: milestoneTitles,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Goal updated successfully'
                  : 'Goal created successfully',
            ),
            backgroundColor: AppColors.accentDark,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving goal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = AppConstants.getCategoryColor(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Goal' : 'Create New Goal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _saveGoal,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(isEditing ? 'Update' : 'Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: catColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title input
            Text(
              'Goal Title *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              maxLength: 120,
              decoration: const InputDecoration(
                hintText: 'e.g. Master Data Structures & Algorithms',
                prefixIcon: Icon(Icons.title_rounded, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a goal title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description input
            Text(
              'Description (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Why is this goal important? What is your strategy?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection
            Text(
              'Category *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final color = AppConstants.getCategoryColor(cat);

                return ChoiceChip(
                  avatar: Icon(
                    AppConstants.getCategoryIcon(cat),
                    size: 15,
                    color: isSelected ? Colors.white : color,
                  ),
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: color,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Priority Selection
            Text(
              'Priority',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Low', 'Medium', 'High'].map((p) {
                final isSelected = _selectedPriority == p;
                final pColor = AppColors.getPriorityColor(p);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? pColor.withValues(alpha: 0.15)
                            : null,
                        side: BorderSide(
                          color: isSelected
                              ? pColor
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          width: isSelected ? 1.8 : 1,
                        ),
                        foregroundColor: isSelected
                            ? pColor
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                      ),
                      onPressed: () => setState(() => _selectedPriority = p),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Target Date Deadline
            Text(
              'Target Completion Date',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTargetDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedTargetDate == null
                            ? 'Select deadline (Optional)'
                            : AppDateUtils.formatShortDate(_selectedTargetDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedTargetDate != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _selectedTargetDate != null
                              ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary)
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                    if (_selectedTargetDate != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () =>
                            setState(() => _selectedTargetDate = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Initial Milestones (when creating new goal)
            if (!isEditing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Initial Milestones',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addMilestoneRow,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Add Milestone',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Break down this goal into actionable steps. You can add more later.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ..._milestoneControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceSubtle
                              : AppColors.lightSurfaceSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'e.g. Read chapters 1-3, Complete Lab 1',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      if (_milestoneControllers.length > 1) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () => _removeMilestoneRow(index),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
