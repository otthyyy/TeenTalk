import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/presentation/widgets/comment_widget.dart';

void main() {
  group('CommentWidget Tests', () {
    testWidgets('displays comment information correctly', (WidgetTester tester) async {
      final comment = Comment(
        id: '1',
        postId: 'post1',
        authorId: 'user1',
        authorNickname: 'TestUser',
        isAnonymous: false,
        content: 'This is a test comment',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        likeCount: 5,
        likedBy: ['user1', 'user2', 'user3', 'user4', 'user5'],
        mentionedUserIds: ['mentionedUser'],
        replyCount: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentWidget(
              comment: comment,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Check if author name is displayed
      expect(find.text('TestUser'), findsOneWidget);
      
      // Check if comment content is displayed
      expect(find.text('This is a test comment'), findsOneWidget);
      
      // Check if like count is displayed
      expect(find.text('5'), findsOneWidget);
      
      // Check if reply count is displayed
      expect(find.text('3'), findsOneWidget);
      
      // Check if mentioned user is displayed
      expect(find.text('@mentionedUser'), findsOneWidget);
      
      // Check if timestamp is displayed
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('displays anonymous comment correctly', (WidgetTester tester) async {
      final comment = Comment(
        id: '1',
        postId: 'post1',
        authorId: 'user1',
        authorNickname: 'TestUser',
        isAnonymous: true,
        content: 'This is an anonymous comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentWidget(
              comment: comment,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Check if 'Anonymous' is displayed instead of author name
      expect(find.text('Anonymous'), findsOneWidget);
      expect(find.text('TestUser'), findsNothing);
      
      // Check if anonymous icon is displayed
      expect(find.byIcon(Icons.person_off), findsOneWidget);
    });

    testWidgets('like button toggles correctly', (WidgetTester tester) async {
      bool likeCalled = false;
      bool unlikeCalled = false;

      final comment = Comment(
        id: '1',
        postId: 'post1',
        authorId: 'user2',
        authorNickname: 'TestUser',
        isAnonymous: false,
        content: 'Test comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        likedBy: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentWidget(
              comment: comment,
              currentUserId: 'user1',
              onLike: () => likeCalled = true,
              onUnlike: () => unlikeCalled = true,
            ),
          ),
        ),
      );

      // Initially should show unfilled heart
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap like button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(likeCalled, isTrue);
      expect(unlikeCalled, isFalse);

      // Reset for unlike test
      likeCalled = false;
      final likedComment = comment.copyWith(
        likeCount: 1,
        likedBy: ['user1'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentWidget(
              comment: likedComment,
              currentUserId: 'user1',
              onLike: () => likeCalled = true,
              onUnlike: () => unlikeCalled = true,
            ),
          ),
        ),
      );

      // Should show filled heart
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      // Tap unlike button
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      expect(unlikeCalled, isTrue);
      expect(likeCalled, isFalse);
    });

    testWidgets('reply button calls onReply callback', (WidgetTester tester) async {
      bool replyCalled = false;

      final comment = Comment(
        id: '1',
        postId: 'post1',
        authorId: 'user2',
        authorNickname: 'TestUser',
        isAnonymous: false,
        content: 'Test comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentWidget(
              comment: comment,
              currentUserId: 'user1',
              onReply: () => replyCalled = true,
            ),
          ),
        ),
      );

      // Tap reply button
      await tester.tap(find.text('Reply'));
      await tester.pump();

      expect(replyCalled, isTrue);
    });

    testWidgets('report menu shows report option', (WidgetTester tester) async {
      final comment = Comment(
        id: '1',
        postId: 'post1',
        authorId: 'user2',
        authorNickname: 'TestUser',
        isAnonymous: false,
        content: 'Test comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentWidget(
              comment: comment,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Tap menu button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Check if report option is available
      expect(find.text('Report'), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });
  });
}