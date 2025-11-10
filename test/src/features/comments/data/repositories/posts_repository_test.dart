import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';

class _FakeFirebaseStorage extends Fake implements FirebaseStorage {}

void main() {
  group('PostsRepository', () {
    late FakeFirebaseFirestore firestore;
    late PostsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = PostsRepository(
        firestore: firestore,
        storage: _FakeFirebaseStorage(),
      );
    });

    Future<DocumentReference<Map<String, dynamic>>> _createPost({
      required String content,
      bool isModerated = false,
      int likeCount = 0,
      List<String> likedBy = const [],
      int commentCount = 0,
      String section = 'spotted',
      String? school,
    }) {
      final now = DateTime.now();
      return firestore.collection('posts').add({
        'authorId': 'author1',
        'authorNickname': 'Author One',
        'isAnonymous': false,
        'content': content,
        'section': section,
        'school': school,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'likeCount': likeCount,
        'likedBy': likedBy,
        'commentCount': commentCount,
        'mentionedUserIds': <String>[],
        'isModerated': isModerated,
      });
    }

    group('getPosts', () {
      test('filters by section and excludes moderated posts', () async {
        await _createPost(content: 'Spotted post', section: 'spotted');
        await _createPost(content: 'Help post', section: 'help');
        await _createPost(
          content: 'Moderated post',
          section: 'spotted',
          isModerated: true,
        );

        final (posts, lastDocument) = await repository.getPosts(
          section: 'spotted',
          limit: 10,
          sortOption: FeedSortOption.newest,
        );

        expect(posts.length, 1);
        expect(posts.first.content, 'Spotted post');
        expect(lastDocument, isNotNull);
      });

      test('orders posts by createdAt descending for newest sort option', () async {
        final oldest = await _createPost(content: 'Oldest');
        final newest = await _createPost(content: 'Newest');

        // Update timestamps to ensure ordering
        await oldest.update({'createdAt': DateTime(2023, 1, 1).toIso8601String()});
        await newest.update({'createdAt': DateTime(2024, 1, 1).toIso8601String()});

        final (posts, _) = await repository.getPosts(
          limit: 10,
          sortOption: FeedSortOption.newest,
        );

        expect(posts.length, 2);
        expect(posts.first.content, 'Newest');
        expect(posts.last.content, 'Oldest');
      });
    });

    group('createPost', () {
      test('returns post with extracted mentions', () async {
        final post = await repository.createPost(
          authorId: 'author1',
          authorNickname: 'Author One',
          isAnonymous: false,
          content: 'Hello @friend1 and @friend2',
        );

        expect(post.mentionedUserIds, ['friend1', 'friend2']);

        final stored = await firestore.collection('posts').doc(post.id).get();
        expect(stored.exists, true);
        expect(stored.get('mentionedUserIds'), ['friend1', 'friend2']);
      });

      test('increments anonymous post count for anonymous authors', () async {
        final post = await repository.createPost(
          authorId: 'anonymousUser',
          authorNickname: 'Mystery',
          isAnonymous: true,
          content: 'Anonymous post content',
        );

        expect(post.isAnonymous, true);

        final userDoc = await firestore.collection('users').doc('anonymousUser').get();
        expect(userDoc.exists, true);
        expect(userDoc.get('anonymousPostsCount'), 1);
      });

      test('throws when content is empty', () async {
        expect(
          () => repository.createPost(
            authorId: 'author1',
            authorNickname: 'Author One',
            isAnonymous: false,
            content: '   ',
          ),
          throwsException,
        );
      });
    });

    group('likePost', () {
      test('increments like count and adds user to likedBy', () async {
        final docRef = await _createPost(content: 'Like me');

        await repository.likePost(docRef.id, 'user42');

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user42']);
      });

      test('does not add duplicate likes', () async {
        final docRef = await _createPost(
          content: 'Already liked',
          likeCount: 1,
          likedBy: const ['user42'],
        );

        await repository.likePost(docRef.id, 'user42');

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user42']);
      });

      test('throws when liking non-existent post', () async {
        expect(
          () => repository.likePost('missing', 'user42'),
          throwsException,
        );
      });
    });

    group('unlikePost', () {
      test('decrements like count and removes user from likedBy', () async {
        final docRef = await _createPost(
          content: 'Unlike me',
          likeCount: 2,
          likedBy: const ['user42', 'user99'],
        );

        await repository.unlikePost(docRef.id, 'user42');

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user99']);
      });

      test('does not decrement below zero', () async {
        final docRef = await _createPost(
          content: 'Never negative',
          likeCount: 1,
          likedBy: const ['user42'],
        );

        await repository.unlikePost(docRef.id, 'user42');
        await repository.unlikePost(docRef.id, 'user42');

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 0);
        expect((updated.get('likedBy') as List).isEmpty, true);
      });
    });

    group('getPostById', () {
      test('returns null for missing post', () async {
        final post = await repository.getPostById('missing');
        expect(post, isNull);
      });

      test('returns post with transformed data', () async {
        final docRef = await _createPost(
          content: 'Transform me',
          likeCount: 3,
          likedBy: const ['user1', 'user2', 'user3'],
          commentCount: 5,
          section: 'help',
          school: 'Harvard',
        );

        final post = await repository.getPostById(docRef.id);

        expect(post, isNotNull);
        expect(post!.id, docRef.id);
        expect(post.likeCount, 3);
        expect(post.likedBy.length, 3);
        expect(post.commentCount, 5);
        expect(post.section, 'help');
        expect(post.school, 'Harvard');
      });
    });
  });
}
