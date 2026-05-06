# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run on a specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Build Android APK (debug)
flutter build apk --debug

# Build Android APK (release)
flutter build apk --release

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code (lint)
flutter analyze

# Format code
dart format lib/
```

## Architecture

The entire application lives in a single file: `lib/main.dart`. There are no separate files, feature folders, or route definitions.

### State Management

`AppState` (extends `ChangeNotifier`) is the single source of truth, passed explicitly as a constructor argument to every screen. There is no `Provider` widget in the tree — widgets rebuild by wrapping themselves in `AnimatedBuilder(animation: appState, ...)`. `AppState` is instantiated once in `_RescueBoatAppState` and flows down manually.

### Firebase Backend

Three Firestore collections:
- **`users`** — documents keyed by CIN, loaded once at startup into `AppState.users`
- **`alertes`** — drowning alerts ordered by `heure` desc, real-time via `StreamSubscription`
- **`historique`** — victim case records ordered by `date` desc, real-time via `StreamSubscription`

Firebase is initialized in `main()` before `runApp`. `google-services.json` (Android) is present but not committed to git.

### User Roles & Auth

Authentication is CIN + a single shared hardcoded password (`motDePasseGeneral`). The three roles control UI access:
- `adminPrincipal` — sees all admin features including secondary admin management
- `adminSecondaire` — sees admin tab, manages their own assigned members (`adminCin` field)
- `maitreDuNauge` — no admin tab, read-only access to alerts and history

Role is stored as a string enum name in Firestore and parsed via `UserRole.values.firstWhere`.

### Screen Flow

`RescueBoatApp` renders one of three states based on `AppState`:
1. `_SplashScreen` — while `isLoading` is true
2. `LoginScreen` — when `currentUser` is null
3. `HomeScreen` — bottom nav shell with `DashboardPage`, `AlertesPage`, `HistoriquePage`, and optionally `AdminPage`

### Alert Lifecycle

Alerts have two boolean flags: `confirmee` (acknowledged by staff) → `traitee` (mission complete). The UI drives Firestore updates via `AppState.confirmerAlerte` and `AppState.traiterAlerte`.

### UI Conventions

- Color palette is defined in `AppColors` (dark ocean theme: navy/teal/red/green)
- Reusable private widgets are prefixed with `_` (e.g., `_InputField`, `_AlerteCard`, `_StatCard`)
- `WavePainter` is a `CustomPainter` used as animated background decoration on the login screen
- The `_BoatStatusCard` and `_GpsCard` on the dashboard display hardcoded/static data (not yet connected to a real device)

## Firebase Setup

The app requires a Firebase project with Firestore enabled. For Android, `android/app/google-services.json` must be present (it is gitignored). The Android app ID is `com.example.bateau_sauveur`.

Dependencies include `firebase_messaging` but push notification initialization is not yet wired up in `main.dart`.
