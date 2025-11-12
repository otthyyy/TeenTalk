import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/feed/presentation/pages/post_composer_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:teen_talk_app/src/features/auth/data/models/auth_user.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/features/profile/data/models/user_profile.dart';
import 'package:teen_talk_app/src/core/providers/rate_limit_provider.dart';
import 'package:teen_talk_app/src/core/analytics/analytics_provider.dart';
import 'package:teen_talk_app/src/core/services/rate_limit_service.dart';
import 'package:teen_talk_app/src/core/analytics/analytics_service.dart';
import 'package:teen_talk_app/src/features/offline_sync/services/offline_submission_helper.dart';
import 'package:teen_talk_app/src/features/comments/presentation/providers/comments_provider.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

class _FakeRateLimitService extends Fake implements RateLimitService {
  @override
  RateLimitStatus checkLimit(ContentType contentType) {
    return const RateLimitStatus(
      canSubmit: true,
      remainingPerMinute: 5,
      remainingPerHour: 20,
      cooldownDuration: null,
    );
  }

  @override
  void recordSubmission(ContentType contentType) {}

  @override
  int getSubmissionCount(ContentType contentType, Duration duration) => 0;

  @override
  RateLimitConfig getConfig(ContentType contentType) {
    return const RateLimitConfig(
      maxPerMinute: 5,
      maxPerHour: 20,
      cooldownDuration: Duration(minutes: 5),
    );
  }
}

class _FakeAnalyticsService extends Fake implements AnalyticsService {
  @override
  Future<void> logContentSubmission({
    required String contentType,
    required bool isAnonymous,
  }) async {}

  @override
  Future<void> logRateLimitHit({
    required String contentType,
    required String limitType,
    required int submissionCount,
  }) async {}

  @override
  Future<void> logRateLimitWarning({
    required String contentType,
    required int remainingSubmissions,
  }) async {}
}

class _FakeOfflineSubmissionHelper extends Fake implements OfflineSubmissionHelper {
  @override
  Future<bool> isOnline() async => true;
}

class _FakeAuthNotifier extends StateNotifier<AuthState> {
  _FakeAuthNotifier(AuthState state) : super(state);
}

class _MockPostsRepository extends PostsRepository {
  final Future<void> Function()? onCreatePost;
  final Duration? delay;

  _MockPostsRepository({this.onCreatePost, this.delay})
      : super(
          firestore: FakeFirebaseFirestore(),
          storage: _FakeFirebaseStorage(),
          logger: Logger(level: Level.nothing),
        );

  @override
  Future<Post> createPost({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
    String section = 'spotted',
    String? school,
  }) async {
    if (delay != null) {
      await Future<void>.delayed(delay!);
    }
    if (onCreatePost != null) {
      await onCreatePost!();
    }
    return Post(
      id: 'test-post-id',
      authorId: authorId,
      authorNickname: authorNickname,
      isAnonymous: isAnonymous,
      content: content,
      section: section,
      school: school,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likeCount: 0,
      likedBy: [],
      commentCount: 0,
      mentionedUserIds: [],
      isModerated: false,
      searchKeywords: [],
      imageUrl: imageUrl,
    );
  }

  String? get imageUrl => null;
}

class _FakeFirebaseStorage extends Fake implements FirebaseStorage {}

void main() {
  group('PostComposerPage', () {
    late AuthUser testAuthUser;
    late UserProfile testProfile;

    setUp(() {
      testAuthUser = AuthUser(
        uid: 'test-user-id',
        email: 'test@example.com',
        emailVerified: true,
        isAnonymous: false,
        createdAt: DateTime.now(),
        authMethods: ['password'],
      );
      testProfile = const UserProfile(
        uid: 'test-user-id',
        nickname: 'TestUser',
        school: 'Test School',
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-01-01T00:00:00.000',
      );
    });

    Widget createTestWidget({
      PostsRepository? repository,
    }) {
      return ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => _FakeAuthNotifier(
              AuthState(
                isAuthenticated: true,
                isLoading: false,
                error: null,
                user: testAuthUser,
              ),
            ),
          ),
          userProfileProvider.overrideWith((ref) {
            return AsyncValue.data(testProfile);
          }),
          rateLimitServiceProvider.overrideWith((ref) {
            return _FakeRateLimitService();
          }),
          analyticsServiceProvider.overrideWith((ref) {
            return _FakeAnalyticsService();
          }),
          offlineSubmissionHelperProvider.overrideWith((ref) {
            return _FakeOfflineSubmissionHelper();
          }),
          postRateLimitStatusProvider.overrideWith((ref) {
            return const AsyncValue.data(
              RateLimitStatus(
                canSubmit: true,
                remainingPerMinute: 5,
                remainingPerHour: 20,
                cooldownDuration: null,
              ),
            );
          }),
          if (repository != null)
            postsRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(
          home: PostComposerPage(),
        ),
      );
    }

    testWidgets('Post button is disabled while uploading', (tester) async {
      final repository = _MockPostsRepository(
        delay: const Duration(milliseconds: 500),
      );

      await tester.pumpWidget(createTestWidget(repository: repository));
      await tester.pumpAndSettle();

      final contentField = find.byType(TextFormField);
      expect(contentField, findsOneWidget);

      await tester.enterText(contentField, 'Test post content');
      await tester.pump();

      final postButton = find.widgetWithText(FilledButton, 'Post');
      expect(postButton, findsOneWidget);

      await tester.tap(postButton);
      await tester.pump();

      expect(find.text('Posting...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final buttonWidget = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Posting...'),
      );
      expect(buttonWidget.onPressed, isNull);

      await tester.pumpAndSettle();
    });

    testWidgets('Post button shows progress indicator during submission',
        (tester) async {
      final repository = _MockPostsRepository(
        delay: const Duration(milliseconds: 200),
      );

      await tester.pumpWidget(createTestWidget(repository: repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Test content');
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Post'));
      await tester.pump();

      expect(find.text('Posting...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows success snackbar after post creation', (tester) async {
      final repository = _MockPostsRepository();

      await tester.pumpWidget(createTestWidget(repository: repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Success test');
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Post'));
      await tester.pumpAndSettle();

      expect(find.text('Post created successfully!'), findsOneWidget);
    });

    testWidgets('Post button is enabled when not uploading', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Test content');
      await tester.pump();

      final postButton = find.widgetWithText(FilledButton, 'Post');
      expect(postButton, findsOneWidget);

      final buttonWidget = tester.widget<FilledButton>(postButton);
      expect(buttonWidget.onPressed, isNotNull);
    });
  });
}
