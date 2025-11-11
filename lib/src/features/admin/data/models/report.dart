class Report {
  final String id;
  final String itemId;
  final String itemType;
  final String authorId;
  final String authorNickname;
  final String content;
  final String reason;
  final String status;
  final String? severity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Report({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.authorId,
    required this.authorNickname,
    required this.content,
    required this.reason,
    required this.status,
    this.severity,
    required this.createdAt,
    required this.updatedAt,
  });

  Report copyWith({
    String? id,
    String? itemId,
    String? itemType,
    String? authorId,
    String? authorNickname,
    String? content,
    String? reason,
    String? status,
    String? severity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      authorId: authorId ?? this.authorId,
      authorNickname: authorNickname ?? this.authorNickname,
      content: content ?? this.content,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String,
      authorId: json['authorId'] as String,
      authorNickname: json['authorNickname'] as String,
      content: json['content'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String? ?? 'pending',
      severity: json['severity'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemType': itemType,
        'authorId': authorId,
        'authorNickname': authorNickname,
        'content': content,
        'reason': reason,
        'status': status,
        'severity': severity,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
  }

class ModerationDecision {
  final String id;
  final String reportId;
  final String moderatorId;
  final String decision;
  final String? notes;
  final DateTime createdAt;

  const ModerationDecision({
    required this.id,
    required this.reportId,
    required this.moderatorId,
    required this.decision,
    this.notes,
    required this.createdAt,
  });

  factory ModerationDecision.fromJson(Map<String, dynamic> json) {
    return ModerationDecision(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      moderatorId: json['moderatorId'] as String,
      decision: json['decision'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportId': reportId,
    'moderatorId': moderatorId,
    'decision': decision,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
}

class AdminAnalytics {
  final int activeReportCount;
  final int flaggedPostCount;
  final int flaggedCommentCount;
  final int userBanCount;
  final int resolvedReportCount;
  final int dismissedReportCount;

  const AdminAnalytics({
    required this.activeReportCount,
    required this.flaggedPostCount,
    required this.flaggedCommentCount,
    required this.userBanCount,
    required this.resolvedReportCount,
    required this.dismissedReportCount,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    return AdminAnalytics(
      activeReportCount: json['activeReportCount'] as int? ?? 0,
      flaggedPostCount: json['flaggedPostCount'] as int? ?? 0,
      flaggedCommentCount: json['flaggedCommentCount'] as int? ?? 0,
      userBanCount: json['userBanCount'] as int? ?? 0,
      resolvedReportCount: json['resolvedReportCount'] as int? ?? 0,
      dismissedReportCount: json['dismissedReportCount'] as int? ?? 0,
    );
  }
}
