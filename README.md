# Personal Goal Achievement Tracker

**Student Roll Number:** `24PA1A05I4`  
**Application Title:** Personal Goal Achievement Tracker  
**Target Platform:** Flutter (Mobile, Desktop, Web)  
**SDK Requirement:** Flutter 3.41+ / Dart 3.11+  
**State Management:** Provider (6.1.5+)  
**Design System:** Material 3  

---

## 1. Project Overview

The **Personal Goal Achievement Tracker** is a modern, local-first productivity and personal achievement application built using Flutter. It is designed to assist students and professionals in converting high-level, long-term ambitions into manageable, granular daily milestones.

By combining an intuitive **Material 3 user interface**, **Daily Focus checklists**, **deterministic streak tracking**, and **real-time analytics**, the application enables users to cultivate disciplined study and wellness routines without relying on third-party cloud accounts, subscription fees, or internet connectivity.

---

## 2. Problem Statement

Modern learners frequently set broad, ambitious goals (e.g., "Crack Placement Interviews", "Learn Data Structures", "Get Physically Fit") but fail to achieve them due to:
1. **Lack of Granular Decomposition:** Goals remain intimidating abstractions without daily actionable milestones.
2. **Cognitive Overload:** Traditional to-do apps display overwhelming backlogs rather than highlighting today's immediate priorities.
3. **Absence of Tangible Reinforcement:** Inconsistent tracking leads to lost momentum and broken habit streaks.
4. **Privacy Concerns and Cloud Dependency:** Many productivity applications require user registration, track personal data, and degrade when offline.

---

## 3. Project Objectives

- **Deconstruct Complex Goals:** Allow users to define goals with categorical tags, priorities, deadlines, and multiple step-by-step milestones.
- **Daily Focus Prioritization:** Provide a dedicated dashboard mechanism for selecting and executing high-impact milestones today.
- **Transparent Progress Computation:** Recalculate progress strictly from milestone states using safe mathematical logic (0–100%, handling zero-milestone edge cases safely).
- **Habit & Streak Consistency:** Calculate consecutive active days from immutable historical activity logs without arbitrary counters.
- **Actionable Analytics:** Offer real-time visualizations for goal distribution, milestone completion rates, and weekly performance trends.
- **Offline-First Resilience:** Ensure all data, preferences, and histories survive application restarts via atomic local storage.

---

## 4. Alignment with UN Sustainable Development Goals (SDGs)

This application is purposefully aligned with two United Nations Sustainable Development Goals:

### SDG 3: Good Health and Well-being
- **Target 3.4 & 3.5:** Promotes mental well-being and physical lifestyle habits by encouraging structured fitness routines, hydration tracking, and mindfulness practices.
- **Application Feature:** Built-in **"Health and Well-being"** and **"Fitness"** goal categories with dedicated tracking, reminders, and habit consistency metrics.

### SDG 4: Quality Education
- **Target 4.4:** Increases the number of youth and adults with relevant skills for employment, decent jobs, and entrepreneurship.
- **Application Feature:** Dedicated **"Academic"** and **"Career"** modules allowing students to track DSA problem-solving, project development, placement prep, and technical certifications with deadline management.

---

## 5. Technology Stack

| Layer | Technology / Package | Purpose |
|---|---|---|
| **Framework** | Flutter 3.41.4 (Channel stable) | Cross-platform UI toolkit |
| **Language** | Dart 3.11.1 | Modern sound null-safe programming |
| **Design Language** | Material 3 (`useMaterial3: true`) | Premium responsive layout, customized theme tokens |
| **State Management** | `provider: ^6.1.5+1` | Reactive, decoupled state and dependency injection |
| **Local Persistence** | `shared_preferences: ^2.5.6` | Atomic JSON storage for goals, history, and focus state |
| **Identifiers** | `uuid: ^4.6.0` | Unique cryptographic IDs for goals and milestones |
| **Date & Time** | `intl: ^0.20.3` | Date formatting and calendar day normalization |
| **Charts & Metrics** | Custom Canvas / Material 3 Bar Visualizers | Real-time weekly milestone activity charts |

---

## 6. Architecture & Directory Structure

The project follows clean architecture principles, separating models, persistence, business logic, and presentation:

```
lib/
├── main.dart                          # Application bootstrap & dependency setup
├── app.dart                           # Material 3 theme wiring & navigation shell
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Roll number, SDG metadata, categories, storage keys
│   ├── theme/
│   │   ├── app_colors.dart            # Semantic tokens (Slate, Emerald, Amber, Fire)
│   │   └── app_theme.dart             # Material 3 light & dark theme definitions
│   └── utils/
│       ├── app_date_utils.dart        # Normalization, relative deadlines, overdue checks
│       └── streak_calculator.dart     # Deterministic streak and active-days calculation
├── models/
│   ├── goal.dart                      # Goal domain entity & progress calculations
│   ├── milestone.dart                 # Milestone domain entity & completion status
│   └── activity_record.dart           # Immutable event record for audit & streak tracking
├── services/
│   ├── storage_service.dart           # Storage contract & JSON persistence engine
│   └── notification_service.dart      # In-app reminder and notification contract
├── repositories/
│   └── goal_repository.dart           # Domain repository & sample data seeder
├── viewmodels/
│   ├── goal_provider.dart             # Central provider for goals, focus, search & analytics
│   └── settings_provider.dart         # Provider for theme mode, notifications, reminders
├── views/
│   ├── dashboard/
│   │   ├── dashboard_view.dart        # Home dashboard with overview cards & goal list
│   │   └── widgets/
│   │       ├── overview_cards.dart    # Live stat metric cards & streak banner
│   │       ├── daily_focus_section.dart # Daily Focus checklist & milestone picker sheet
│   │       └── goal_filter_chips.dart # Search bar, category chips, status pills & sorting
│   ├── goal_details/
│   │   └── goal_details_view.dart     # Full goal view, milestone CRUD & progress bar
│   ├── goal_form/
│   │   └── goal_form_view.dart        # Reusable create/edit goal form with validation
│   ├── analytics/
│   │   ├── analytics_view.dart        # Analytics screen with charts and achievements
│   │   └── widgets/
│   │       ├── weekly_completion_chart.dart # 7-day milestone completion bar chart
│   │       ├── category_distribution_chart.dart # Distribution across life domains
│   │       └── achievements_list.dart # Chronological accomplishment timeline
│   └── settings/
│       ├── settings_view.dart         # Student info, theme mode, export/import, data reset
│       └── widgets/
│           └── sdg_info_card.dart     # Official SDG 3 & SDG 4 social impact details
└── widgets/
    ├── custom_badge.dart              # Status, category, and priority badge pills
    ├── goal_card.dart                 # Reusable dashboard goal card with progress
    ├── milestone_tile.dart            # Interactive milestone tile with checkbox & actions
    ├── empty_state.dart               # Meaningful empty-state graphics & call-to-actions
    └── confirm_dialog.dart            # Destructive action confirmation dialogs
```

---

## 7. Key Features Implemented

1. **Dashboard & Live Statistics:**
   - Real-time counts for active goals, completed goals, overdue goals, and today's actions.
   - Fire streak banner illustrating consecutive active days.
   - Category filtering, status filtering (`All`, `Active`, `Completed`, `Overdue`), and multi-criteria sorting (`Deadline`, `Priority`, `Newest`, `Title`).

2. **Goal & Milestone CRUD Management:**
   - Goal creation with validation (empty title checks, trimmed input, priority selection, category tags, optional deadline picker).
   - Milestone management (inline creation, editing title, deletion with confirmation, reordering).
   - Dynamic progress updates: `Progress = (Completed / Total) * 100%`. Goals with 0 milestones safely show 0% without NaN or divide-by-zero errors.
   - Reopening completed milestones instantly updates the parent goal and streak.

3. **Daily Focus Checklist:**
   - Pin high-priority milestones to "Today's Focus".
   - Direct completion checkbox on the dashboard.
   - Instant synchronization with parent goal progress and activity history.
   - Bottom sheet picker to select pending milestones from active goals.

4. **Analytics & Performance Tracking:**
   - Overall milestone completion rate.
   - 7-Day interactive activity bar chart showing milestone completions for the last 7 calendar days.
   - Category distribution chart with progress bars and percentages.
   - Recent achievements feed logging exact accomplishment timestamps.

5. **Settings, Data Management & SDG Alignment:**
   - Switch between **Light**, **Dark**, and **System** themes.
   - Student roll number (`24PA1A05I4`) and project metadata prominently displayed.
   - Dedicated SDG 3 and SDG 4 impact description cards.
   - One-click **"Load Sample Demo Data"** populating DSA, fitness, placement, and habit goals.
   - Full **JSON Export** (copy to clipboard) and **JSON Import** for data backup and migration.
   - Secure **"Reset & Clear All Data"** protected by a confirmation dialog.

---

## 8. Prerequisites & Installation

### Prerequisites
- Flutter SDK `>=3.0.0` (tested on Flutter `3.41.4`)
- Dart SDK `>=3.0.0` (tested on Dart `3.11.1`)
- Web Browser (Chrome/Edge) or Desktop runner or Android/iOS emulator

### Setup & Run Commands

```bash
# 1. Clone or navigate to the project directory
cd c:\Users\bharg\Flutter-Project

# 2. Get dependencies
flutter pub get

# 3. Verify static analysis (Zero errors/warnings)
flutter analyze

# 4. Run automated test suite (21 passing tests)
flutter test

# 5. Launch application on available device
# For Web (Chrome):
flutter run -d chrome

# For Windows Desktop:
flutter run -d windows

# For Android Device/Emulator:
flutter run -d android
```

---

## 9. Automated Testing Summary

A comprehensive test suite of **21 unit and widget tests** verifies the application's core logic:

- `test/unit/goal_and_milestone_test.dart`
  - Zero-milestone edge cases (0% progress, safe from NaN).
  - Milestone completion and dynamic parent progress calculations.
  - Automatic goal completion rule (all milestones done = completed).
  - Reopening milestone reverts parent completion.
  - Overdue deadline comparison logic with normalized calendar dates.
  - JSON serialization and deserialization integrity.
- `test/unit/streak_calculator_test.dart`
  - Empty history returns 0 streak.
  - Today completion yields 1 streak.
  - Yesterday completion preserves active streak.
  - Consecutive multi-day streaks (3 days = streak 3).
  - Missed day break in consistency resets streak to 0.
  - Same-day multiple completions deduplication.
- `test/unit/goal_provider_test.dart`
  - Empty title validation (throws `ArgumentError`).
  - Goal creation, milestone completion, and activity logging.
  - Daily Focus toggling, deduplication, and persistence.
  - Goal deletion and cleanup of associated records.
  - Reinitialization persistence across fresh provider instances.
  - Live analytics calculations (active, completed, rates, distributions).
- `test/widget_test.dart`
  - Navigation shell rendering with Home, Analytics, and Settings tabs.
  - Tab switching interaction and state preservation.
  - Student roll number verification (`24PA1A05I4`).

Run the test suite with:
```bash
flutter test
```

---

## 10. Screenshots & UI Demonstration

| Dashboard (Overview & Focus) | Goal Details & Milestones | Analytics & Charts | Settings & SDG Alignment |
|---|---|---|---|
| *(Screenshot Placeholder: Home Dashboard with Overview Cards & Daily Focus)* | *(Screenshot Placeholder: Goal Details Screen with Milestones & Progress)* | *(Screenshot Placeholder: Analytics Screen with 7-Day Chart & Categories)* | *(Screenshot Placeholder: Settings with Roll Number 24PA1A05I4 & SDG Info)* |

---

## 11. Known Limitations & Honest Platform Disclosures

- **Platform Native Alarms:** The application runs cross-platform across Web, Windows Desktop, Android, and iOS. On web and desktop environments, system-level background daemon wakeups may be restricted without native service privileges. Therefore, the application implements reliable in-app deadline banners, status pills, and alert reminders alongside standard notification interfaces.
- **Local Storage Scope:** Data is persisted locally on the device via `SharedPreferences` and atomic JSON serialization. No cloud synchronization is performed, guaranteeing complete privacy and zero data leakage.

---

## 12. Future Enhancements

1. Cloud backup integration (e.g. Google Drive / WebDAV) with end-to-end encryption.
2. Recurring milestones (daily habits that automatically reset at midnight).
3. Export analytics reports in PDF format for academic submissions.
4. Voice-input milestone capture.
