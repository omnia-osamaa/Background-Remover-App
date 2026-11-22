# Background Remover App

A Flutter mobile app that removes the background from photos. The user picks a photo, the app removes the background, and the user downloads, shares, or edits the result.

Built as part of the Techwave Developers intern task.

## Screens

| Flow | Screens |
|------|---------|
| Start | Splash, Onboarding (3 pages), Login, Sign Up, Forgot Password |
| Main (bottom nav) | Home, My Files (history), Plans, Profile & Settings |
| Remove flow | Upload / Pick photo, Processing, Result (before/after), Editor |
| Billing | Packages (Free / Pro / Premium), Payment / Upgrade |
| States | Logout confirmation, no internet, processing failed, no images yet, daily limit reached |

## Tech Stack

- Flutter / Dart, Clean Architecture
- State management: BLoC / Cubit
- Networking: Dio, DI: GetIt, Functional errors: Dartz
- Navigation: go_router (StatefulShellRoute for the bottom navigation)
- Storage: shared_preferences, path_provider
- Images: image_picker, gal (save to gallery), share_plus

## Project Structure

```
lib/
├── core/            constants, di, error, network, router, services, theme, usecases, utils, widgets
├── features/
│   ├── splash/ onboarding/ auth/ home/
│   ├── background_removal/   (upload, processing, result)
│   ├── editor/ history/ packages/ profile/
│   └── <feature>/ data/ (datasources, models, repositories)
│                  domain/ (entities, repositories, usecases)
│                  presentation/ (cubit, pages, widgets)
├── app.dart
└── main.dart
```

## Getting Started

```bash
flutter create . --project-name bg_remover --org com.omnia   # first time only
flutter pub get
flutter run
```

Requires Flutter 3.27+ (Dart 3.6+). See `SETUP.md` for the Android / iOS permissions.

## Background removal

By default the app uses a **fake** data source: it only simulates the processing time and returns a copy of the original photo (the background is not really removed).

To use real background removal with the [remove.bg](https://www.remove.bg/api) API:

```bash
flutter run --dart-define=REMOVE_BG_API_KEY=your_key
```

## Plans (demo)

| Plan | Price | Limit | Notes |
|------|-------|-------|-------|
| Free | $0 | 3 images / day | Standard quality |
| Pro (best value) | $4.99 / month | 50 images / day | HD, no watermark |
| Premium | $9.99 / month | Unlimited | Ultra HD, priority |

Yearly billing = 10 months for the price of 12. Only the daily limit is enforced in code; quality and watermark are display-only. Payment is a demo checkout (no real charge).

## Testing tips

- Sign up with `taken@example.com` to see the error state.
- Process more images than your daily limit to see the "limit reached" state.
- Turn off the internet before processing to see the "no internet" state.

## Author

Omnia Osama
