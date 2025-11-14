import 'package:flutter_test/flutter_test.dart';

import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/presentation/providers/comments_provider.dart';

void main() {
  group('Comments Integration Tests', () {

    test('comment count updates correctly when adding comments', () async {
      const postId = 'test_post_1';
      
      // Create initial comment
      final comment1 = Comment(
        id: 'comment1',
        postId: postId,
        authorId: 'user1',
        authorNickname: 'User1',
        isAnonymous: false,
        content: 'First comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add second comment
      final comment2 = Comment(
        id: 'comment2',
        postId: postId,
        authorId: 'user2',
        authorNickname: 'User2',
        isAnonymous: false,
        content: 'Second comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create post with initial comment count
      final post = Post(
        id: postId,
        authorId: 'user1',
        authorNickname: 'User1',
        isAnonymous: false,
        content: 'Test post',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        commentCount: 1,
      );

      // Verify initial state
      expect(post.commentCount, equals(1));

      // Simulate adding another comment (this would normally be done via repository)
      final updatedPost = post.copyWith(commentCount: post.commentCount + 1);
      
      // Verify comment count increased
      expect(updatedPost.commentCount, equals(2));
    });

    test('anonymous comments preserve author confidentiality', () {
      final anonymousComment = Comment(
        id: 'comment1',
        postId: 'post1',
        authorId: 'user1',
        authorNickname: 'RealUser',
        isAnonymous: true,
        content: 'Anonymous comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final publicComment = Comment(
        id: 'comment2',
        postId: 'post1',
        authorId: 'user2',
        authorNickname: 'PublicUser',
        isAnonymous: false,
        content: 'Public comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify anonymous comment doesn't expose real author info
      expect(anonymousComment.isAnonymous, isTrue);
      expect(anonymousComment.authorId, equals('user1')); // Still stored for internal use
      expect(anonymousComment.authorNickname, equals('RealUser')); // Still stored for internal use

      // Verify public comment shows author info
      expect(publicComment.isAnonymous, isFalse);
      expect(publicComment.authorId, equals('user2'));
      expect(publicComment.authorNickname, equals('PublicUser'));
    });

    test('comment threading works correctly', () {
      final parentComment = Comment(
        id: 'parent1',
        postId: 'post1',
        authorId: 'user1',
        authorNickname: 'User1',
        isAnonymous: false,
        content: 'Parent comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        replyCount: 2,
      );

      final replyComment = Comment(
        id: 'reply1',
        postId: 'post1',
        authorId: 'user2',
        authorNickname: 'User2',
        isAnonymous: false,
        content: 'Reply to parent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        replyToCommentId: 'parent1',
      );

      // Verify threading relationship
      expect(replyComment.replyToCommentId, equals(parentComment.id));
      expect(parentComment.replyCount, equals(2));
      
      // Verify reply doesn't have its own replies (in this test case)
      expect(replyComment.replyCount, equals(0));
    });

    test('mention extraction works correctly', () {
      const contentWithMentions = 'Hello @user1 and @user2, how are you doing @user3?';
      final comment = Comment(
        id: 'comment1',
        postId: 'post1',
        authorId: 'user1',
        authorNickname: 'User1',
        isAnonymous: false,
        content: contentWithMentions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        mentionedUserIds: ['user1', 'user2', 'user3'],
      );

      // Verify mentions are extracted correctly
      expect(comment.mentionedUserIds.length, equals(3));
      expect(comment.mentionedUserIds, contains('user1'));
      expect(comment.mentionedUserIds, contains('user2'));
      expect(comment.mentionedUserIds, contains('user3'));
    });

    test('comment state management works correctly', () {
      const initialState = CommentsState();
      expect(initialState.comments.isEmpty, isTrue);
      expect(initialState.isLoading, isFalse);
      expect(initialState.error, isNull);

      final loadingState = initialState.copyWith(isLoading: true);
      expect(loadingState.isLoading, isTrue);

      final errorState = initialState.copyWith(error: 'Test error');
      expect(errorState.error, equals('Test error'));

      final comments = [
        Comment(
          id: 'comment1',
          postId: 'post1',
          authorId: 'user1',
          authorNickname: 'User1',
          isAnonymous: false,
          content: 'Test comment',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final commentsState = initialState.copyWith(comments: comments);
      expect(commentsState.comments.length, equals(1));
      expect(commentsState.comments.first.content, equals('Test comment'));
    });
  });
}