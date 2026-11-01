# NTIZA

Flutter app for discovering and booking agricultural equipment. Firebase backend (added in Step 4).

## First run (Step 2 scaffold)

This folder holds `lib/`, `pubspec.yaml` and config only. Generate the native
Android/iOS folders once, then run:

```
cd ntiza_app
flutter create . --org com.ntiza --project-name ntiza --platforms=android,ios
flutter pub get
flutter analyze
flutter run
```

`flutter create .` may offer to overwrite `lib/main.dart` or `pubspec.yaml` — keep ours.
Fonts load through `google_fonts` at runtime and fall back to the system font offline.

## Structure

```
lib/core/    theme (tokens), router (go_router), shared widgets
lib/features/<screen>/   one folder per screen
```
