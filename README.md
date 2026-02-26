# Tummy_boy

Android-first Flutter (Dart) fitness app to track daily reps, measure running distance with GPS, generate weekly/monthly graph summaries, and recommend exercises using ML based on user profile data.

## Dart/Flutter File Structure

```text
Tummy_boy/
├─ pubspec.yaml
├─ analysis_options.yaml
├─ lib/
│  ├─ main.dart
│  ├─ app.dart
│  ├─ routes/
│  │  └─ app_router.dart
│  ├─ core/
│  │  ├─ constants/
│  │  │  └─ app_strings.dart
│  │  ├─ services/
│  │  │  ├─ location_service.dart
│  │  │  └─ ml_recommendation_service.dart
│  │  └─ theme/
│  │     └─ app_theme.dart
│  ├─ features/
│  │  ├─ home/presentation/pages/home_page.dart
│  │  ├─ workout/
│  │  │  ├─ data/models/workout_entry.dart
│  │  │  └─ presentation/pages/workout_page.dart
│  │  ├─ run/
│  │  │  ├─ data/models/run_session.dart
│  │  │  └─ presentation/pages/run_page.dart
│  │  ├─ reports/
│  │  │  ├─ data/models/progress_summary.dart
│  │  │  └─ presentation/pages/reports_page.dart
│  │  ├─ profile/
│  │  │  ├─ data/models/user_profile.dart
│  │  │  └─ presentation/pages/profile_page.dart
│  │  └─ recommendation/presentation/pages/recommendation_page.dart
│  └─ shared/
│     └─ widgets/app_scaffold.dart
└─ app/ (existing Android-native scaffold from earlier)
```

## Purpose of Each File (One by One)

- `pubspec.yaml`: Defines Flutter project metadata and dependencies (GPS, charts, local storage, ML runtime).
- `analysis_options.yaml`: Enables Dart lint rules for consistent code quality.

- `lib/main.dart`: App entrypoint; boots Flutter and runs `TummyBoyApp`.
- `lib/app.dart`: Main app widget (`MaterialApp`) with theme and route registration.
- `lib/routes/app_router.dart`: Central route names and screen-to-route mapping.

- `lib/core/constants/app_strings.dart`: App-wide text constants to avoid hard-coded strings.
- `lib/core/theme/app_theme.dart`: Global Material 3 theme setup.
- `lib/core/services/location_service.dart`: GPS/location business service placeholder.
- `lib/core/services/ml_recommendation_service.dart`: ML recommendation service placeholder.

- `lib/features/home/presentation/pages/home_page.dart`: Home dashboard screen.

- `lib/features/workout/data/models/workout_entry.dart`: Data model for exercise rep logs.
- `lib/features/workout/presentation/pages/workout_page.dart`: UI for workout logging screen.

- `lib/features/run/data/models/run_session.dart`: Data model for a run session (distance/time/start).
- `lib/features/run/presentation/pages/run_page.dart`: UI for GPS run tracking screen.

- `lib/features/reports/data/models/progress_summary.dart`: Data model for weekly/monthly summaries.
- `lib/features/reports/presentation/pages/reports_page.dart`: UI for analytics/report charts screen.

- `lib/features/profile/data/models/user_profile.dart`: User profile model (age/height/weight/illness).
- `lib/features/profile/presentation/pages/profile_page.dart`: UI for profile input and editing.

- `lib/features/recommendation/presentation/pages/recommendation_page.dart`: UI for ML-based exercise recommendations.

- `lib/shared/widgets/app_scaffold.dart`: Reusable scaffold shell with common app bar/body layout.

## Next Step

Run Flutter project setup locally:

```bash
flutter create .
flutter pub get
flutter run
```
