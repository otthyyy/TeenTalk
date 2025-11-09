import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../../comments/data/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationsServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final notificationService = ref.watch(notificationsServiceProvider);
  return NotificationsRepository(notificationService);
});

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.uid;
  
  if (userId == null) {
    return Stream<List<AppNotification>>.value(const []);
  }
  
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.watchAll(userId);
});

final unreadNotificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.uid;
  
  if (userId == null) {
    return Stream<List<AppNotification>>.value(const []);
  }
  
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.watchUnread(userId);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final unreadNotifications = ref.watch(unreadNotificationsStreamProvider);
  return unreadNotifications.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final notificationsActionsProvider = Provider<NotificationsActions>((ref) {
  return NotificationsActions(ref);
});

class NotificationsActions {
  final Ref _ref;

  NotificationsActions(this._ref);

  Future<void> markAsRead(String notificationId) async {
    final repository = _ref.read(notificationsRepositoryProvider);
    await repository.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    final authState = _ref.read(authStateProvider);
    final userId = authState.user?.uid;
    
    if (userId == null) return;
    
    final repository = _ref.read(notificationsRepositoryProvider);
    await repository.markAllAsRead(userId);
  }
}
