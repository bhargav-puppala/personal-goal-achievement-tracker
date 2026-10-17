import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'repositories/goal_repository.dart';
import 'viewmodels/goal_provider.dart';
import 'viewmodels/settings_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local persistence and notification services
  final storageService = LocalStorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  // 2. Instantiate repository
  final goalRepository = GoalRepository(storageService: storageService);

  // 3. Instantiate view models / providers
  final settingsProvider = SettingsProvider(storageService: storageService);
  await settingsProvider.loadSettings();

  final goalProvider = GoalProvider(
    repository: goalRepository,
    notificationService: notificationService,
  );
  await goalProvider.initialize();

  // 4. Run application with Provider tree
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<GoalProvider>.value(value: goalProvider),
      ],
      child: const PersonalGoalTrackerApp(),
    ),
  );
}
