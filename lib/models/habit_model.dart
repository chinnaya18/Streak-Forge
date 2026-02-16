import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitStatus { active, completed, paused }

class HabitModel {
  final String id;
  final String userId;
  final String habitName;
  final String? description;
  final String? icon;
  final DateTime startDate;
  final int durationDays;
  final DateTime endDate;
  final HabitStatus status;
  final int completedDays;
  final DateTime? lastCompletedDate;

  HabitModel({
    required this.id,
    required this.userId,
    required this.habitName,
    this.description,
    this.icon,
    required this.startDate,
    required this.durationDays,
    required this.endDate,
    this.status = HabitStatus.active,
    this.completedDays = 0,
    this.lastCompletedDate,
  });

  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      userId: map['userId'] ?? '',
      habitName: map['habitName'] ?? '',
      description: map['description'],
      icon: map['icon'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      durationDays: map['durationDays'] ?? 30,
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: HabitStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => HabitStatus.active,
      ),
      completedDays: map['completedDays'] ?? 0,
      lastCompletedDate: map['lastCompletedDate'] != null
          ? (map['lastCompletedDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'habitName': habitName,
      'description': description,
      'icon': icon,
      'startDate': Timestamp.fromDate(startDate),
      'durationDays': durationDays,
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'completedDays': completedDays,
      'lastCompletedDate': lastCompletedDate != null
          ? Timestamp.fromDate(lastCompletedDate!)
          : null,
    };
  }

  HabitModel copyWith({
    String? habitName,
    String? description,
    String? icon,
    HabitStatus? status,
    int? completedDays,
    DateTime? lastCompletedDate,
  }) {
    return HabitModel(
      id: id,
      userId: userId,
      habitName: habitName ?? this.habitName,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      startDate: startDate,
      durationDays: durationDays,
      endDate: endDate,
      status: status ?? this.status,
      completedDays: completedDays ?? this.completedDays,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  double get progressPercentage => completedDays / durationDays;

  int get remainingDays {
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    return diff > 0 ? diff : 0;
  }

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
        lastCompletedDate!.month == now.month &&
        lastCompletedDate!.day == now.day;
  }

  bool get isDurationComplete => completedDays >= durationDays;
}
