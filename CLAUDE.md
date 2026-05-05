# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**GameForge** — A Flutter mobile app serving as a task command center for a 4-person game development team. The UI uses a dark, cyberpunk/military aesthetic with neon accents (cyan, purple, pink, gold). The app is in Turkish.

## Commands

```bash
# Run the app
flutter run

# Build Android release APK
flutter build apk --release

# Build Android release (split by ABI, smaller size)
flutter build apk --split-per-abi --release

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Clean build cache
flutter clean && flutter pub get
```

## Architecture

**State management:** Provider pattern (`ChangeNotifier`).

- `AuthProvider` — handles login state. Credentials are hardcoded: `admin` / `atss19`. Injected at the root `MultiProvider` in `main.dart`.
- `TaskProvider` — injected at login time via `ChangeNotifierProvider` in `LoginScreen`, wrapping `HomeScreen`. All task data lives in memory (no persistence); `AppData.sampleTasks` in `task_model.dart` is the initial seed data.

**Navigation:** `HomeScreen` uses a `PageView` with a custom `BottomAppBar` (circular notch FAB in center). The 4 tabs are: Dashboard → Departments → Tasks → Project Info. Tab switching uses `PageController.animateToPage`.

**Screen flow:**
```
SplashScreen → LoginScreen → HomeScreen (PageView)
                                ├── DashboardScreen
                                ├── DepartmentsScreen
                                ├── TasksScreen
                                └── ProjectInfoScreen
```
`AddTaskScreen` is pushed modally from the FAB in `HomeScreen`.

**Data model (`task_model.dart`):**
- `TaskModel` — core entity with `id`, `title`, `department`, `status`, `priority`, `assignee`, `dueDate`, `tags`, `progress` (0–100), `createdAt`.
- `Department` enum: `dev`, `art`, `design`, `audio`, `qa`, `pm`
- `TaskStatus` enum: `todo`, `inProgress`, `review`, `done`
- `Priority` enum: `low`, `medium`, `high`, `critical`
- `AppData.departments` — static map from `Department` → `DepartmentInfo` (name, emoji, color, description, icon)
- Extensions `TaskStatusExtension` and `PriorityExtension` provide `.label` (Turkish) and `.color` from `AppTheme`.

## Theme System (`lib/theme/app_theme.dart`)

All colors are defined as `static const` on `AppTheme`. Always use these constants — never hardcode colors.

| Constant | Usage |
|---|---|
| `bgDeep` | Scaffold background (`#09090F`) |
| `bgCard` | Card/surface background |
| `bgElevated` | Elevated surfaces, input fills |
| `accentCyan` | Primary accent, active state |
| `accentPurple` | Secondary accent |
| `accentPink` | Errors, critical indicators |
| `accentGold` | Review/warning state |
| `accentGreen` | Done/success state |
| `textSecondary` | Muted labels |
| `borderGlow` | Subtle border color |

Typography uses **Orbitron** (headings, numbers, UI labels — all-caps with `letterSpacing`) and **Rajdhani** (body text, secondary labels) via `google_fonts`.

`GlowingCard` (`lib/widgets/glowing_card.dart`) is the standard container for highlighted content — accepts a `glowColor` parameter.

## Key Conventions

- All UI text is Turkish (uppercase for labels, normal case for descriptions).
- Department colors come from `AppData.departments[dept]!.color`, not hardcoded.
- `overallProgress` in `TaskProvider` is the arithmetic mean of all task `progress` values (0–100), not a completion count ratio.
- When `progress == 100`, status auto-sets to `done`; when status is set to `done`, progress auto-sets to `100`.
