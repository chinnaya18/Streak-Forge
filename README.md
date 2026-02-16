# 🔥 StreakForge

**Forge Your Discipline** — A cross-platform habit tracking application built with Flutter & Firebase.

StreakForge helps users build life-changing habits through streak tracking, gamified achievements, social accountability, and beautiful analytics.

---

## 📱 Target Platforms

- ✅ Android
- ✅ iOS

---

## 🛠️ Technology Stack

| Layer             | Technology                       |
| ----------------- | -------------------------------- |
| **Framework**     | Flutter 3.x                      |
| **Language**      | Dart                             |
| **State Mgmt**    | Provider                         |
| **Backend**       | Firebase (Auth, Firestore, FCM)  |
| **Charts**        | fl_chart                         |
| **Notifications** | flutter_local_notifications      |
| **Animations**    | confetti_widget, flutter_animate |
| **UI**            | Material 3 + Dark Mode           |

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   ├── constants.dart           # App constants & messages
│   ├── routes.dart              # Route definitions
│   └── theme.dart               # Light & Dark themes
├── models/
│   ├── user_model.dart          # User data model
│   ├── habit_model.dart         # Habit data model
│   ├── completion_model.dart    # Daily completion model
│   ├── friendship_model.dart    # Friendship data model
│   └── achievement_model.dart   # Achievement/badge model
├── services/
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── habit_service.dart       # Habit CRUD & completions
│   ├── streak_service.dart      # Streak evaluation logic
│   ├── friendship_service.dart  # Friend management
│   ├── achievement_service.dart # Badge & achievement logic
│   └── notification_service.dart# Local notifications
├── providers/
│   ├── auth_provider.dart       # Auth state management
│   ├── habit_provider.dart      # Habit state management
│   └── theme_provider.dart      # Theme state management
├── screens/
│   ├── splash/splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/home_screen.dart    # Bottom nav wrapper
│   ├── dashboard/dashboard_screen.dart
│   ├── habits/
│   │   ├── habit_list_screen.dart
│   │   ├── create_habit_screen.dart
│   │   └── habit_detail_screen.dart
│   ├── streak/streak_screen.dart
│   ├── analytics/analytics_screen.dart
│   ├── profile/profile_screen.dart
│   ├── friends/
│   │   ├── friends_screen.dart
│   │   └── add_friend_screen.dart
│   └── achievements/achievements_screen.dart
├── widgets/
│   └── common_widgets.dart      # Reusable UI components
assets/
├── images/
├── animations/
└── fonts/
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.1+ installed
- Firebase project created
- Android Studio / VS Code

### Setup Steps

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd Streak-Forge
   ```

2. **Install Flutter SDK** (if not already installed)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add to PATH
   - Run `flutter doctor` to verify

3. **Configure Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "StreakForge"
   - Add Android & iOS apps
   - Download `google-services.json` → place in `android/app/`
   - Download `GoogleService-Info.plist` → place in `ios/Runner/`
   - Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
   - Run: `flutterfire configure`

4. **Enable Firebase Services**
   - **Authentication** → Enable Email/Password sign-in
   - **Cloud Firestore** → Create database in production mode
   - **Deploy security rules** from `firestore.rules`
   - **Deploy indexes** from `firestore.indexes.json`

5. **Install dependencies**

   ```bash
   flutter pub get
   ```

6. **Add Fonts** (Optional — Google Fonts loads them dynamically)
   - Download Poppins from [Google Fonts](https://fonts.google.com/specimen/Poppins)
   - Place `.ttf` files in `assets/fonts/`

7. **Run the app**
   ```bash
   flutter run
   ```

---

## 🧠 Core Logic

### Streak System

- **All tasks completed** → Streak increments by 1
- **Any task missed** → Streak resets to 0 (unless streak freeze is used)
- **Streak freeze** → Protects your streak for 1 missed day
- **Birthday bonus** → Automatic streak freeze on your birthday

### Friendship Streaks

- Both friends complete all tasks → Friendship streak +1
- One friend misses → Friendship streak resets
- Reminder notifications sent to encourage completion

### Habit Lifecycle

1. Create habit with duration (30/60/90 days)
2. Complete daily task each day
3. Track progress through completion percentage
4. Earn badge when duration is completed
5. Option to renew habit for another cycle

---

## 🗄️ Database Schema (Firestore)

### Collections

| Collection     | Key Fields                                              |
| -------------- | ------------------------------------------------------- |
| `users`        | name, email, currentStreak, maxStreak, friendId, role   |
| `habits`       | userId, habitName, startDate, durationDays, status      |
| `completions`  | userId, habitId, date, status                           |
| `friendships`  | user1Id, user2Id, friendshipStreak, maxFriendshipStreak |
| `achievements` | userId, badgeType, title, dateEarned                    |

---

## 🏆 Achievement Badges

| Badge                  | Requirement                    | Icon |
| ---------------------- | ------------------------------ | ---- |
| Week Warrior           | 7-day streak                   | ⚡   |
| Monthly Master         | 30-day streak                  | 🔥   |
| Century Legend         | 100-day streak                 | 👑   |
| Habit Finisher         | Complete a full habit duration | 🎯   |
| Social Starter         | Add your first friend          | 🤝   |
| Accountability Partner | 7-day friendship streak        | 💪   |

---

## 🎨 UI Features

- **Material 3 Design** with custom color palette
- **Dark Mode** support with toggle
- **Confetti celebration** when all daily habits are completed
- **Animated progress indicators** for habits and streaks
- **Gradient cards** for streak and achievement displays
- **Birthday greeting** with bonus streak freeze

---

## 📋 Development Phases

### Phase 1 — MVP ✅

- [x] Authentication (Login/Register)
- [x] Habit tracking (Create/Complete/Delete)
- [x] Daily completion system
- [x] Streak system with freeze protection
- [x] Dashboard with progress overview

### Phase 2 — Core Features ✅

- [x] Analytics (Weekly/Monthly charts)
- [x] Achievements & Badges
- [x] Local Notifications
- [x] Dark Mode toggle

### Phase 3 — Advanced Features ✅

- [x] Friendship streaks & leaderboard
- [x] Friend ID system
- [x] Firestore security rules
- [x] Reusable widget library

### Phase 4 — Future Enhancements

- [ ] Admin panel (Web)
- [ ] Offline sync
- [ ] Home screen widgets
- [ ] Push notifications (FCM)
- [ ] Profile image upload
- [ ] Habit categories & tags
- [ ] Export data (CSV/PDF)

---

## 📄 License

This project is for educational purposes as part of PSG Semester 2 coursework.

---

**Built with ❤️ using Flutter & Firebase**
