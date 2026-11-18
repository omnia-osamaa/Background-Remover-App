# Background Remover App

A Flutter mobile app that removes the background from photos. The user picks a photo, the app removes the background, and the user downloads, shares, or edits the result.

Built as part of the Techwave Developers intern task.

## Features

- Splash and onboarding
- Sign up, login, forgot password (email/password and Google)
- Pick a photo from gallery or camera
- Background removal with a processing screen
- Before/after result view with download, share, and edit
- Simple editor: transparent, solid color, gradient, or photo background; crop and adjust
- History / My Files
- Packages: Free, Pro, Premium
- Profile, settings, light/dark theme, logout

## Tech Stack

- Flutter / Dart
- Clean Architecture
- State management: BLoC / Cubit
- Networking: Dio
- Dependency injection: GetIt
- Functional error handling: Dartz
- Navigation: go_router

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── error/
│   ├── network/
│   ├── router/
│   ├── theme/
│   └── usecases/
├── features/
│   └── <feature>/
│       ├── data/          (datasources, models, repositories)
│       ├── domain/        (entities, repositories, usecases)
│       └── presentation/  (cubit, pages, widgets)
├── app.dart
└── main.dart
```

Features: splash, onboarding, auth, home, background_removal, editor, history, packages, profile.

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.22+ (Dart 3.3+).

## Status

In progress. Core setup, theme, DI, and routing are done. Features are being built one by one.

## Author

Omnia Osama