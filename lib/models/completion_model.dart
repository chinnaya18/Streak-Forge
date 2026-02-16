import 'package:cloud_firestore/cloud_firestore.dart';

enum CompletionStatus { completed, missed }

class CompletionModel {
  final String id;
  final String userId;
  final String habitId;
  final DateTime date;
  final CompletionStatus status;
  final DateTime? completedAt;

  CompletionModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.status,
    this.completedAt,
  });

  factory CompletionModel.fromMap(Map<String, dynamic> map, String id) {
    return CompletionModel(
      id: id,
      userId: map['userId'] ?? '',
      habitId: map['habitId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: CompletionStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'missed'),
        orElse: () => CompletionStatus.missed,
      ),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'habitId': habitId,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  bool get isCompleted => status == CompletionStatus.completed;
}
