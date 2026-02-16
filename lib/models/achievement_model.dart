import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementModel {
  final String id;
  final String userId;
  final String badgeType;
  final String title;
  final String description;
  final String icon;
  final DateTime dateEarned;

  AchievementModel({
    required this.id,
    required this.userId,
    required this.badgeType,
    required this.title,
    required this.description,
    this.icon = '🏆',
    required this.dateEarned,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map, String id) {
    return AchievementModel(
      id: id,
      userId: map['userId'] ?? '',
      badgeType: map['badgeType'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏆',
      dateEarned: map['dateEarned'] != null
          ? (map['dateEarned'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'badgeType': badgeType,
      'title': title,
      'description': description,
      'icon': icon,
      'dateEarned': Timestamp.fromDate(dateEarned),
    };
  }

  static AchievementModel createBadge({
    required String userId,
    required String badgeType,
  }) {
    final badgeInfo = _badgeDefinitions[badgeType]!;
    return AchievementModel(
      id: '',
      userId: userId,
      badgeType: badgeType,
      title: badgeInfo['title']!,
      description: badgeInfo['description']!,
      icon: badgeInfo['icon']!,
      dateEarned: DateTime.now(),
    );
  }

  static final Map<String, Map<String, String>> _badgeDefinitions = {
    '7_day_streak': {
      'title': 'Week Warrior',
      'description': 'Maintain a 7-day streak',
      'icon': '⚡',
    },
    '30_day_discipline': {
      'title': 'Monthly Master',
      'description': 'Maintain a 30-day streak',
      'icon': '🔥',
    },
    '100_day_legend': {
      'title': 'Century Legend',
      'description': 'Maintain a 100-day streak',
      'icon': '👑',
    },
    'habit_completed': {
      'title': 'Habit Finisher',
      'description': 'Complete a full habit duration',
      'icon': '🎯',
    },
    'first_friend': {
      'title': 'Social Starter',
      'description': 'Add your first friend',
      'icon': '🤝',
    },
    '7_day_friendship': {
      'title': 'Accountability Partners',
      'description': '7-day friendship streak',
      'icon': '💪',
    },
  };

  static Map<String, Map<String, String>> get badgeDefinitions =>
      _badgeDefinitions;
}
