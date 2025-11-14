import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {

  const Conversation({
    required this.id,
    required this.userId1,
    required this.userId2,
    List<String>? participantIds,
    this.lastMessageId,
    this.lastMessage,
    this.lastSenderId,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.unreadCounts,
    required this.createdAt,
    this.updatedAt,
  }) : participantIds = participantIds ?? const [];

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final participantIds = data['participantIds'] != null
        ? List<String>.from(data['participantIds'] as List)
        : [data['userId1'] as String, data['userId2'] as String];
    
    final unreadCounts = data['unreadCounts'] != null
        ? Map<String, int>.from(data['unreadCounts'] as Map)
        : null;
    
    return Conversation(
      id: doc.id,
      userId1: data['userId1'] as String,
      userId2: data['userId2'] as String,
      participantIds: participantIds,
      lastMessageId: data['lastMessageId'] as String?,
      lastMessage: data['lastMessage'] as String?,
      lastSenderId: data['lastSenderId'] as String?,
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      unreadCount: data['unreadCount'] as int? ?? 0,
      unreadCounts: unreadCounts,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      userId1: json['userId1'] as String,
      userId2: json['userId2'] as String,
      participantIds: json['participantIds'] != null
          ? List<String>.from(json['participantIds'] as List)
          : [json['userId1'] as String, json['userId2'] as String],
      lastMessageId: json['lastMessageId'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastSenderId: json['lastSenderId'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      unreadCounts: json['unreadCounts'] != null
          ? Map<String, int>.from(json['unreadCounts'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
  final String id;
  final String userId1;
  final String userId2;
  final List<String> participantIds;
  final String? lastMessageId;
  final String? lastMessage;
  final String? lastSenderId;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final Map<String, int>? unreadCounts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Conversation copyWith({
    String? id,
    String? userId1,
    String? userId2,
    List<String>? participantIds,
    String? lastMessageId,
    String? lastMessage,
    String? lastSenderId,
    DateTime? lastMessageTime,
    int? unreadCount,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      participantIds: participantIds ?? this.participantIds,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId1': userId1,
      'userId2': userId2,
      'participantIds': participantIds.isNotEmpty ? participantIds : [userId1, userId2],
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'unreadCount': unreadCount,
      if (unreadCounts != null) 'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'participantIds': participantIds.isNotEmpty ? participantIds : [userId1, userId2],
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      if (unreadCounts != null) 'unreadCounts': unreadCounts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
