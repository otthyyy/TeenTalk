import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_request.dart';
import '../models/friend_entry.dart';
import '../models/friendship_status.dart';

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepository(FirebaseFirestore.instance);
});

class FriendsRepository {

  FriendsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  String _generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> sendFriendRequest(String fromUserId, String toUserId) async {
    if (fromUserId == toUserId) {
      throw Exception('Cannot send friend request to yourself');
    }

    final existingStatus = await getFriendshipStatus(fromUserId, toUserId);
    if (existingStatus != FriendshipStatus.none) {
      throw Exception('Friend request already exists or users are already friends');
    }

    final requestRef = _firestore.collection('friendRequests').doc();
    final request = FriendRequest(
      id: requestRef.id,
      senderId: fromUserId,
      receiverId: toUserId,
      status: FriendRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    await requestRef.set(request.toFirestore());
    return requestRef.id;
  }

  Future<void> cancelFriendRequest(String requestId) async {
    await _firestore
        .collection('friendRequests')
        .doc(requestId)
        .update({
      'status': FriendRequestStatus.cancelled.name,
      'respondedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> acceptFriendRequest(String requestId) async {
    final requestDoc = await _firestore
        .collection('friendRequests')
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw Exception('Friend request not found');
    }

    final request = FriendRequest.fromFirestore(requestDoc);
    if (request.status != FriendRequestStatus.pending) {
      throw Exception('Friend request is no longer pending');
    }

    final batch = _firestore.batch();
    final now = DateTime.now();

    batch.update(requestDoc.reference, {
      'status': FriendRequestStatus.accepted.name,
      'respondedAt': Timestamp.fromDate(now),
      'conversationId': _generateConversationId(
        request.senderId,
        request.receiverId,
      ),
    });

    final conversationId = _generateConversationId(
      request.senderId,
      request.receiverId,
    );

    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);

    final conversationDoc = await conversationRef.get();
    if (!conversationDoc.exists) {
      final participantIds = [request.senderId, request.receiverId]..sort();
      batch.set(conversationRef, {
        'userId1': participantIds[0],
        'userId2': participantIds[1],
        'participantIds': participantIds,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'unreadCount': 0,
        'unreadCounts': {
          request.senderId: 0,
          request.receiverId: 0,
        },
      });
    }

    final senderFriendRef = _firestore
        .collection('friends')
        .doc(request.senderId)
        .collection('list')
        .doc(request.receiverId);

    batch.set(senderFriendRef, {
      'conversationId': conversationId,
      'createdAt': Timestamp.fromDate(now),
    });

    final receiverFriendRef = _firestore
        .collection('friends')
        .doc(request.receiverId)
        .collection('list')
        .doc(request.senderId);

    batch.set(receiverFriendRef, {
      'conversationId': conversationId,
      'createdAt': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore
        .collection('friendRequests')
        .doc(requestId)
        .update({
      'status': FriendRequestStatus.rejected.name,
      'respondedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<FriendRequest>> watchIncomingRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendRequest.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<FriendRequest>> watchOutgoingRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendRequest.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<FriendEntry>> watchFriends(String userId) {
    return _firestore
        .collection('friends')
        .doc(userId)
        .collection('list')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendEntry.fromFirestore(doc))
          .toList();
    });
  }

  Future<bool> areFriends(String userId1, String userId2) async {
    final doc = await _firestore
        .collection('friends')
        .doc(userId1)
        .collection('list')
        .doc(userId2)
        .get();

    return doc.exists;
  }

  Future<FriendshipStatus> getFriendshipStatus(
    String currentUserId,
    String otherUserId,
  ) async {
    if (currentUserId == otherUserId) {
      return FriendshipStatus.none;
    }

    final areFriendsResult = await areFriends(currentUserId, otherUserId);
    if (areFriendsResult) {
      return FriendshipStatus.friends;
    }

    final sentRequest = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: otherUserId)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .limit(1)
        .get();

    if (sentRequest.docs.isNotEmpty) {
      return FriendshipStatus.pendingSent;
    }

    final receivedRequest = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .limit(1)
        .get();

    if (receivedRequest.docs.isNotEmpty) {
      return FriendshipStatus.pendingReceived;
    }

    return FriendshipStatus.none;
  }

  Future<String?> getPendingRequestId(String currentUserId, String otherUserId) async {
    final sentRequest = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: otherUserId)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .limit(1)
        .get();

    if (sentRequest.docs.isNotEmpty) {
      return sentRequest.docs.first.id;
    }

    final receivedRequest = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .limit(1)
        .get();

    if (receivedRequest.docs.isNotEmpty) {
      return receivedRequest.docs.first.id;
    }

    return null;
  }

  Future<void> removeFriend(String userId, String friendId) async {
    final batch = _firestore.batch();

    final userFriendRef = _firestore
        .collection('friends')
        .doc(userId)
        .collection('list')
        .doc(friendId);

    final friendUserRef = _firestore
        .collection('friends')
        .doc(friendId)
        .collection('list')
        .doc(userId);

    batch.delete(userFriendRef);
    batch.delete(friendUserRef);

    await batch.commit();
  }

  Future<String?> getConversationId(String userId, String friendId) async {
    final doc = await _firestore
        .collection('friends')
        .doc(userId)
        .collection('list')
        .doc(friendId)
        .get();

    if (doc.exists) {
      return doc.data()?['conversationId'] as String?;
    }
    return null;
  }
}
