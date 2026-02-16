import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../models/completion_model.dart';
import '../services/habit_service.dart';
import '../services/streak_service.dart';
import '../services/achievement_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();
  final StreakService _streakService = StreakService();
  final AchievementService _achievementService = AchievementService();

  List<HabitModel> _habits = [];
  List<HabitModel> _activeHabits = [];
  List<CompletionModel> _todayCompletions = [];
  bool _isLoading = false;
  String? _error;
  bool _allCompletedToday = false;

  List<HabitModel> get habits => _habits;
  List<HabitModel> get activeHabits => _activeHabits;
  List<CompletionModel> get todayCompletions => _todayCompletions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get allCompletedToday => _allCompletedToday;

  int get totalActiveHabits => _activeHabits.length;
  int get completedTodayCount => _todayCompletions.length;

  /// Initialize habit data for a user
  void initHabits(String userId) {
    _habitService.getUserHabits(userId).listen((habits) {
      _habits = habits;
      notifyListeners();
    });

    _habitService.getActiveHabits(userId).listen((habits) {
      _activeHabits = habits;
      _checkAllCompleted();
      notifyListeners();
    });

    loadTodayCompletions(userId);
  }

  /// Load today's completions
  Future<void> loadTodayCompletions(String userId) async {
    _todayCompletions = await _habitService.getTodayCompletions(userId);
    _checkAllCompleted();
    notifyListeners();
  }

  /// Create a new habit
  Future<bool> createHabit({
    required String userId,
    required String habitName,
    String? description,
    String? icon,
    required int durationDays,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _habitService.createHabit(
        userId: userId,
        habitName: habitName,
        description: description,
        icon: icon,
        durationDays: durationDays,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Complete a habit for today
  Future<bool> completeHabit({
    required String userId,
    required String habitId,
  }) async {
    try {
      await _habitService.completeHabitForToday(
        userId: userId,
        habitId: habitId,
      );

      await loadTodayCompletions(userId);

      // Check if all habits are now completed
      _checkAllCompleted();

      if (_allCompletedToday) {
        // Evaluate streak
        final streakIncremented = await _streakService.evaluateDailyStreak(
          userId: userId,
          allTasksCompleted: true,
        );

        if (streakIncremented) {
          // Check for streak achievements
          final stats = await _streakService.getStreakStats(userId);
          await _achievementService.checkStreakAchievements(
            userId: userId,
            currentStreak: stats['currentStreak'],
          );
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId, String userId) async {
    await _habitService.deleteHabit(habitId, userId);
    notifyListeners();
  }

  /// Check if a specific habit is completed today
  bool isHabitCompletedToday(String habitId) {
    return _todayCompletions.any((c) => c.habitId == habitId && c.isCompleted);
  }

  void _checkAllCompleted() {
    if (_activeHabits.isEmpty) {
      _allCompletedToday = false;
      return;
    }

    _allCompletedToday = _activeHabits.every(
      (habit) => isHabitCompletedToday(habit.id),
    );
  }

  /// Get completion data for analytics
  Future<List<CompletionModel>> getCompletionsInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _habitService.getCompletionsInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
