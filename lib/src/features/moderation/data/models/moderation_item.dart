import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_report.dart';

enum ModerationStatus {
  active('active'),
  hidden('hidden'),
  removed('removed');

  final String value;
  const ModerationStatus(this.value);

  static ModerationStatus fromString(String value) {
    return ModerationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ModerationStatus.active,
    );
  }
}

class ModerationItem {
  final String contentId;
  final ContentType contentType;
  final String authorId;
  final int reportCount;
  final ModerationStatus status;
  final DateTime? hiddenAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ModerationItem({
    required this.contentId,
    required this.contentType,
    required this.authorId,
    required this.reportCount,
    required this.status,
    this.hiddenAt,
    this.reviewedAt,
    this.reviewedBy,
    this.isAnonymous = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModerationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModerationItem(
      contentId: doc.id,
      contentType: ContentType.fromString(data['contentType'] as String),
      authorId: data['authorId'] as String,
      reportCount: data['reportCount'] as int,
      status: ModerationStatus.fromString(data['status'] as String),
      hiddenAt: data['hiddenAt'] != null 
          ? (data['hiddenAt'] as Timestamp).toDate() 
          : null,
      reviewedAt: data['reviewedAt'] != null 
          ? (data['reviewedAt'] as Timestamp).toDate() 
          : null,
      reviewedBy: data['reviewedBy'] as String?,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'contentType': contentType.value,
      'authorId': authorId,
      'reportCount': reportCount,
      'status': status.value,
      'hiddenAt': hiddenAt != null ? Timestamp.fromDate(hiddenAt!) : null,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ModerationItem copyWith({
    String? contentId,
    ContentType? contentType,
    String? authorId,
    int? reportCount,
    ModerationStatus? status,
    DateTime? hiddenAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModerationItem(
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      authorId: authorId ?? this.authorId,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
