class ExtendedAnalytics {
  final List<DailyMetric> dailyMetrics;
  final List<SchoolMetric> schoolMetrics;
  final Map<String, int> reportReasons;
  final int totalUsers;
  final int activeUsers;
  final int totalPosts;
  final int totalComments;

  const ExtendedAnalytics({
    required this.dailyMetrics,
    required this.schoolMetrics,
    required this.reportReasons,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPosts,
    required this.totalComments,
  });

  factory ExtendedAnalytics.fromJson(Map<String, dynamic> json) {
    return ExtendedAnalytics(
      dailyMetrics: (json['dailyMetrics'] as List<dynamic>?)
              ?.map((e) => DailyMetric.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      schoolMetrics: (json['schoolMetrics'] as List<dynamic>?)
              ?.map((e) => SchoolMetric.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reportReasons: (json['reportReasons'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      totalPosts: json['totalPosts'] as int? ?? 0,
      totalComments: json['totalComments'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyMetrics': dailyMetrics.map((e) => e.toJson()).toList(),
        'schoolMetrics': schoolMetrics.map((e) => e.toJson()).toList(),
        'reportReasons': reportReasons,
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'totalPosts': totalPosts,
        'totalComments': totalComments,
      };
}

class DailyMetric {
  final DateTime date;
  final int postCount;
  final int commentCount;
  final int reportCount;
  final int activeUserCount;

  const DailyMetric({
    required this.date,
    required this.postCount,
    required this.commentCount,
    required this.reportCount,
    required this.activeUserCount,
  });

  factory DailyMetric.fromJson(Map<String, dynamic> json) {
    return DailyMetric(
      date: DateTime.parse(json['date'] as String),
      postCount: json['postCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
      activeUserCount: json['activeUserCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'postCount': postCount,
        'commentCount': commentCount,
        'reportCount': reportCount,
        'activeUserCount': activeUserCount,
      };
}

class SchoolMetric {
  final String schoolName;
  final int userCount;
  final int postCount;
  final int reportCount;

  const SchoolMetric({
    required this.schoolName,
    required this.userCount,
    required this.postCount,
    required this.reportCount,
  });

  factory SchoolMetric.fromJson(Map<String, dynamic> json) {
    return SchoolMetric(
      schoolName: json['schoolName'] as String,
      userCount: json['userCount'] as int? ?? 0,
      postCount: json['postCount'] as int? ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'schoolName': schoolName,
        'userCount': userCount,
        'postCount': postCount,
        'reportCount': reportCount,
      };
}

class AnalyticsFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? school;

  const AnalyticsFilter({
    this.startDate,
    this.endDate,
    this.school,
  });

  AnalyticsFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? school,
  }) {
    return AnalyticsFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      school: school ?? this.school,
    );
  }

  Map<String, dynamic> toJson() => {
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (school != null) 'school': school,
      };
}
