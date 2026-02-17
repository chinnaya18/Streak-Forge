import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friendship_model.dart';
import '../config/constants.dart';
import 'notification_service.dart';

class FriendRequestListener {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  
  Stream<List<FriendshipModel>> getPendingFriendRequests(String userId) {
    return _firestore
        .collection(AppConstants.friendshipsCollection)
        .where('user2Id', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendshipModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Listen for new friend requests and show notifications
  void listenForFriendRequests(String userId) {
    getPendingFriendRequests(userId).listen((requests) {
      for (var request in requests) {
        _notificationService.showFriendRequestNotification(
          friendName: request.user1Name,
          requestId: request.id,
        );
      }
    });
  }
}
