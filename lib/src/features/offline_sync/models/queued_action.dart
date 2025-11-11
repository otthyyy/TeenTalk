import 'package:hive/hive.dart';

part 'queued_action.g.dart';

enum QueuedActionType {
  post,
  comment,
  directMessage,
}

enum QueuedActionStatus {
  pending,
  syncing,
  failed,
  completed,
}

@HiveType(typeId: 0)
class QueuedAction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final QueuedActionType type;

  @HiveField(2)
  QueuedActionStatus status;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime? lastAttemptAt;

  @HiveField(6)
  int retryCount;

  @HiveField(7)
  String? errorMessage;

  @HiveField(8)
  DateTime? completedAt;

  QueuedAction({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.status = QueuedActionStatus.pending,
    this.lastAttemptAt,
    this.retryCount = 0,
    this.errorMessage,
    this.completedAt,
  });

  bool get canRetry => retryCount < 3 && status == QueuedActionStatus.failed;
  bool get isPending => status == QueuedActionStatus.pending;
  bool get isSyncing => status == QueuedActionStatus.syncing;
  bool get isCompleted => status == QueuedActionStatus.completed;
  bool get hasFailed => status == QueuedActionStatus.failed;

  void markAsSyncing() {
    status = QueuedActionStatus.syncing;
    lastAttemptAt = DateTime.now();
  }

  void markAsCompleted() {
    status = QueuedActionStatus.completed;
    completedAt = DateTime.now();
  }

  void markAsFailed(String error) {
    status = QueuedActionStatus.failed;
    errorMessage = error;
    retryCount++;
  }

  void resetForRetry() {
    status = QueuedActionStatus.pending;
    errorMessage = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory QueuedAction.fromJson(Map<String, dynamic> json) {
    return QueuedAction(
      id: json['id'] as String,
      type: QueuedActionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      status: QueuedActionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QueuedActionStatus.pending,
      ),
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      retryCount: json['retryCount'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
