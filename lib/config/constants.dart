class AppConstants {
  // App Info
  static const String appName = 'StreakZen';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Forge Your Discipline';

  // Habit Durations
  static const List<int> habitDurations = [30, 60, 90];

  // Streak Thresholds
  static const int weekStreak = 7;
  static const int monthStreak = 30;
  static const int legendStreak = 100;

  // Achievement Badge Types
  static const String badge7Day = '7_day_streak';
  static const String badge30Day = '30_day_discipline';
  static const String badge100Day = '100_day_legend';
  static const String badgeHabitComplete = 'habit_completed';
  static const String badgeFirstFriend = 'first_friend';
  static const String badge7DayFriendship = '7_day_friendship';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String completionsCollection = 'completions';
  static const String friendshipsCollection = 'friendships';
  static const String achievementsCollection = 'achievements';
  static const String notificationsCollection = 'notifications';

  // Shared Preferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefReminderTime = 'reminder_time';

  // Notification Channels
  static const String dailyReminderChannel = 'daily_reminder';
  static const String streakAlertChannel = 'streak_alert';
  static const String friendAlertChannel = 'friend_alert';

  // Motivational Messages
  static const List<String> motivationalMessages = [
    'You\'re on fire! Keep the streak alive! 🔥',
    'Consistency is the key to mastery! 💪',
    'Another day, another victory! 🏆',
    'Discipline is the bridge between goals and accomplishment! 🌉',
    'Small steps lead to giant leaps! 🚀',
    'You\'re building something amazing! ⭐',
    'Champions are made one day at a time! 🥇',
    'Your future self will thank you! 🙏',
    'Every streak starts with a single day! 🌟',
    'Keep pushing — greatness awaits! 💎',
  ];

  // Birthday Messages
  static const String birthdayMessage = 'Happy Birthday! 🎂 Here\'s a free streak freeze as a gift!';
}
