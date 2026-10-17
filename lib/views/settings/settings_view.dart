import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/goal_provider.dart';
import '../../viewmodels/settings_provider.dart';
import '../../widgets/confirm_dialog.dart';
import 'widgets/sdg_info_card.dart';

/// Settings & Profile screen for theme preferences, notifications, student roll information, and data backup.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showExportDialog(BuildContext context, String jsonContent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Exported JSON Backup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy to Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonContent));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup copied to clipboard!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Import JSON Backup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your exported JSON data below to restore goals and activity history:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              decoration: const InputDecoration(
                hintText: '{\n  "goals": [...]\n}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final raw = controller.text.trim();
              if (raw.isNotEmpty) {
                final success = await context.read<GoalProvider>().importBackup(
                  raw,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Backup successfully imported!'
                            : 'Invalid backup format. Import failed.',
                      ),
                      backgroundColor: success
                          ? AppColors.accentDark
                          : AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final goalProvider = context.watch<GoalProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Student & Project Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.studentName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Roll Number: ${AppConstants.studentRollNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppConstants.appName} • v${AppConstants.appVersion}',
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // SDG Alignment Card
          const SdgInfoCard(),
          const SizedBox(height: 16),

          // Theme Preference Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ThemeOptionPill(
                        label: 'System',
                        icon: Icons.brightness_auto_rounded,
                        isSelected: settings.themeMode == ThemeMode.system,
                        onTap: () => settings.setThemeMode(ThemeMode.system),
                      ),
                      const SizedBox(width: 8),
                      _ThemeOptionPill(
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                        isSelected: settings.themeMode == ThemeMode.light,
                        onTap: () => settings.setThemeMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 8),
                      _ThemeOptionPill(
                        label: 'Dark',
                        icon: Icons.dark_mode_rounded,
                        isSelected: settings.themeMode == ThemeMode.dark,
                        onTap: () => settings.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications Preference Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications & Reminders',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Goal Deadline Reminders',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Notify when goals approach their target completion date',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    value: settings.notificationsEnabled,
                    activeThumbColor: AppColors.accent,
                    onChanged: (val) => settings.setNotificationsEnabled(val),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Focus Reminder Time',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Morning prompt to review today\'s milestones',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: settings.dailyReminderTime,
                          );
                          if (picked != null) {
                            settings.setDailyReminderTime(picked);
                          }
                        },
                        child: Text(settings.dailyReminderTime.format(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Data Management Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Seed Demo Data
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Load Sample Demo Data',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Populate realistic DSA course, fitness habits, and placement goals',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () async {
                        await goalProvider.seedSampleData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sample demonstration data loaded!',
                              ),
                              backgroundColor: AppColors.accentDark,
                            ),
                          );
                        }
                      },
                      child: const Text('Load Demo'),
                    ),
                  ),
                  const Divider(height: 16),
                  // Export Backup
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.file_download_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Export JSON Backup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Export complete offline goals, milestones, and habit history',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    onTap: () async {
                      final json = await goalProvider.exportBackup();
                      if (context.mounted) _showExportDialog(context, json);
                    },
                  ),
                  const Divider(height: 16),
                  // Import Backup
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.file_upload_outlined,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Import JSON Backup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Restore records from a previously exported backup file',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    onTap: () => _showImportDialog(context),
                  ),
                  const Divider(height: 16),
                  // Clear All Data
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Reset & Clear All Data',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently remove all goals, milestones, focus records, and streaks',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    onTap: () async {
                      final confirmed = await ConfirmDialog.show(
                        context: context,
                        title: 'Clear All Data?',
                        message:
                            'This action is irreversible. All goals, milestones, daily focus items, and activity history will be deleted.',
                        confirmLabel: 'Clear All',
                        confirmColor: AppColors.error,
                      );
                      if (confirmed && context.mounted) {
                        await goalProvider.clearAllData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All data has been cleared.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ThemeOptionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.lightSurfaceSubtle),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
