import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Evaluate the daily streak.
  /// Call this after checking if all today's tasks are completed.
  /// Returns true if streak was incremented, false if reset.
  Future<bool> evaluateDailyStreak({
    required String userId,
    required bool allTasksCompleted,
  }) async {
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (!userDoc.exists) return false;

    final user = UserModel.fromMap(userDoc.data()!, userId);

    if (allTasksCompleted) {
      // Increment streak
      final newStreak = user.currentStreak + 1;
      final newMax =
          newStreak > user.maxStreak ? newStreak : user.maxStreak;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'currentStreak': newStreak,
        'maxStreak': newMax,
        'totalCompletedDays': FieldValue.increment(1),
      });

      return true;
    } else {
      // Check if user has streak freeze
      if (user.streakFreezeCount > 0) {
        // Use a freeze instead of resetting
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update({
          'streakFreezeCount': FieldValue.increment(-1),
        });
        return true; // Streak preserved
      }

      // Reset streak
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'currentStreak': 0,
      });

      return false;
    }
  }

  /// Check if all active habits are completed for today
  Future<bool> areAllHabitsCompletedToday(String userId) async {
    // Get active habits
    final habitsSnapshot = await _firestore
        .collection(AppConstants.habitsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    if (habitsSnapshot.docs.isEmpty) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get today's completions
    final completionsSnapshot = await _firestore
        .collection(AppConstants.completionsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .where('status', isEqualTo: 'completed')
        .get();

    final completedHabitIds =
        completionsSnapshot.docs.map((doc) => doc.data()['habitId']).toSet();

    // Check if every active habit is completed
    for (final habitDoc in habitsSnapshot.docs) {
      if (!completedHabitIds.contains(habitDoc.id)) {
        return false;
      }
    }

    return true;
  }

  /// Add streak freeze to user
  Future<void> addStreakFreeze(String userId, {int count = 1}) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'streakFreezeCount': FieldValue.increment(count),
    });
  }

  /// Get streak statistics
  Future<Map<String, dynamic>> getStreakStats(String userId) async {
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      return {
        'currentStreak': 0,
        'maxStreak': 0,
        'totalCompletedDays': 0,
        'streakFreezeCount': 0,
      };
    }

    final data = userDoc.data()!;
    return {
      'currentStreak': data['currentStreak'] ?? 0,
      'maxStreak': data['maxStreak'] ?? 0,
      'totalCompletedDays': data['totalCompletedDays'] ?? 0,
      'streakFreezeCount': data['streakFreezeCount'] ?? 0,
    };
  }
}
