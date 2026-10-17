import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:personal_goal_tracker/app.dart';
import 'package:personal_goal_tracker/repositories/goal_repository.dart';
import 'package:personal_goal_tracker/viewmodels/goal_provider.dart';
import 'package:personal_goal_tracker/viewmodels/settings_provider.dart';
import 'mocks/mock_storage_service.dart';

void main() {
  testWidgets('Dashboard loads and displays navigation shell with 3 tabs', (
    WidgetTester tester,
  ) async {
    final mockStorage = MockStorageService();
    final repo = GoalRepository(storageService: mockStorage);
    final settingsProvider = SettingsProvider(storageService: mockStorage);
    final goalProvider = GoalProvider(repository: repo);

    await settingsProvider.loadSettings();
    await goalProvider.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider<GoalProvider>.value(value: goalProvider),
        ],
        child: const PersonalGoalTrackerApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app title in header
    expect(find.text('Personal Goal Tracker'), findsOneWidget);

    // Verify navigation tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify FAB
    expect(find.text('New Goal'), findsOneWidget);

    // Tap on Analytics tab
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    // Verify Analytics screen title
    expect(find.text('Performance Insights'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify student roll number display
    expect(find.text('Roll Number: 24PA1A05I4'), findsOneWidget);
  });
}
