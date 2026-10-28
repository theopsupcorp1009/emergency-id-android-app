# 🚑 QMedID (Emergency ID)

A **Flutter** Android app that turns your phone's lock screen into an emergency medical ID. Store your key health details and emergency contacts once, and QMedID keeps them visible in a persistent notification, so first responders or bystanders can see who you are and who to call, even when the phone is locked.

> 📦 **Repository:**(https://github.com/theopsupcorp1009/emergency-id-android-app)

---

## ✨ Features

- **Emergency ID card** showing profile photo, name, age, gender, blood group, and medical conditions
- **Medical details** covering diabetes, blood pressure (Low, Normal, High), asthma with inhaler information, and allergies
- **Allergy picker** with common options (Penicillin, Sulfa drugs, Aspirin, NSAIDs, Latex, Peanuts, Tree nuts, Shellfish, Eggs, Milk, Dust) plus a free-text "Other" field
- **Emergency contacts** with name, phone number, and relation, each with a one-tap **CALL** button
- **Lock-screen notification** that stays on screen (ongoing, public visibility, maximum importance) and expands to show the full medical summary
- **Call buttons in the notification** for up to three contacts, so help can be reached without unlocking the app
- **Notification visibility settings** to choose what appears on the lock screen: age, blood group, diabetes, asthma, blood pressure, allergies, and call buttons
- **Periodic reminders** (every 15, 20, 30, 40, 50, or 60 minutes, or off) that refresh the emergency notification in the background using WorkManager
- **Form validation** that requires all medical fields and at least one complete emergency contact before saving
- **Dark mode** toggle
- Animated **heartbeat splash screen**
- **Fully offline**: everything is stored locally on the device

---

## 🖥️ Tech Stack

| Layer                | Technology                                              |
|----------------------|----------------------------------------------------------|
| Framework            | [Flutter](https://flutter.dev/) (Dart SDK ^3.12.2)       |
| Platform             | Android (Kotlin host, Java 17, core library desugaring)  |
| Local Storage        | `shared_preferences`                                     |
| Notifications        | `flutter_local_notifications`                            |
| Background Tasks     | `workmanager`                                            |
| Calling              | `url_launcher`                                           |
| Profile Photo        | `image_picker`                                           |
| Runtime Permissions  | `permission_handler`                                     |
| App Icon             | `flutter_launcher_icons`                                 |

---

## 📂 Project Structure

```
emergency_id/
├── lib/
│   ├── main.dart                  # App entry, splash, emergency screen,
│   │                              # edit profile, and settings screens
│   ├── notification_service.dart  # Lock-screen notification builder and call actions
│   └── reminder_service.dart      # WorkManager periodic reminder scheduling
├── assets/
│   └── icon.png                   # App icon source
├── android/                       # Android host project and manifest
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🔐 Permissions

| Permission                | Why it is needed                                        |
|---------------------------|----------------------------------------------------------|
| `POST_NOTIFICATIONS`      | Show the emergency card on the lock screen (Android 13+) |
| `CALL_PHONE`              | Call emergency contacts directly                         |
| `SCHEDULE_EXACT_ALARM`    | Reliable scheduling on Android 12+                       |
| `WAKE_LOCK`, `FOREGROUND_SERVICE` | Background reminder work                         |
| `RECEIVE_BOOT_COMPLETED`  | Reschedule reminders after the device restarts           |
| `INTERNET`                | Used by Flutter tooling, the app itself works offline    |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.12.2 or newer)
- Android Studio or VS Code with the Flutter extension
- JDK 17
- An Android device or emulator

### Installation

```bash
# Clone the repository
git clone <your-repository-url>
cd emergency_id

# Install dependencies
flutter pub get
```

### Run the app

```bash
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

> The release build currently uses the debug signing config. Create your own keystore and update `android/app/build.gradle.kts` before publishing to the Play Store.

### Regenerate launcher icons

```bash
dart run flutter_launcher_icons
```

---

## 🎛️ How to Use

1. Open the app and allow **notifications** when prompted.
2. Tap **Edit** and fill in your name, age, gender, blood group, medical conditions, and allergies. Add a profile photo if you like.
3. Add at least one **emergency contact** with a phone number and relation.
4. Save. The **emergency notification** now appears on your lock screen.
5. Open **Settings** to choose which details appear in the notification, enable call buttons, set the reminder interval, or switch to dark mode.
6. In an emergency, anyone can read your details from the lock screen and tap a contact's call button.

---

## 🔒 Privacy

All profile data stays on your device in local storage. Nothing is uploaded or shared with any server. Keep in mind that details shown in the lock-screen notification are visible to anyone holding your phone, so use the visibility toggles in Settings to show only what you are comfortable sharing.

---

## ⚠️ Notes

- Some phone manufacturers aggressively limit background work. If reminders stop, exclude the app from battery optimization in system settings.
- Lock-screen notification visibility also depends on your device's notification settings. Make sure sensitive notification content is allowed on the lock screen.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is open source. Add your preferred license (e.g., MIT) here.

---

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Notifications by [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- Background scheduling by [workmanager](https://pub.dev/packages/workmanager)

---

## 📝 Project Summary

**QMedID (Emergency ID)** is an offline Android app that makes critical medical information available when it matters most. Built with Flutter and Dart, it lets users store their blood group, conditions, allergies, and emergency contacts, then surfaces them in a persistent, expandable lock-screen notification with optional one-tap call buttons. Users control exactly which details are visible, and a WorkManager-based reminder keeps the card refreshed in the background. All data is saved locally with shared preferences, so the app works without internet and keeps personal health data on the device. The project demonstrates practical experience with Flutter state management, local persistence, Android notifications and permissions, background task scheduling, form validation, and theming with light and dark modes.
