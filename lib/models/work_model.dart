import 'package:cloud_firestore/cloud_firestore.dart';

class WorkModel {
  final String id;
  final String habitId;
  final String userId;
  final String workName;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int order;

  WorkModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.workName,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    required this.order,
  });

  factory WorkModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkModel(
      id: id,
      habitId: map['habitId'] ?? '',
      userId: map['userId'] ?? '',
      workName: map['workName'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'userId': userId,
      'workName': workName,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'order': order,
    };
  }

  WorkModel copyWith({
    String? workName,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return WorkModel(
      id: id,
      habitId: habitId,
      userId: userId,
      workName: workName ?? this.workName,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      order: order,
    );
  }
}
