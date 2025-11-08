import 'package:cloud_firestore/cloud_firestore.dart';

class Block {
  final String blockerId;
  final String blockedUserId;
  final DateTime createdAt;

  const Block({
    required this.blockerId,
    required this.blockedUserId,
    required this.createdAt,
  });

  Block copyWith({
    String? blockerId,
    String? blockedUserId,
    DateTime? createdAt,
  }) {
    return Block(
      blockerId: blockerId ?? this.blockerId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Block.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Block(
      blockerId: doc.id,
      blockedUserId: data['blockedUserId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      blockerId: json['blockerId'] as String,
      blockedUserId: json['blockedUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'blockedUserId': blockedUserId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'blockerId': blockerId,
      'blockedUserId': blockedUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
