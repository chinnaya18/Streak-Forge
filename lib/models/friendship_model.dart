import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendshipStatus { pending, accepted }

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
  final FriendshipStatus status;

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
    this.status = FriendshipStatus.accepted,
  });

  factory FriendshipModel.fromMap(Map<String, dynamic> map, String id) {
    final statusString = map['status'] ?? 'accepted';
    final statusEnum = statusString == 'pending' 
        ? FriendshipStatus.pending 
        : FriendshipStatus.accepted;
    
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
      status: statusEnum,
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
      'status': status == FriendshipStatus.pending ? 'pending' : 'accepted',
    };
  }

  String getFriendName(String currentUserId) {
    return currentUserId == user1Id ? user2Name : user1Name;
  }

  String getFriendId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  FriendshipModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? user1Name,
    String? user2Name,
    int? friendshipStreak,
    int? maxFriendshipStreak,
    DateTime? createdAt,
    DateTime? lastBothCompletedDate,
    FriendshipStatus? status,
  }) {
    return FriendshipModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      user1Name: user1Name ?? this.user1Name,
      user2Name: user2Name ?? this.user2Name,
      friendshipStreak: friendshipStreak ?? this.friendshipStreak,
      maxFriendshipStreak: maxFriendshipStreak ?? this.maxFriendshipStreak,
      createdAt: createdAt ?? this.createdAt,
      lastBothCompletedDate: lastBothCompletedDate ?? this.lastBothCompletedDate,
      status: status ?? this.status,
    );
  }
}
