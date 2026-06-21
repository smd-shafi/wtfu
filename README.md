# WTFU (Wake The Fuck Up) Alarm Clock App

WTFU is a production-ready, high-fidelity Alarm Clock App built with Flutter. It utilizes `flutter_bloc` for state management, `get_it` for dependency injection, and follows clean architecture rules.

## Tech Stack

*   **Core**: Flutter & Dart (Null-Safe)
*   **State Management**: `flutter_bloc` (v9.1+)
*   **Dependency Injection**: `get_it` (v9.2+)
*   **Scheduler**: `alarm` (v5.5+)
*   **Persistence**: SharedPreferences (JSON serialized mappings)
*   **Aesthetics**: Glassmorphism dark mode accents, pulsing HSL animations, and hold-to-confirm dismiss controls.

---

## Clean Architecture Folder Structure

```
lib/
├── core/
│   ├── logger/
│   │   └── app_logger.dart
│   └── theme/
│       └── app_theme.dart
├── dependency_injection/
│   └── injection.dart
├── features/
│   └── alarm/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── alarm_datasource.dart
│       │   ├── models/
│       │   │   ├── alarm_history_model.dart
│       │   │   └── alarm_model.dart
│       │   └── repos/
│       │       └── alarm_repo_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── alarm_entity.dart
│       │   └── repos/
│       │       └── alarm_repo.dart
│       ├── presentation/
│       │   ├── bloc/
│       │   │   ├── alarm_bloc.dart
│       │   │   ├── alarm_event.dart
│       │   │   └── alarm_state.dart
│       │   ├── screens/
│       │   │   ├── full_screen_alarm_screen.dart
│       │   │   ├── home_screen.dart
│       │   │   └── settings_screen.dart
│       │   └── widgets/
│       │       ├── add_edit_alarm_bottom_sheet.dart
│       │       ├── alarm_history_widget.dart
│       │       ├── alarm_item_widget.dart
│       │       └── long_press_button.dart
│       └── services/
│           ├── alarm_scheduler_service.dart
│           ├── full_screen_alarm_service.dart
│           ├── local_storage_service.dart
│           └── notification_service.dart
├── routes/
│   └── app_routes.dart
└── main.dart
```

---

## Core Features

1.  **Alarm Scheduler**: Create, edit, and delete one-time, daily, weekend, weekday, or custom repeating schedules. Calculates next occurrence automatically.
2.  **Sound Previews**: Select between three synthesized WAV sounds (Classic Beep, Digital Alert, Gentle Pulsing) and play real-time previews inside the set-up sheets.
3.  **Vibration Controls**: Toggle ongoing device vibration patterns for active alerts.
4.  **Activity Logs**: Automatic tracking and storage of triggered/stopped alarm history.
5.  **Hold to Stop**: Renders a large animated ringing bell and requires holding the button for 1.5 seconds to stop, preventing accidental dismissal.
6.  **Persistence & Autostart**: Alarms are saved in local preferences, and automatically rescheduled on system boot.

---

## Installation & Setup Instructions

### 1. Pre-requisites
*   Flutter SDK (v3.12.0+)
*   Android SDK / Xcode

### 2. Synthesize Default Sounds
Ringtone WAV assets are synthesized locally without network dependencies. To regenerate the audio sounds:
```bash
python3 .gemini/antigravity-ide/brain/4ad03cfd-aa15-4bff-aa2d-828639e26829/scratch/synthesize_sounds.py
```
This writes the following files:
*   `assets/sounds/alarm_beep.wav`
*   `assets/sounds/alarm_digital.wav`
*   `assets/sounds/alarm_gentle.wav`

### 3. Run Dependencies Resolution
```bash
flutter pub get
```

### 4. Running the App
Start a local development runner or build the production bundle:
```bash
flutter run
```

---

## Verification & Testing

To run the unit test suite covering next alarm calculation scenarios and JSON model parsing:
```bash
flutter test
```
