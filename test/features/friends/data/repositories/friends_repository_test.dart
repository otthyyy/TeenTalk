import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:teen_talk_app/src/features/friends/data/repositories/friends_repository.dart';
import 'package:teen_talk_app/src/features/friends/data/models/friend_request.dart';
import 'package:teen_talk_app/src/features/friends/data/models/friendship_status.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FriendsRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FriendsRepository(firestore);
  });

  group('FriendsRepository', () {
    const userId1 = 'user1';
    const userId2 = 'user2';

    test('sendFriendRequest creates a pending friend request', () async {
      final requestId = await repository.sendFriendRequest(userId1, userId2);

      expect(requestId, isNotEmpty);

      final doc = await firestore.collection('friendRequests').doc(requestId).get();
      expect(doc.exists, isTrue);

      final request = FriendRequest.fromFirestore(doc);
      expect(request.senderId, userId1);
      expect(request.receiverId, userId2);
      expect(request.status, FriendRequestStatus.pending);
    });

    test('sendFriendRequest throws when sending to self', () async {
      expect(
        () => repository.sendFriendRequest(userId1, userId1),
        throwsException,
      );
    });

    test('getFriendshipStatus returns none initially', () async {
      final status = await repository.getFriendshipStatus(userId1, userId2);
      expect(status, FriendshipStatus.none);
    });

    test('getFriendshipStatus returns pendingSent after sending request', () async {
      await repository.sendFriendRequest(userId1, userId2);

      final status = await repository.getFriendshipStatus(userId1, userId2);
      expect(status, FriendshipStatus.pendingSent);
    });

    test('getFriendshipStatus returns pendingReceived for receiver', () async {
      await repository.sendFriendRequest(userId1, userId2);

      final status = await repository.getFriendshipStatus(userId2, userId1);
      expect(status, FriendshipStatus.pendingReceived);
    });

    test('acceptFriendRequest creates friendship and conversation', () async {
      final requestId = await repository.sendFriendRequest(userId1, userId2);

      await repository.acceptFriendRequest(requestId);

      final status1 = await repository.getFriendshipStatus(userId1, userId2);
      final status2 = await repository.getFriendshipStatus(userId2, userId1);
      expect(status1, FriendshipStatus.friends);
      expect(status2, FriendshipStatus.friends);

      final areFriends1 = await repository.areFriends(userId1, userId2);
      final areFriends2 = await repository.areFriends(userId2, userId1);
      expect(areFriends1, isTrue);
      expect(areFriends2, isTrue);

      final conversationId = repository._generateConversationId(userId1, userId2);
      final conversationDoc = await firestore.collection('conversations').doc(conversationId).get();
      expect(conversationDoc.exists, isTrue);
    });

    test('rejectFriendRequest marks request as rejected', () async {
      final requestId = await repository.sendFriendRequest(userId1, userId2);

      await repository.rejectFriendRequest(requestId);

      final doc = await firestore.collection('friendRequests').doc(requestId).get();
      final request = FriendRequest.fromFirestore(doc);
      expect(request.status, FriendRequestStatus.rejected);
    });

    test('cancelFriendRequest marks request as cancelled', () async {
      final requestId = await repository.sendFriendRequest(userId1, userId2);

      await repository.cancelFriendRequest(requestId);

      final doc = await firestore.collection('friendRequests').doc(requestId).get();
      final request = FriendRequest.fromFirestore(doc);
      expect(request.status, FriendRequestStatus.cancelled);
    });

    test('watchIncomingRequests streams incoming friend requests', () async {
      await repository.sendFriendRequest(userId1, userId2);

      final stream = repository.watchIncomingRequests(userId2);
      final requests = await stream.first;

      expect(requests.length, 1);
      expect(requests.first.senderId, userId1);
      expect(requests.first.receiverId, userId2);
    });

    test('watchOutgoingRequests streams outgoing friend requests', () async {
      await repository.sendFriendRequest(userId1, userId2);

      final stream = repository.watchOutgoingRequests(userId1);
      final requests = await stream.first;

      expect(requests.length, 1);
      expect(requests.first.senderId, userId1);
      expect(requests.first.receiverId, userId2);
    });

    test('watchFriends streams friends list', () async {
      final requestId = await repository.sendFriendRequest(userId1, userId2);
      await repository.acceptFriendRequest(requestId);

      final stream = repository.watchFriends(userId1);
      final friends = await stream.first;

      expect(friends.length, 1);
      expect(friends.first.friendId, userId2);
    });

    test('removeFriend removes friendship from both users', () async {
      final requestId = await repository.sendFriendRequest(userId1, userId2);
      await repository.acceptFriendRequest(requestId);

      await repository.removeFriend(userId1, userId2);

      final areFriends1 = await repository.areFriends(userId1, userId2);
      final areFriends2 = await repository.areFriends(userId2, userId1);
      expect(areFriends1, isFalse);
      expect(areFriends2, isFalse);
    });

    test('getConversationId returns conversation ID for friends', () async {
      final requestId = await repository.sendFriendRequest(userId1, userId2);
      await repository.acceptFriendRequest(requestId);

      final conversationId = await repository.getConversationId(userId1, userId2);
      expect(conversationId, isNotNull);
      expect(conversationId, contains('_'));
    });

    test('getConversationId returns null for non-friends', () async {
      final conversationId = await repository.getConversationId(userId1, userId2);
      expect(conversationId, isNull);
    });
  });
}

extension on FriendsRepository {
  String _generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
