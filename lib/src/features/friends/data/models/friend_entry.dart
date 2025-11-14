import 'package:cloud_firestore/cloud_firestore.dart';

class FriendEntry {

  const FriendEntry({
    required this.friendId,
    this.conversationId,
    required this.createdAt,
  });

  factory FriendEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendEntry(
      friendId: doc.id,
      conversationId: data['conversationId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory FriendEntry.fromJson(Map<String, dynamic> json) {
    return FriendEntry(
      friendId: json['friendId'] as String,
      conversationId: json['conversationId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  final String friendId;
  final String? conversationId;
  final DateTime createdAt;

  FriendEntry copyWith({
    String? friendId,
    String? conversationId,
    DateTime? createdAt,
  }) {
    return FriendEntry(
      friendId: friendId ?? this.friendId,
      conversationId: conversationId ?? this.conversationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'conversationId': conversationId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
