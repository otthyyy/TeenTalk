import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/auth/data/models/auth_user.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:teen_talk_app/src/features/notifications/data/models/app_notification.dart';
import 'package:teen_talk_app/src/features/notifications/data/repositories/notifications_repository.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  group('Notifications providers', () {
    late TestNotificationsRepository repository;
    late AuthUser testUser;

    setUp(() {
      repository = TestNotificationsRepository();
      testUser = AuthUser(
        uid: 'user-123',
        email: 'user@example.com',
        phoneNumber: null,
        displayName: 'Test User',
        photoURL: null,
        emailVerified: true,
        isAnonymous: false,
        createdAt: DateTime.now(),
        authMethods: const ['password'],
      );
    });

    test('notificationsStreamProvider emits repository notifications for authenticated user', () async {
      final notifications = [
        AppNotification(
          id: '1',
          userId: testUser.uid,
          type: NotificationType.commentMention,
          title: 'Mentioned you',
          body: 'Someone mentioned you in a comment',
          data: const {'postId': 'post1'},
          createdAt: DateTime.now(),
          read: false,
        ),
        AppNotification(
          id: '2',
          userId: testUser.uid,
          type: NotificationType.commentReply,
          title: 'New reply',
          body: 'Someone replied to your comment',
          data: const {'commentId': 'comment1'},
          createdAt: DateTime.now(),
          read: true,
        ),
      ];
      repository.stubAllNotifications(notifications);

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          authStateProvider.overrideWith((ref) => _TestAuthStateNotifier(testUser)),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationsStreamProvider.future);

      expect(result.length, notifications.length);
      expect(result.first.title, 'Mentioned you');
    });

    test('unreadNotificationCountProvider reflects unread stream length', () async {
      final unread = [
        AppNotification(
          id: '1',
          userId: testUser.uid,
          type: NotificationType.postMention,
          title: 'Post mention',
          body: 'You were mentioned in a post',
          data: const {},
          createdAt: DateTime.now(),
          read: false,
        ),
        AppNotification(
          id: '2',
          userId: testUser.uid,
          type: NotificationType.general,
          title: 'Welcome',
          body: 'Thanks for joining!',
          data: const {},
          createdAt: DateTime.now(),
          read: false,
        ),
      ];
      repository.stubUnreadNotifications(unread);

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          authStateProvider.overrideWith((ref) => _TestAuthStateNotifier(testUser)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(unreadNotificationsStreamProvider.future);
      final count = container.read(unreadNotificationCountProvider);

      expect(count, unread.length);
    });

    test('notifications actions delegate to repository', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          authStateProvider.overrideWith((ref) => _TestAuthStateNotifier(testUser)),
        ],
      );
      addTearDown(container.dispose);

      final actions = container.read(notificationsActionsProvider);

      await actions.markAsRead('notif-1');
      await actions.markAllAsRead();

      expect(repository.markedAsReadIds, contains('notif-1'));
      expect(repository.markedAllForUser, testUser.uid);
    });

    test('unread stream emits empty list when user is null', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          authStateProvider.overrideWith((ref) => _TestAuthStateNotifier(null)),
        ],
      );
      addTearDown(container.dispose);

      final unread = await container.read(unreadNotificationsStreamProvider.future);

      expect(unread, isEmpty);
      expect(container.read(unreadNotificationCountProvider), 0);
    });
  });

  group('AppNotification model', () {
    test('copyWith updates properties while preserving others', () {
      final original = AppNotification(
        id: '1',
        userId: 'user',
        type: NotificationType.commentMention,
        title: 'Original',
        body: 'Original body',
        data: const {},
        createdAt: DateTime.now(),
        read: false,
      );

      final updated = original.copyWith(read: true, title: 'Updated');

      expect(updated.read, isTrue);
      expect(updated.title, 'Updated');
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
    });

    test('NotificationType.fromString handles unknown gracefully', () {
      expect(NotificationType.fromString('comment_mention'), NotificationType.commentMention);
      expect(NotificationType.fromString('comment_reply'), NotificationType.commentReply);
      expect(NotificationType.fromString('post_mention'), NotificationType.postMention);
      expect(NotificationType.fromString('random'), NotificationType.general);
    });
  });
}

class _TestAuthStateNotifier extends StateNotifier<AuthState> {
  _TestAuthStateNotifier(AuthUser? user)
      : super(AuthState(
          isAuthenticated: user != null,
          isLoading: false,
          error: null,
          user: user,
        ));
}

class TestNotificationsRepository implements NotificationsRepository {
  List<AppNotification> _all = const [];
  List<AppNotification> _unread = const [];
  final List<String> markedAsReadIds = [];
  String? markedAllForUser;

  void stubAllNotifications(List<AppNotification> notifications) {
    _all = notifications;
  }

  void stubUnreadNotifications(List<AppNotification> notifications) {
    _unread = notifications;
  }

  @override
  Stream<List<AppNotification>> watchAll(String userId) {
    return Stream<List<AppNotification>>.value(_all);
  }

  @override
  Stream<List<AppNotification>> watchUnread(String userId) {
    return Stream<List<AppNotification>>.value(_unread);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    markedAsReadIds.add(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    markedAllForUser = userId;
  }
}
