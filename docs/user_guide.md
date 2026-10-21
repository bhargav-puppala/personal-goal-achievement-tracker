# User Guide — Personal Goal Achievement Tracker

**Student Roll Number:** `24PA1A05I4`  
**Application Version:** `1.0.0`  

---

## 1. Introduction

The **Personal Goal Achievement Tracker** helps students and professionals convert long-term academic, career, and personal goals into daily milestones. This guide provides step-by-step instructions on operating all application features.

---

## 2. Navigation Overview

The application features a bottom navigation bar with three primary screens:
1. **Home (Dashboard):** Live overview statistics, Daily Focus checklist, search, category filters, and active goal cards.
2. **Analytics:** Performance insights, 7-day milestone completion bar chart, category distribution, and accomplishment timeline.
3. **Settings & Profile:** Student roll number (`24PA1A05I4`), SDG 3 & 4 cards, theme switcher, demo data seeder, and JSON backup/restore.

---

## 3. Step-by-Step Feature Walkthrough

### 3.1 Creating a New Goal
1. On the **Home** tab, tap the **"New Goal"** floating action button at the bottom right.
2. Enter a **Goal Title** (e.g., *"Master Data Structures & Algorithms"*).
3. Optionally enter a **Description** detailing your strategy.
4. Select a **Category** chip (*Academic*, *Career*, *Fitness*, *Personal*, *Finance*, *Health and Well-being*, or *Other*).
5. Choose a **Priority** (*Low*, *Medium*, or *High*).
6. Tap the **Deadline** field to pick a target completion date.
7. Under **Initial Milestones**, enter actionable steps (e.g., *"Complete Binary Search exercises"*). Tap **"Add Milestone"** to add more rows.
8. Tap **"Save"** in the top app bar.

### 3.2 Managing Milestones on Goal Details
1. From the dashboard, tap any goal card to open its **Goal Details** screen.
2. Review the milestone progress bar and percentage.
3. Tap **"Add Milestone"** to dynamically append a new milestone.
4. Tap the three dots (`⋮`) on any milestone to **Edit Title** or **Delete**.
5. Tap the **Star icon** (`★`) on a milestone to pin it to **Today's Focus**.
6. Tap the checkbox next to any milestone to mark it completed or reopened. Parent goal progress updates automatically.

### 3.3 Prioritizing Actions with Daily Focus
1. Return to the **Home** dashboard and locate the **"Today's Focus"** card.
2. You will see all milestones you've starred for today.
3. Alternatively, tap **"Add Focus"** on the card to choose any pending milestone from your active goals.
4. Tap the checkbox directly on the dashboard to complete the milestone.
5. Your milestone completion count, progress bar, and active streak update immediately!

### 3.4 Reviewing Analytics & Habit Streaks
1. Tap the **Analytics** destination in the bottom navigation bar.
2. View your **Current Streak** and best historical streak.
3. Inspect the **Weekly Milestone Activity** bar chart showing completions over the past 7 calendar days.
4. Review the **Category Distribution** visualizer to ensure balance across academic and wellness goals.
5. Scroll through **Recent Achievements** to see chronological completion timestamps.

### 3.5 Loading Demonstration Data
For academic faculty and lab evaluators, the app includes realistic demo data:
1. Tap the **Settings** tab.
2. Scroll to **Data Management** and tap **"Load Demo"**.
3. The app instantly seeds goals aligned with SDG 4 (DSA Mastery, Placement Prep) and SDG 3 (10,000 steps, Hydration habit), complete with simulated activity history and streaks!

### 3.6 Backing Up and Restoring Data
1. On the **Settings** tab, tap **"Export JSON Backup"**.
2. Tap **"Copy to Clipboard"** to save your backup text.
3. To restore or migrate data, tap **"Import JSON Backup"**, paste the JSON string, and tap **"Import"**.

### 3.7 Switching Themes (Light / Dark Mode)
1. On the **Settings** tab under **Appearance**, tap **Light**, **Dark**, or **System**.
2. The entire application transitions smoothly with tailored contrast surfaces.

### 3.8 Deadline Alerts and Reminder Settings
The app displays deadline status and alerts in its interface. Settings also stores a reminder toggle and preferred time, but these preferences do not schedule background or operating-system notifications. `NotificationService` currently records scheduling/cancellation requests in debug output only.
