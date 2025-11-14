import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';
import 'package:teen_talk_app/src/core/exceptions/post_exceptions.dart';

class _FakeFirebaseStorage extends Fake implements FirebaseStorage {
  @override
  Reference ref([String? path]) => _FakeStorageReference();
}

class _FakeStorageReference extends Fake implements Reference {
  @override
  Reference child(String path) => _FakeStorageReference();

  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    return _FakeUploadTask(success: true);
  }

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    return _FakeUploadTask(success: true);
  }
}

class _FakeUploadTask extends Fake implements UploadTask {
  _FakeUploadTask({required this.success});
  final bool success;

  @override
  Stream<TaskSnapshot> asStream() => Stream.fromFuture(future);

  @override
  Future<TaskSnapshot> get future async {
    if (!success) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'unknown',
        message: 'Upload failed',
      );
    }
    return _FakeTaskSnapshot();
  }

  @override
  Future<TaskSnapshot> then<R>(
    FutureOr<R> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) {
    return future.then(onValue, onError: onError);
  }
}

class _FakeTaskSnapshot extends Fake implements TaskSnapshot {
  @override
  Reference get ref => _FakeStorageReferenceWithUrl();
}

class _FakeStorageReferenceWithUrl extends Fake implements Reference {
  @override
  Future<String> getDownloadURL() async => 'https://example.com/test-image.jpg';
}

class _TestPostsRepository extends PostsRepository {
  _TestPostsRepository({
    required FirebaseFirestore super.firestore,
    super.storage,
    this.onUpload,
  });

  final Future<String?> Function(
    File? imageFile, {
    Uint8List? imageBytes,
    String? imageName,
  })? onUpload;

  @override
  Future<String?> uploadPostImage(
    File? imageFile, {
    Uint8List? imageBytes,
    String? imageName,
  }) {
    if (onUpload != null) {
      return onUpload!(
        imageFile,
        imageBytes: imageBytes,
        imageName: imageName,
      );
    }
    return super.uploadPostImage(
      imageFile,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }
}

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

    Future<DocumentReference<Map<String, dynamic>>> createPost({
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
        await createPost(content: 'Spotted post', section: 'spotted');
        await createPost(content: 'Help post', section: 'help');
        await createPost(
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
        final oldest = await createPost(content: 'Oldest');
        final newest = await createPost(content: 'Newest');

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

      test('throws PostValidationException when content is empty', () async {
        expect(
          () => repository.createPost(
            authorId: 'author1',
            authorNickname: 'Author One',
            isAnonymous: false,
            content: '   ',
          ),
          throwsA(isA<PostValidationException>()),
        );
      });

      test('creates post with image after upload completes', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        final post = await repository.createPost(
          authorId: 'author1',
          authorNickname: 'Author One',
          isAnonymous: false,
          content: 'Post with image',
          imageBytes: imageBytes,
          imageName: 'test.jpg',
        );

        expect(post.imageUrl, isNotNull);
        expect(post.imageUrl, equals('https://example.com/test-image.jpg'));

        final stored = await firestore.collection('posts').doc(post.id).get();
        expect(stored.exists, true);
        expect(stored.get('imageUrl'), equals('https://example.com/test-image.jpg'));
      });

      test('uses SetOptions(merge: true) when creating post', () async {
        final post = await repository.createPost(
          authorId: 'author1',
          authorNickname: 'Author One',
          isAnonymous: false,
          content: 'Test merge post',
        );

        final stored = await firestore.collection('posts').doc(post.id).get();
        expect(stored.exists, true);
        expect(stored.get('content'), 'Test merge post');
      });
    });

    group('uploadPostImage', () {
      test('returns null when no image provided', () async {
        final result = await repository.uploadPostImage(null);
        expect(result, isNull);
      });

      test('throws ImageValidationException when image too large', () async {
        final largeImage = Uint8List(6 * 1024 * 1024);
        expect(
          () => repository.uploadPostImage(
            null,
            imageBytes: largeImage,
            imageName: 'large.jpg',
          ),
          throwsA(isA<ImageValidationException>()),
        );
      });

      test('returns download URL after successful upload', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final downloadUrl = await repository.uploadPostImage(
          null,
          imageBytes: imageBytes,
          imageName: 'test.jpg',
        );

        expect(downloadUrl, equals('https://example.com/test-image.jpg'));
      });
    });

    group('validatePostContent', () {
      test('throws PostValidationException for empty content', () {
        expect(
          () => repository.validatePostContent(''),
          throwsA(isA<PostValidationException>()),
        );
      });

      test('throws PostValidationException for content exceeding max length', () {
        final longContent = 'a' * 2001;
        expect(
          () => repository.validatePostContent(longContent),
          throwsA(isA<PostValidationException>()),
        );
      });

      test('does not throw for valid content', () {
        expect(
          () => repository.validatePostContent('Valid post content'),
          returnsNormally,
        );
      });
    });

    group('Image upload resilience', () {
      test('ensures upload completes before Firestore write', () async {
        final uploadCompleter = Completer<void>();
        var uploadStarted = false;

        final testRepo = _TestPostsRepository(
          firestore: firestore,
          storage: _FakeFirebaseStorage(),
          onUpload: (imageFile, {imageBytes, imageName}) async {
            uploadStarted = true;
            await uploadCompleter.future;
            return 'https://example.com/uploaded.jpg';
          },
        );

        final imageBytes = Uint8List.fromList([1, 2, 3]);

        final createFuture = testRepo.createPost(
          authorId: 'author1',
          authorNickname: 'Test',
          isAnonymous: false,
          content: 'Test content',
          imageBytes: imageBytes,
        );

        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(uploadStarted, true);

        final snapshotBefore = await firestore.collection('posts').get();
        expect(snapshotBefore.docs, isEmpty);

        uploadCompleter.complete();
        final post = await createFuture;

        final stored = await firestore.collection('posts').doc(post.id).get();
        expect(stored.exists, true);
        expect(stored.get('imageUrl'), 'https://example.com/uploaded.jpg');
      });

      test('bubbles storage failure without writing document', () async {
        final testRepo = _TestPostsRepository(
          firestore: firestore,
          storage: _FakeFirebaseStorage(),
          onUpload: (imageFile, {imageBytes, imageName}) async {
            throw const PostStorageException('Forced failure');
          },
        );

        final imageBytes = Uint8List.fromList([9, 9, 9]);

        await expectLater(
          () => testRepo.createPost(
            authorId: 'author1',
            authorNickname: 'Test',
            isAnonymous: false,
            content: 'Test content',
            imageBytes: imageBytes,
          ),
          throwsA(isA<PostStorageException>()),
        );

        final snapshotAfter = await firestore.collection('posts').get();
        expect(snapshotAfter.docs, isEmpty);
      });
    });

    group('likePost', () {
      test('increments like count and adds user to likedBy', () async {
        final docRef = await createPost(content: 'Like me');

        await repository.likePost(docRef.id, 'user42');

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user42']);
      });

      test('does not add duplicate likes', () async {
        final docRef = await createPost(
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
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('post no longer exists'),
          )),
        );
      });

      test('handles concurrent likes correctly', () async {
        final docRef = await createPost(content: 'Popular post');

        await Future.wait([
          repository.likePost(docRef.id, 'user1'),
          repository.likePost(docRef.id, 'user2'),
          repository.likePost(docRef.id, 'user3'),
        ]);

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 3);
        expect(updated.get('likedBy'), hasLength(3));
        expect(updated.get('likedBy'), containsAll(['user1', 'user2', 'user3']));
      });

      test('handles duplicate concurrent likes', () async {
        final docRef = await createPost(content: 'Double tap test');

        await Future.wait([
          repository.likePost(docRef.id, 'user42'),
          repository.likePost(docRef.id, 'user42'),
          repository.likePost(docRef.id, 'user42'),
        ]);

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user42']);
      });

      test('allows multiple users to like the same post', () async {
        final docRef = await createPost(content: 'Multi-user like test');

        await repository.likePost(docRef.id, 'user1');
        await repository.likePost(docRef.id, 'user2');

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 2);
        expect(updated.get('likedBy'), containsAll(['user1', 'user2']));
      });
    });

    group('unlikePost', () {
      test('decrements like count and removes user from likedBy', () async {
        final docRef = await createPost(
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
        final docRef = await createPost(
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

      test('handles concurrent unlikes correctly', () async {
        final docRef = await createPost(
          content: 'Popular post',
          likeCount: 3,
          likedBy: const ['user1', 'user2', 'user3'],
        );

        await Future.wait([
          repository.unlikePost(docRef.id, 'user1'),
          repository.unlikePost(docRef.id, 'user2'),
        ]);

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user3']);
      });

      test('ignores duplicate concurrent unlikes', () async {
        final docRef = await createPost(
          content: 'Repeated unlike teen',
          likeCount: 1,
          likedBy: const ['user42'],
        );

        await Future.wait([
          repository.unlikePost(docRef.id, 'user42'),
          repository.unlikePost(docRef.id, 'user42'),
          repository.unlikePost(docRef.id, 'user42'),
        ]);

        final updated = await docRef.get();
        expect(updated.get('likeCount'), 0);
        expect((updated.get('likedBy') as List).isEmpty, true);
      });

      test('throws when unliking non-existent post', () async {
        expect(
          () => repository.unlikePost('missing', 'user42'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('post no longer exists'),
          )),
        );
      });
    });

    group('getPostById', () {
      test('returns null for missing post', () async {
        final post = await repository.getPostById('missing');
        expect(post, isNull);
      });

      test('returns post with transformed data', () async {
        final docRef = await createPost(
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
