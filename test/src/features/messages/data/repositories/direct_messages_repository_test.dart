import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/messages/data/repositories/direct_messages_repository.dart';
import 'package:teen_talk_app/src/features/friends/data/repositories/friends_repository.dart';

void main() {
  group('DirectMessagesRepository', () {
    late DirectMessagesRepository repository;
    late FakeFirebaseFirestore firestore;
    late FriendsRepository friendsRepository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      friendsRepository = FriendsRepository(firestore);
      repository = DirectMessagesRepository(firestore, friendsRepository);
    });

    Future<void> makeFriends(String userA, String userB) async {
      final timestamp = Timestamp.now();
      final conversationId = _generateConversationId(userA, userB);

      await firestore
          .collection('friends')
          .doc(userA)
          .collection('list')
          .doc(userB)
          .set({
        'createdAt': timestamp,
        'conversationId': conversationId,
      });

      await firestore
          .collection('friends')
          .doc(userB)
          .collection('list')
          .doc(userA)
          .set({
        'createdAt': timestamp,
        'conversationId': conversationId,
      });
    }

    group('_generateConversationId', () {
      test('generates consistent ID regardless of order', () {
        final id1 = _generateConversationId('user1', 'user2');
        final id2 = _generateConversationId('user2', 'user1');
        
        expect(id1, id2);
      });

      test('generates unique ID for different user pairs', () {
        final id1 = _generateConversationId('user1', 'user2');
        final id2 = _generateConversationId('user1', 'user3');
        
        expect(id1, isNot(id2));
      });
    });

    group('sendMessage', () {
      test('creates new conversation when sending first message', () async {
        const senderId = 'user1';
        const receiverId = 'user2';

        await makeFriends(senderId, receiverId);

        final message = await repository.sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          text: 'Hello!',
        );

        expect(message.senderId, senderId);
        expect(message.content, 'Hello!');

        final conversationId = _generateConversationId(senderId, receiverId);
        final conversation = await firestore
            .collection('conversations')
            .doc(conversationId)
            .get();

        expect(conversation.exists, true);
        expect(conversation.get('participantIds'), containsAll([senderId, receiverId]));
      });

      test('updates existing conversation when sending message', () async {
        const senderId = 'user1';
        const receiverId = 'user2';
        final conversationId = _generateConversationId(senderId, receiverId);

        await makeFriends(senderId, receiverId);

        await firestore.collection('conversations').doc(conversationId).set({
          'userId1': 'user1',
          'userId2': 'user2',
          'participantIds': ['user1', 'user2'],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'unreadCount': 0,
          'unreadCounts': {'user1': 0, 'user2': 0},
        });

        final message = await repository.sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          text: 'Second message',
        );

        expect(message.content, 'Second message');

        final messages = await firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();

        expect(messages.docs.length, 1);
      });

      test('throws exception when users are not friends', () async {
        const senderId = 'user1';
        const receiverId = 'user2';

        expect(
          () => repository.sendMessage(
            senderId: senderId,
            receiverId: receiverId,
            text: 'Hello!',
          ),
          throwsException,
        );
      });

      test('throws exception when sender is blocked by receiver', () async {
        const senderId = 'user1';
        const receiverId = 'user2';

        await makeFriends(senderId, receiverId);

        await firestore.collection('blocks').doc(receiverId).set({
          'createdAt': Timestamp.now(),
        });

        await firestore
            .collection('blocks')
            .doc(receiverId)
            .collection('blockedUsers')
            .doc(senderId)
            .set({
          'blockedUserId': senderId,
          'createdAt': Timestamp.now(),
        });

        expect(
          () => repository.sendMessage(
            senderId: senderId,
            receiverId: receiverId,
            text: 'Hello!',
          ),
          throwsException,
        );
      });

      test('increments unread count for receiver', () async {
        const senderId = 'user1';
        const receiverId = 'user2';

        await makeFriends(senderId, receiverId);

        await repository.sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          text: 'Hello!',
        );

        final conversationId = _generateConversationId(senderId, receiverId);
        final conversation = await firestore
            .collection('conversations')
            .doc(conversationId)
            .get();

        final unreadCounts = conversation.get('unreadCounts') as Map<String, dynamic>;
        expect(unreadCounts[receiverId], 1);
        expect(unreadCounts[senderId], 0);
      });

      test('stores message with correct timestamp', () async {
        const senderId = 'user1';
        const receiverId = 'user2';

        await makeFriends(senderId, receiverId);

        final beforeSend = DateTime.now();
        await repository.sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          text: 'Hello!',
        );
        final afterSend = DateTime.now();

        final conversationId = _generateConversationId(senderId, receiverId);
        final messages = await firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();

        expect(messages.docs.length, 1);
        final messageData = messages.docs.first.data();
        final messageTime = (messageData['createdAt'] as Timestamp).toDate();

        expect(messageTime.isAfter(beforeSend.subtract(const Duration(seconds: 1))), true);
        expect(messageTime.isBefore(afterSend.add(const Duration(seconds: 1))), true);
      });
    });

    group('blockUser', () {
      test('creates block document and adds user to blocked list', () async {
        const blockerId = 'user1';
        const blockedUserId = 'user2';

        await repository.blockUser(blockerId, blockedUserId);

        final blockerDoc = await firestore.collection('blocks').doc(blockerId).get();
        expect(blockerDoc.exists, true);

        final blockedUserDoc = await firestore
            .collection('blocks')
            .doc(blockerId)
            .collection('blockedUsers')
            .doc(blockedUserId)
            .get();
        expect(blockedUserDoc.exists, true);
        expect(blockedUserDoc.get('blockedUserId'), blockedUserId);
      });

      test('handles blocking multiple users', () async {
        const blockerId = 'user1';

        await repository.blockUser(blockerId, 'user2');
        await repository.blockUser(blockerId, 'user3');

        final blockedUsers = await firestore
            .collection('blocks')
            .doc(blockerId)
            .collection('blockedUsers')
            .get();

        expect(blockedUsers.docs.length, 2);
      });

      test('creates blocker document if it does not exist', () async {
        const blockerId = 'user1';
        const blockedUserId = 'user2';

        final blockerDocBefore = await firestore
            .collection('blocks')
            .doc(blockerId)
            .get();
        expect(blockerDocBefore.exists, false);

        await repository.blockUser(blockerId, blockedUserId);

        final blockerDocAfter = await firestore
            .collection('blocks')
            .doc(blockerId)
            .get();
        expect(blockerDocAfter.exists, true);
      });
    });

    group('unblockUser', () {
      test('removes user from blocked list', () async {
        const blockerId = 'user1';
        const blockedUserId = 'user2';

        await repository.blockUser(blockerId, blockedUserId);

        final blockedBefore = await repository.isUserBlocked(blockerId, blockedUserId);
        expect(blockedBefore, true);

        await repository.unblockUser(blockerId, blockedUserId);

        final blockedAfter = await repository.isUserBlocked(blockerId, blockedUserId);
        expect(blockedAfter, false);
      });

      test('handles unblocking user that was not blocked', () async {
        const blockerId = 'user1';
        const blockedUserId = 'user2';

        expect(
          () => repository.unblockUser(blockerId, blockedUserId),
          returnsNormally,
        );
      });
    });

    group('isUserBlocked', () {
      test('returns true when user is blocked', () async {
        const blockerId = 'user1';
        const blockedUserId = 'user2';

        await repository.blockUser(blockerId, blockedUserId);

        final isBlocked = await repository.isUserBlocked(blockerId, blockedUserId);
        expect(isBlocked, true);
      });

      test('returns false when user is not blocked', () async {
        const blockerId = 'user1';
        const blockedUserId = 'user2';

        final isBlocked = await repository.isUserBlocked(blockerId, blockedUserId);
        expect(isBlocked, false);
      });

      test('returns false after unblocking', () async {
        const blockerId = 'user1';
        const blockedUserId = 'user2';

        await repository.blockUser(blockerId, blockedUserId);
        await repository.unblockUser(blockerId, blockedUserId);

        final isBlocked = await repository.isUserBlocked(blockerId, blockedUserId);
        expect(isBlocked, false);
      });

      test('blocking is directional (A blocks B does not mean B blocks A)', () async {
        const user1 = 'user1';
        const user2 = 'user2';

        await repository.blockUser(user1, user2);

        final user1BlocksUser2 = await repository.isUserBlocked(user1, user2);
        final user2BlocksUser1 = await repository.isUserBlocked(user2, user1);

        expect(user1BlocksUser2, true);
        expect(user2BlocksUser1, false);
      });
    });

    group('getBlockedUsers', () {
      test('returns list of blocked user IDs', () async {
        const blockerId = 'user1';

        await repository.blockUser(blockerId, 'user2');
        await repository.blockUser(blockerId, 'user3');
        await repository.blockUser(blockerId, 'user4');

        final blockedUsers = await repository.getBlockedUsers(blockerId);

        expect(blockedUsers.length, 3);
        expect(blockedUsers, containsAll(['user2', 'user3', 'user4']));
      });

      test('returns empty list when no users are blocked', () async {
        const blockerId = 'user1';

        final blockedUsers = await repository.getBlockedUsers(blockerId);

        expect(blockedUsers.length, 0);
      });
    });

    group('getConversation', () {
      test('returns conversation if it exists', () async {
        const user1 = 'user1';
        const user2 = 'user2';
        final conversationId = _generateConversationId(user1, user2);

        await firestore.collection('conversations').doc(conversationId).set({
          'userId1': user1,
          'userId2': user2,
          'participantIds': [user1, user2],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'unreadCount': 0,
          'unreadCounts': {'user1': 0, 'user2': 0},
        });

        final conversation = await repository.getConversation(user1, user2);

        expect(conversation, isNotNull);
      });

      test('returns null if conversation does not exist', () async {
        final conversation = await repository.getConversation('user1', 'user2');

        expect(conversation, isNull);
      });
    });

    group('markConversationAsRead', () {
      test('resets unread count for specific user', () async {
        const user1 = 'user1';
        const user2 = 'user2';
        final conversationId = _generateConversationId(user1, user2);

        await firestore.collection('conversations').doc(conversationId).set({
          'userId1': user1,
          'userId2': user2,
          'participantIds': [user1, user2],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'unreadCount': 5,
          'unreadCounts': {user1: 0, user2: 5},
        });

        await repository.markConversationAsRead(conversationId, user2);

        final conversation = await firestore
            .collection('conversations')
            .doc(conversationId)
            .get();

        final unreadCounts = conversation.get('unreadCounts') as Map<String, dynamic>;
        expect(unreadCounts[user2], 0);
        expect(unreadCounts[user1], 0);
      });

      test('marks all unread messages as read', () async {
        const user1 = 'user1';
        const user2 = 'user2';
        final conversationId = _generateConversationId(user1, user2);

        await firestore.collection('conversations').doc(conversationId).set({
          'userId1': user1,
          'userId2': user2,
          'participantIds': [user1, user2],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'unreadCount': 3,
          'unreadCounts': {user1: 0, user2: 3},
        });

        await firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .add({
          'senderId': user1,
          'content': 'Message 1',
          'isRead': false,
          'createdAt': Timestamp.now(),
        });

        await firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .add({
          'senderId': user1,
          'content': 'Message 2',
          'isRead': false,
          'createdAt': Timestamp.now(),
        });

        await repository.markConversationAsRead(conversationId, user2);

        final messages = await firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();

        for (final doc in messages.docs) {
          expect(doc.get('isRead'), true);
        }
      });
    });

    group('deleteConversation', () {
      test('deletes conversation and all messages', () async {
        const user1 = 'user1';
        const user2 = 'user2';
        final conversationId = _generateConversationId(user1, user2);

        await firestore.collection('conversations').doc(conversationId).set({
          'userId1': user1,
          'userId2': user2,
          'participantIds': [user1, user2],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'unreadCount': 0,
          'unreadCounts': {user1: 0, user2: 0},
        });

        await firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .add({
          'senderId': user1,
          'content': 'Message 1',
          'createdAt': Timestamp.now(),
        });

        await repository.deleteConversation(conversationId);

        final conversation = await firestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        expect(conversation.exists, false);

        final messages = await firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();
        expect(messages.docs.length, 0);
      });
    });

    group('getUnreadCount', () {
      test('calculates total unread messages for user', () async {
        const userId = 'user1';

        final conv1 = _generateConversationId(userId, 'user2');
        await firestore.collection('conversations').doc(conv1).set({
          'userId1': userId,
          'userId2': 'user2',
          'participantIds': [userId, 'user2'],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'unreadCounts': {userId: 3, 'user2': 0},
        });

        final conv2 = _generateConversationId(userId, 'user3');
        await firestore.collection('conversations').doc(conv2).set({
          'userId1': userId,
          'userId2': 'user3',
          'participantIds': [userId, 'user3'],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'unreadCounts': {userId: 2, 'user3': 0},
        });

        final totalUnread = await repository.getUnreadCount(userId);

        expect(totalUnread, 5);
      });

      test('returns 0 when user has no unread messages', () async {
        const userId = 'user1';

        final totalUnread = await repository.getUnreadCount(userId);

        expect(totalUnread, 0);
      });
    });
  });
}

String _generateConversationId(String userId1, String userId2) {
  final ids = [userId1, userId2]..sort();
  return '${ids[0]}_${ids[1]}';
}
