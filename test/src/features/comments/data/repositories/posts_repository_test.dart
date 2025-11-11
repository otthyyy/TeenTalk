import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PostsRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = PostsRepository(firestore: firestore);
  });

  group('PostsRepository - getPostsByAuthor', () {
    late DateTime baseTime;

    setUp(() async {
      baseTime = DateTime.utc(2024, 1, 10, 12);

      await firestore.collection('posts').doc('post1').set({
        'authorId': 'user1',
        'authorNickname': 'TestUser',
        'isAnonymous': false,
        'isModerated': false,
        'content': 'Test post 1',
        'school': 'Test School',
        'section': 'spotted',
        'createdAt': baseTime.subtract(const Duration(hours: 2)).toIso8601String(),
        'updatedAt': baseTime.subtract(const Duration(hours: 2)).toIso8601String(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'mentionedUserIds': <String>[],
        'engagementScore': 0.0,
      });

      await firestore.collection('posts').doc('post2').set({
        'authorId': 'user1',
        'authorNickname': 'TestUser',
        'isAnonymous': false,
        'isModerated': false,
        'content': 'Test post 2',
        'school': 'Test School',
        'section': 'spotted',
        'createdAt': baseTime.subtract(const Duration(hours: 1)).toIso8601String(),
        'updatedAt': baseTime.subtract(const Duration(hours: 1)).toIso8601String(),
        'likeCount': 5,
        'likedBy': <String>['user2', 'user3'],
        'commentCount': 2,
        'mentionedUserIds': <String>[],
        'engagementScore': 7.0,
      });

      await firestore.collection('posts').doc('post3').set({
        'authorId': 'user1',
        'authorNickname': 'TestUser',
        'isAnonymous': true,
        'isModerated': false,
        'content': 'Test anonymous post',
        'school': 'Test School',
        'section': 'spotted',
        'createdAt': baseTime.subtract(const Duration(minutes: 30)).toIso8601String(),
        'updatedAt': baseTime.subtract(const Duration(minutes: 30)).toIso8601String(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'mentionedUserIds': <String>[],
        'engagementScore': 0.0,
      });

      await firestore.collection('posts').doc('post4').set({
        'authorId': 'user2',
        'authorNickname': 'OtherUser',
        'isAnonymous': false,
        'isModerated': false,
        'content': 'Different author post',
        'school': 'Test School',
        'section': 'spotted',
        'createdAt': baseTime.subtract(const Duration(hours: 3)).toIso8601String(),
        'updatedAt': baseTime.subtract(const Duration(hours: 3)).toIso8601String(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'mentionedUserIds': <String>[],
        'engagementScore': 0.0,
      });

      await firestore.collection('posts').doc('post5').set({
        'authorId': 'user1',
        'authorNickname': 'TestUser',
        'isAnonymous': false,
        'isModerated': true,
        'content': 'Moderated post',
        'school': 'Test School',
        'section': 'spotted',
        'createdAt': baseTime.subtract(const Duration(minutes: 10)).toIso8601String(),
        'updatedAt': baseTime.subtract(const Duration(minutes: 10)).toIso8601String(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'mentionedUserIds': <String>[],
        'engagementScore': 0.0,
      });

      await firestore.collection('posts').doc('post6').set({
        'authorId': 'user1',
        'authorNickname': 'TestUser',
        'isAnonymous': false,
        'isModerated': false,
        'content': 'Different school post',
        'school': 'Other School',
        'section': 'spotted',
        'createdAt': baseTime.subtract(const Duration(hours: 4)).toIso8601String(),
        'updatedAt': baseTime.subtract(const Duration(hours: 4)).toIso8601String(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'mentionedUserIds': <String>[],
        'engagementScore': 0.0,
      });
    });

    test('filters posts by authorId and excludes anonymous posts', () async {
      expect(
        () async {
          final result = await repository.getPostsByAuthor(
            authorId: 'user1',
          );
          return result.$1.length;
        },
        completion(equals(2)),
      );
    });

    test('excludes moderated posts', () async {
      final (posts, _) = await repository.getPostsByAuthor(
        authorId: 'user1',
      );

      expect(posts.any((post) => post.isModerated), isFalse);
    });

    test('filters by school when provided', () async {
      final (posts, _) = await repository.getPostsByAuthor(
        authorId: 'user1',
        school: 'Test School',
      );

      expect(posts.every((post) => post.school == 'Test School'), isTrue);
    });

    test('excludes posts from other authors', () async {
      final (posts, _) = await repository.getPostsByAuthor(
        authorId: 'user1',
      );

      expect(posts.every((post) => post.authorId == 'user1'), isTrue);
      expect(posts.any((post) => post.authorId == 'user2'), isFalse);
    });

    test('orders posts by createdAt descending', () async {
      final (posts, _) = await repository.getPostsByAuthor(
        authorId: 'user1',
      );

      if (posts.length >= 2) {
        for (var i = 0; i < posts.length - 1; i++) {
          expect(
            posts[i].createdAt.isAfter(posts[i + 1].createdAt) ||
                posts[i].createdAt.isAtSameMomentAs(posts[i + 1].createdAt),
            isTrue,
          );
        }
      }
    });

    test('respects pagination limit', () async {
      final (posts, _) = await repository.getPostsByAuthor(
        authorId: 'user1',
        limit: 1,
      );

      expect(posts.length, lessThanOrEqualTo(1));
    });
  });

  group('PostsRepository - getPostsStreamByAuthor', () {
    test('streams posts by author in real-time', () async {
      await firestore.collection('posts').doc('stream_post').set({
        'authorId': 'user3',
        'authorNickname': 'StreamUser',
        'isAnonymous': false,
        'isModerated': false,
        'content': 'Stream test post',
        'school': 'Stream School',
        'section': 'spotted',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'mentionedUserIds': <String>[],
        'engagementScore': 0.0,
      });

      final stream = repository.getPostsStreamByAuthor(
        authorId: 'user3',
        school: 'Stream School',
      );

      expect(
        stream,
        emitsInOrder([
          predicate<List>((posts) => posts.length == 1 && posts.first.authorId == 'user3'),
        ]),
      );
    });
  });
}
