# Daily Tracker

A Flutter-based habit tracker and daily task management app with Firebase backend. Keep track of your daily tasks, build consistent habits, and monitor your progress over time.

## Features

- ✅ Track daily tasks and habits
- 📆 Calendar view for monitoring completion patterns
- 🌙 Dark and light mode support
- 🔐 User authentication (email/password and anonymous)
- 💾 Cloud sync with Firebase
- 📱 Cross-platform (Android, iOS)
- 🗓️ Future task scheduling

## Screenshots

<table>
  <tr>
    <td><img src="https://i.imgur.com/iSFvlio.png" alt="Login Screen"></td>
    <td><img src="https://i.imgur.com/ctvfwpC.png" alt="Tasks Screen"></td>
    <td><img src="https://i.imgur.com/qfFWlFK.png" alt="Calendar View"></td>
  </tr>
</table>

## Getting Started

### Prerequisites

- Flutter (2.10.0 or higher)
- Dart (2.16.0 or higher)
- Firebase account
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/daily-tracker.git
cd daily-tracker
```

2. Install dependencies:

```bash
flutter pub get
```

3. Follow the Firebase setup instructions below.

4. Run the app:

```bash
flutter run
```

## Firebase Setup

This app requires Firebase for backend services including authentication and data storage. Follow these steps to set up Firebase for your own deployment:

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)

2. Enable the following Firebase services in your project:

   - Firebase Authentication (Email/Password and Anonymous)
   - Cloud Firestore

3. Add apps for each platform you want to support:

   - Android (use package name `com.example.dailies` or update it in the code)
   - iOS (if needed)
   - Web (if needed)

4. Install the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

5. Run the FlutterFire configuration command in your project directory:

```bash
flutterfire configure --project=your-firebase-project-id
```

6. This will generate the necessary `firebase_options.dart` file needed to run the app.

7. Set up Firestore security rules. Here's a basic template to start with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Only allow access to the user's own document
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Tasks subcollection rules
      match /tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
