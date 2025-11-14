import 'package:hive/hive.dart';

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
}

class QueuedActionAdapter extends TypeAdapter<QueuedAction> {
  @override
  final int typeId = 0;

  @override
  QueuedAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final fieldKey = reader.readByte();
      fields[fieldKey] = reader.read();
    }

    final rawData = fields[3] as Map<dynamic, dynamic>?;
    final data = rawData != null
        ? rawData.map((key, value) => MapEntry(key as String, value))
        : <String, dynamic>{};

    return QueuedAction(
      id: fields[0] as String,
      type: fields[1] as QueuedActionType? ?? QueuedActionType.post,
      status: fields[2] as QueuedActionStatus? ?? QueuedActionStatus.pending,
      data: data,
      createdAt: fields[4] as DateTime,
      lastAttemptAt: fields[5] as DateTime?,
      retryCount: fields[6] as int? ?? 0,
      errorMessage: fields[7] as String?,
      completedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QueuedAction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastAttemptAt)
      ..writeByte(6)
      ..write(obj.retryCount)
      ..writeByte(7)
      ..write(obj.errorMessage)
      ..writeByte(8)
      ..write(obj.completedAt);
  }
}

class QueuedActionTypeAdapter extends TypeAdapter<QueuedActionType> {
  @override
  final int typeId = 1;

  @override
  QueuedActionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QueuedActionType.post;
      case 1:
        return QueuedActionType.comment;
      case 2:
        return QueuedActionType.directMessage;
      default:
        return QueuedActionType.post;
    }
  }

  @override
  void write(BinaryWriter writer, QueuedActionType obj) {
    writer.writeByte(obj.index);
  }
}

class QueuedActionStatusAdapter extends TypeAdapter<QueuedActionStatus> {
  @override
  final int typeId = 2;

  @override
  QueuedActionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QueuedActionStatus.pending;
      case 1:
        return QueuedActionStatus.syncing;
      case 2:
        return QueuedActionStatus.failed;
      case 3:
        return QueuedActionStatus.completed;
      default:
        return QueuedActionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, QueuedActionStatus obj) {
    writer.writeByte(obj.index);
  }
}
