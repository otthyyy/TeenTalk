import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';
import '../../../comments/data/services/notification_service.dart';

class NotificationsRepository {
  final NotificationService _notificationService;

  NotificationsRepository(this._notificationService);

  Stream<List<AppNotification>> watchAll(String userId) {
    return _notificationService
        .getNotificationsStream(userId)
        .map(_mapSnapshotToNotifications);
  }

  Stream<List<AppNotification>> watchUnread(String userId) {
    return _notificationService
        .getUnreadNotificationsStream(userId)
        .map(_mapSnapshotToNotifications);
  }

  Future<void> markAsRead(String notificationId) {
    return _notificationService.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) {
    return _notificationService.markAllNotificationsAsRead(userId);
  }

  List<AppNotification> _mapSnapshotToNotifications(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => AppNotification.fromFirestore(doc))
        .toList();
  }
}
