import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/offline_sync/models/queued_action.dart';

void main() {
  group('QueuedAction', () {
    test('should create a queued action', () {
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.post,
        data: {
          'authorId': 'user123',
          'content': 'Test post',
        },
        createdAt: DateTime.now(),
      );

      expect(action.id, 'test-id');
      expect(action.type, QueuedActionType.post);
      expect(action.status, QueuedActionStatus.pending);
      expect(action.data['content'], 'Test post');
    });

    test('should mark action as syncing', () {
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.comment,
        data: {},
        createdAt: DateTime.now(),
      );

      action.markAsSyncing();

      expect(action.status, QueuedActionStatus.syncing);
      expect(action.lastAttemptAt, isNotNull);
    });

    test('should mark action as completed', () {
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.directMessage,
        data: {},
        createdAt: DateTime.now(),
      );

      action.markAsCompleted();

      expect(action.status, QueuedActionStatus.completed);
      expect(action.completedAt, isNotNull);
      expect(action.isCompleted, isTrue);
    });

    test('should mark action as failed', () {
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.post,
        data: {},
        createdAt: DateTime.now(),
      );

      action.markAsFailed('Network error');

      expect(action.status, QueuedActionStatus.failed);
      expect(action.errorMessage, 'Network error');
      expect(action.retryCount, 1);
      expect(action.hasFailed, isTrue);
    });

    test('should allow retry when retry count is less than 3', () {
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.post,
        data: {},
        createdAt: DateTime.now(),
        retryCount: 2,
        status: QueuedActionStatus.failed,
      );

      expect(action.canRetry, isTrue);
    });

    test('should not allow retry when retry count is 3 or more', () {
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.post,
        data: {},
        createdAt: DateTime.now(),
        retryCount: 3,
        status: QueuedActionStatus.failed,
      );

      expect(action.canRetry, isFalse);
    });

    test('should reset action for retry', () {
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.post,
        data: {},
        createdAt: DateTime.now(),
        status: QueuedActionStatus.failed,
        errorMessage: 'Previous error',
        retryCount: 1,
      );

      action.resetForRetry();

      expect(action.status, QueuedActionStatus.pending);
      expect(action.errorMessage, isNull);
      expect(action.retryCount, 1); // Stays same after reset
    });

    test('should serialize to JSON', () {
      final now = DateTime.now();
      final action = QueuedAction(
        id: 'test-id',
        type: QueuedActionType.post,
        data: {'content': 'Test'},
        createdAt: now,
        status: QueuedActionStatus.pending,
      );

      final json = action.toJson();

      expect(json['id'], 'test-id');
      expect(json['type'], 'post');
      expect(json['status'], 'pending');
      expect(json['data']['content'], 'Test');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['retryCount'], 0);
    });

    test('should deserialize from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'type': 'comment',
        'status': 'syncing',
        'data': {'postId': 'post123'},
        'createdAt': now.toIso8601String(),
        'retryCount': 1,
        'errorMessage': 'Test error',
      };

      final action = QueuedAction.fromJson(json);

      expect(action.id, 'test-id');
      expect(action.type, QueuedActionType.comment);
      expect(action.status, QueuedActionStatus.syncing);
      expect(action.data['postId'], 'post123');
      expect(action.retryCount, 1);
      expect(action.errorMessage, 'Test error');
    });
  });
}
