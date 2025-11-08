import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/direct_message.dart';
import '../models/conversation.dart';
import '../models/block.dart';

final directMessagesRepositoryProvider =
    Provider<DirectMessagesRepository>((ref) {
  return DirectMessagesRepository(FirebaseFirestore.instance);
});

class DirectMessagesRepository {
  final FirebaseFirestore _firestore;

  DirectMessagesRepository(this._firestore);

  /// Generate a conversation ID from two user IDs (ensures consistency)
  String _generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Send a direct message
  Future<DirectMessage> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    String? imageUrl,
  }) async {
    // Check if sender is blocked by receiver
    final isBlocked = await isUserBlocked(receiverId, senderId);
    if (isBlocked) {
      throw Exception('This user has blocked you');
    }

    final conversationId = _generateConversationId(senderId, receiverId);
    final batch = _firestore.batch();

    // Create or get conversation
    final conversationRef = _firestore.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();
    
    if (!conversationDoc.exists) {
      final now = DateTime.now();
      batch.set(conversationRef, {
        'userId1': senderId,
        'userId2': receiverId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'unreadCount': 1,
      });
    } else {
      // Increment unread count if receiver has unread messages
      batch.update(conversationRef, {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    // Create message
    final messageRef = conversationRef.collection('messages').doc();
    final now = DateTime.now();
    final message = DirectMessage(
      id: messageRef.id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: 'User',
      content: text,
      imageUrl: imageUrl,
      isRead: false,
      createdAt: now,
    );

    batch.set(messageRef, message.toJson());

    // Update last message in conversation
    batch.update(conversationRef, {
      'lastMessageId': messageRef.id,
      'lastMessage': text,
      'lastSenderId': senderId,
      'lastMessageTime': Timestamp.fromDate(now),
    });

    await batch.commit();
    return message;
  }

  /// Get conversations for a user (real-time)
  Stream<List<Conversation>> watchConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('userId1', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final conversations = <Conversation>[];
      for (final doc in snapshot.docs) {
        final conv = Conversation.fromFirestore(doc);
        conversations.add(conv);
      }
      return conversations;
    });
  }

  /// Get a single conversation
  Future<Conversation?> getConversation(String userId1, String userId2) async {
    final conversationId = _generateConversationId(userId1, userId2);
    final doc = await _firestore.collection('conversations').doc(conversationId).get();
    return doc.exists ? Conversation.fromFirestore(doc) : null;
  }

  /// Watch messages in a conversation (real-time)
  Stream<List<DirectMessage>> watchMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DirectMessage.fromFirestore(doc))
          .toList()
          .reversed
          .toList();
    });
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(
    String conversationId,
    String messageId,
  ) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isRead': true,
      'readAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Mark all messages in a conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    final messagesRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    final query = await messagesRef.where('isRead', isEqualTo: false).get();
    final batch = _firestore.batch();

    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    // Reset unread count
    batch.update(_firestore.collection('conversations').doc(conversationId), {
      'unreadCount': 0,
    });

    await batch.commit();
  }

  /// Block a user
  Future<void> blockUser(String blockerId, String blockedUserId) async {
    final blockRef = _firestore.collection('blocks').doc(blockerId);
    final blocksCollection = blockRef.collection('blockedUsers');
    
    final batch = _firestore.batch();
    
    // Create or get the blocker's document
    final blockerDoc = await blockRef.get();
    if (!blockerDoc.exists) {
      batch.set(blockRef, {
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    // Add to blocked users
    batch.set(
      blocksCollection.doc(blockedUserId),
      {
        'blockedUserId': blockedUserId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      },
    );

    await batch.commit();
  }

  /// Unblock a user
  Future<void> unblockUser(String blockerId, String blockedUserId) async {
    await _firestore
        .collection('blocks')
        .doc(blockerId)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String blockerId, String potentialBlockedUser) async {
    final doc = await _firestore
        .collection('blocks')
        .doc(blockerId)
        .collection('blockedUsers')
        .doc(potentialBlockedUser)
        .get();
    return doc.exists;
  }

  /// Get list of blocked users
  Future<List<String>> getBlockedUsers(String userId) async {
    final snapshot = await _firestore
        .collection('blocks')
        .doc(userId)
        .collection('blockedUsers')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    final batch = _firestore.batch();

    // Delete all messages
    final messagesSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .get();

    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete conversation
    batch.delete(_firestore.collection('conversations').doc(conversationId));

    await batch.commit();
  }

  /// Delete a specific message
  Future<void> deleteMessage(String conversationId, String messageId) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// Get unread message count for a user
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection('conversations')
        .where('userId2', isEqualTo: userId)
        .get();

    int totalUnread = 0;
    for (final doc in snapshot.docs) {
      totalUnread += (doc['unreadCount'] as int?) ?? 0;
    }
    return totalUnread;
  }
}
