# Habit Tracker

![Version](https://img.shields.io/badge/version-2.0.1-blue.svg)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B.svg)

A powerful, production-ready Habit Tracker application designed to help users build and maintain positive habits. This app features a modern UI, robust data tracking, and insightful analytics.

## Features

- **Habit Management**: Create, edit, and delete habits with custom schedules (daily, weekly, specific days).
- **Daily Tracking**: Mark habits as complete or skip them for the day.
- **Notes & Reflections**: Attach notes to your habits to track your thoughts and progress.
- **Analytics & Statistics**: Visualize your progress with charts, heatmaps, and consistency scores.
- **Reminders**: Set local notifications to never miss a habit.
- **Dark/Light Mode**: Fully adaptive theme support.
- **Secure Auth**: User authentication powered by Firebase.
- **Real-time Sync**: Data stored safely in Cloud Firestore.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Flutter Riverpod
- **Backend & Auth**: Firebase (Auth, Firestore)
- **Local Notifications**: `flutter_local_notifications`
- **Charts**: `fl_chart`

## Getting Started

### Prerequisites

- Flutter SDK (3.x.x)
- Android Studio / Xcode
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/anaslari23/habit-tracker.git
   cd habit_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Place your `google-services.json` in `android/app/`.
   - Place your `GoogleService-Info.plist` in `ios/Runner/`.

4. **Run the app**
   ```bash
   flutter run
   ```

## Production Build

To generate the release APK:

```bash
flutter build apk --release
```

The output will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## Version 2.0.1 Release Notes

- **New Icons**: Updated app launcher icons for a fresh look.
- **Enhanced UI**: Polished screens and animations.
- **Bug Fixes**: Stability improvements and performance optimizations.
