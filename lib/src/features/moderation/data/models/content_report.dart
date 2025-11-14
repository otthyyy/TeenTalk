import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_reason.dart';

enum ReportStatus {
  pending('pending'),
  underReview('under_review'),
  resolved('resolved'),
  dismissed('dismissed');

  final String value;
  const ReportStatus(this.value);

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

enum ContentType {
  post('post'),
  comment('comment');

  final String value;
  const ContentType(this.value);

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContentType.post,
    );
  }
}

class ContentReport {

  const ContentReport({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.reporterId,
    required this.contentAuthorId,
    required this.reason,
    this.additionalDetails,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
  });

  factory ContentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentReport(
      id: doc.id,
      contentId: data['contentId'] as String,
      contentType: ContentType.fromString(data['contentType'] as String),
      reporterId: data['reporterId'] as String,
      contentAuthorId: data['contentAuthorId'] as String,
      reason: ReportReason.fromString(data['reason'] as String),
      additionalDetails: data['additionalDetails'] as String?,
      status: ReportStatus.fromString(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null 
          ? (data['resolvedAt'] as Timestamp).toDate() 
          : null,
      resolvedBy: data['resolvedBy'] as String?,
      resolutionNotes: data['resolutionNotes'] as String?,
    );
  }
  final String id;
  final String contentId;
  final ContentType contentType;
  final String reporterId;
  final String contentAuthorId;
  final ReportReason reason;
  final String? additionalDetails;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNotes;

  Map<String, dynamic> toFirestore() {
    return {
      'contentId': contentId,
      'contentType': contentType.value,
      'reporterId': reporterId,
      'contentAuthorId': contentAuthorId,
      'reason': reason.value,
      'additionalDetails': additionalDetails,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolvedBy': resolvedBy,
      'resolutionNotes': resolutionNotes,
    };
  }

  ContentReport copyWith({
    String? id,
    String? contentId,
    ContentType? contentType,
    String? reporterId,
    String? contentAuthorId,
    ReportReason? reason,
    String? additionalDetails,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNotes,
  }) {
    return ContentReport(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      reporterId: reporterId ?? this.reporterId,
      contentAuthorId: contentAuthorId ?? this.contentAuthorId,
      reason: reason ?? this.reason,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}
