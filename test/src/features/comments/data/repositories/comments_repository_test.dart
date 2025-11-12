import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment_failure.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/comments_repository.dart';

void main() {
  group('CommentsRepository', () {
    late FakeFirebaseFirestore firestore;
    late CommentsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = CommentsRepository(firestore: firestore);
    });

    Future<void> _createPost(String postId, {int commentCount = 0}) async {
      await firestore.collection('posts').doc(postId).set({
        'authorId': 'author1',
        'authorNickname': 'Author',
        'content': 'Post content',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'commentCount': commentCount,
      });
    }

    group('createComment', () {
      test('stores mentions and increments post comment count', () async {
        await _createPost('post1');

        final comment = await repository.createComment(
          postId: 'post1',
          authorId: 'commenter',
          authorNickname: 'Commenter',
          isAnonymous: false,
          content: 'Hello @friend1 and @friend2',
          school: 'Test School',
        );

        expect(comment.mentionedUserIds, ['friend1', 'friend2']);

        final stored = await firestore.collection('comments').doc(comment.id).get();
        expect(stored.get('mentionedUserIds'), ['friend1', 'friend2']);

        final post = await firestore.collection('posts').doc('post1').get();
        expect(post.get('commentCount'), 1);
      });

      test('increments reply count when replying to comment', () async {
        await _createPost('post1', commentCount: 1);

        final parent = await repository.createComment(
          postId: 'post1',
          authorId: 'parent',
          authorNickname: 'Parent',
          isAnonymous: false,
          content: 'Parent comment',
          school: 'Test School',
        );

        final reply = await repository.createComment(
          postId: 'post1',
          authorId: 'child',
          authorNickname: 'Child',
          isAnonymous: false,
          content: 'Reply comment',
          school: 'Test School',
          replyToCommentId: parent.id,
        );

        final parentDoc = await firestore.collection('comments').doc(parent.id).get();
        expect(parentDoc.get('replyCount'), 1);

        final post = await firestore.collection('posts').doc('post1').get();
        expect(post.get('commentCount'), 2);
        expect(reply.replyToCommentId, parent.id);
      });
    });

    group('getCommentsByPostId', () {
      test('returns only active comments for a post', () async {
        await _createPost('post1');
        final active = await repository.createComment(
          postId: 'post1',
          authorId: 'user1',
          authorNickname: 'User1',
          isAnonymous: false,
          content: 'Active comment',
          school: 'Test School',
        );
        final moderated = await repository.createComment(
          postId: 'post1',
          authorId: 'user2',
          authorNickname: 'User2',
          isAnonymous: false,
          content: 'Moderated comment',
          school: 'Test School',
        );

        await firestore.collection('comments').doc(moderated.id).update({
          'isModerated': true,
        });

        final (comments, lastDoc) = await repository.getCommentsByPostId(postId: 'post1');

        expect(comments.length, 1);
        expect(comments.first.id, active.id);
        expect(lastDoc, isNotNull);
      });
    });

    group('getRepliesForComment', () {
      test('returns only replies for the given comment', () async {
        await _createPost('post1');
        final parent = await repository.createComment(
          postId: 'post1',
          authorId: 'parent',
          authorNickname: 'Parent',
          isAnonymous: false,
          content: 'Parent',
          school: 'Test School',
        );

        final reply1 = await repository.createComment(
          postId: 'post1',
          authorId: 'child1',
          authorNickname: 'Child1',
          isAnonymous: false,
          content: 'Reply 1',
          school: 'Test School',
          replyToCommentId: parent.id,
        );
        await repository.createComment(
          postId: 'post1',
          authorId: 'child2',
          authorNickname: 'Child2',
          isAnonymous: false,
          content: 'Other comment',
          school: 'Test School',
        );

        final replies = await repository.getRepliesForComment(commentId: parent.id);

        expect(replies.length, 1);
        expect(replies.first.id, reply1.id);
      });
    });

    group('likeComment / unlikeComment', () {
      test('likeComment increments like count and stores user', () async {
        await _createPost('post1');
        final comment = await repository.createComment(
          postId: 'post1',
          authorId: 'author',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Like me',
          school: 'Test School',
        );

        await repository.likeComment(comment.id, 'user42');

        final updated = await firestore.collection('comments').doc(comment.id).get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user42']);
      });

      test('likeComment does not duplicate likes', () async {
        await _createPost('post1');
        final comment = await repository.createComment(
          postId: 'post1',
          authorId: 'author',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Like me',
          school: 'Test School',
        );

        await repository.likeComment(comment.id, 'user42');
        await repository.likeComment(comment.id, 'user42');

        final updated = await firestore.collection('comments').doc(comment.id).get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user42']);
      });

      test('unlikeComment decrements like count and removes user', () async {
        await _createPost('post1');
        final comment = await repository.createComment(
          postId: 'post1',
          authorId: 'author',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Unlike me',
          school: 'Test School',
        );

        await repository.likeComment(comment.id, 'user42');
        await repository.likeComment(comment.id, 'user99');
        await repository.unlikeComment(comment.id, 'user42');

        final updated = await firestore.collection('comments').doc(comment.id).get();
        expect(updated.get('likeCount'), 1);
        expect(updated.get('likedBy'), ['user99']);
      });

      test('unlikeComment does not go below zero', () async {
        await _createPost('post1');
        final comment = await repository.createComment(
          postId: 'post1',
          authorId: 'author',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Never negative',
          school: 'Test School',
        );

        await repository.unlikeComment(comment.id, 'user42');

        final updated = await firestore.collection('comments').doc(comment.id).get();
        expect(updated.get('likeCount'), 0);
        expect((updated.get('likedBy') as List).isEmpty, true);
      });
    });

    group('deleteComment', () {
      test('decrements post comment count and removes comment', () async {
        await _createPost('post1');
        final comment = await repository.createComment(
          postId: 'post1',
          authorId: 'author',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Remove me',
          school: 'Test School',
        );

        await repository.deleteComment(comment.id);

        final post = await firestore.collection('posts').doc('post1').get();
        expect(post.get('commentCount'), 0);

        final deleted = await firestore.collection('comments').doc(comment.id).get();
        expect(deleted.exists, false);
      });

      test('decrements reply count when deleting reply', () async {
        await _createPost('post1', commentCount: 2);
        final parent = await repository.createComment(
          postId: 'post1',
          authorId: 'parent',
          authorNickname: 'Parent',
          isAnonymous: false,
          content: 'Parent comment',
          school: 'Test School',
        );
        final reply = await repository.createComment(
          postId: 'post1',
          authorId: 'child',
          authorNickname: 'Child',
          isAnonymous: false,
          content: 'Reply comment',
          school: 'Test School',
          replyToCommentId: parent.id,
        );

        await repository.deleteComment(reply.id);

        final parentDoc = await firestore.collection('comments').doc(parent.id).get();
        expect(parentDoc.get('replyCount'), 0);

        final post = await firestore.collection('posts').doc('post1').get();
        expect(post.get('commentCount'), 1);
      });
    });

    group('error handling', () {
      test('createComment throws CommentFailure when post does not exist', () async {
        expect(
          () => repository.createComment(
            postId: 'nonexistent',
            authorId: 'user1',
            authorNickname: 'User1',
            isAnonymous: false,
            content: 'Test',
            school: 'Test School',
          ),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.notFound,
          )),
        );
      });

      test('createComment throws CommentFailure with empty content', () async {
        await _createPost('post1');

        expect(
          () => repository.createComment(
            postId: 'post1',
            authorId: 'user1',
            authorNickname: 'User1',
            isAnonymous: false,
            content: '  ',
            school: 'Test School',
          ),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.invalidData,
          )),
        );
      });

      test('createComment throws CommentFailure when replying to nonexistent comment', () async {
        await _createPost('post1');

        expect(
          () => repository.createComment(
            postId: 'post1',
            authorId: 'user1',
            authorNickname: 'User1',
            isAnonymous: false,
            content: 'Reply',
            school: 'Test School',
            replyToCommentId: 'nonexistent',
          ),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.notFound,
          )),
        );
      });

      test('deleteComment throws CommentFailure for nonexistent comment', () async {
        expect(
          () => repository.deleteComment('nonexistent'),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.notFound,
          )),
        );
      });

      test('likeComment throws CommentFailure for nonexistent comment', () async {
        expect(
          () => repository.likeComment('nonexistent', 'user1'),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.notFound,
          )),
        );
      });

      test('unlikeComment throws CommentFailure for nonexistent comment', () async {
        expect(
          () => repository.unlikeComment('nonexistent', 'user1'),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.notFound,
          )),
        );
      });

      test('updateComment throws CommentFailure with empty content', () async {
        expect(
          () => repository.updateComment(
            commentId: 'comment1',
            content: '  ',
          ),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.invalidData,
          )),
        );
      });

      test('reportComment throws CommentFailure with empty reason', () async {
        expect(
          () => repository.reportComment('comment1', '  '),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.invalidData,
          )),
        );
      });

      test('reportComment throws CommentFailure for nonexistent comment', () async {
        expect(
          () => repository.reportComment('nonexistent', 'spam'),
          throwsA(isA<CommentFailure>().having(
            (e) => e.type,
            'type',
            CommentFailureType.notFound,
          )),
        );
      });
    });
  });
}
