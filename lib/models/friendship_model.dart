import 'package:cloud_firestore/cloud_firestore.dart';

class FriendshipModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final int friendshipStreak;
  final int maxFriendshipStreak;
  final DateTime createdAt;
  final DateTime? lastBothCompletedDate;

  FriendshipModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.user1Name = '',
    this.user2Name = '',
    this.friendshipStreak = 0,
    this.maxFriendshipStreak = 0,
    required this.createdAt,
    this.lastBothCompletedDate,
  });

  factory FriendshipModel.fromMap(Map<String, dynamic> map, String id) {
    return FriendshipModel(
      id: id,
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      user1Name: map['user1Name'] ?? '',
      user2Name: map['user2Name'] ?? '',
      friendshipStreak: map['friendshipStreak'] ?? 0,
      maxFriendshipStreak: map['maxFriendshipStreak'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastBothCompletedDate: map['lastBothCompletedDate'] != null
          ? (map['lastBothCompletedDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'friendshipStreak': friendshipStreak,
      'maxFriendshipStreak': maxFriendshipStreak,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastBothCompletedDate': lastBothCompletedDate != null
          ? Timestamp.fromDate(lastBothCompletedDate!)
          : null,
    };
  }

  String getFriendName(String currentUserId) {
    return currentUserId == user1Id ? user2Name : user1Name;
  }

  String getFriendId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
}
