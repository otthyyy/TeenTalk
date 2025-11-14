import 'package:logger/logger.dart';

enum ContentType {
  post,
  comment,
}

class RateLimitConfig {
  
  const RateLimitConfig({
    required this.maxPerMinute,
    required this.maxPerHour,
  });
  final int maxPerMinute;
  final int maxPerHour;
  
  static const post = RateLimitConfig(
    maxPerMinute: 5,
    maxPerHour: 20,
  );
  
  static const comment = RateLimitConfig(
    maxPerMinute: 10,
    maxPerHour: 50,
  );
}

class RateLimitStatus {
  
  const RateLimitStatus({
    required this.canSubmit,
    required this.remainingPerMinute,
    required this.remainingPerHour,
    this.cooldownDuration,
    this.reason,
  });
  final bool canSubmit;
  final int remainingPerMinute;
  final int remainingPerHour;
  final Duration? cooldownDuration;
  final String? reason;
  
  bool get isNearLimit => remainingPerMinute <= 2 || remainingPerHour <= 5;
}

class RateLimitService {
  final Logger _logger = Logger();
  final Map<ContentType, List<DateTime>> _submissions = {
    ContentType.post: [],
    ContentType.comment: [],
  };
  
  RateLimitConfig getConfig(ContentType type) {
    return type == ContentType.post ? RateLimitConfig.post : RateLimitConfig.comment;
  }

  RateLimitStatus checkLimit(ContentType type) {
    final config = getConfig(type);
    
    final now = DateTime.now();
    final submissions = _submissions[type] ?? [];
    
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    final recentMinute = submissions
        .where((time) => time.isAfter(oneMinuteAgo))
        .toList();
    final recentHour = submissions
        .where((time) => time.isAfter(oneHourAgo))
        .toList();
    
    _submissions[type] = recentHour;
    
    final remainingPerMinute = (config.maxPerMinute - recentMinute.length).clamp(0, config.maxPerMinute);
    final remainingPerHour = (config.maxPerHour - recentHour.length).clamp(0, config.maxPerHour);
    
    if (recentMinute.length >= config.maxPerMinute) {
      final oldestInMinute = recentMinute.reduce((a, b) => a.isBefore(b) ? a : b);
      final cooldown = oldestInMinute.add(const Duration(minutes: 1)).difference(now);
      
      return RateLimitStatus(
        canSubmit: false,
        remainingPerMinute: 0,
        remainingPerHour: remainingPerHour,
        cooldownDuration: cooldown,
        reason: 'minute_limit',
      );
    }
    
    if (recentHour.length >= config.maxPerHour) {
      final oldestInHour = recentHour.reduce((a, b) => a.isBefore(b) ? a : b);
      final cooldown = oldestInHour.add(const Duration(hours: 1)).difference(now);
      
      return RateLimitStatus(
        canSubmit: false,
        remainingPerMinute: remainingPerMinute,
        remainingPerHour: 0,
        cooldownDuration: cooldown,
        reason: 'hour_limit',
      );
    }
    
    return RateLimitStatus(
      canSubmit: true,
      remainingPerMinute: remainingPerMinute,
      remainingPerHour: remainingPerHour,
    );
  }
  
  void recordSubmission(ContentType type) {
    final submissions = _submissions[type] ?? [];
    submissions.add(DateTime.now());
    _submissions[type] = submissions;
    
    _logger.d('Recorded ${type.name} submission. Total in memory: ${submissions.length}');
  }
  
  void clearHistory(ContentType type) {
    _submissions[type] = [];
    _logger.i('Cleared ${type.name} submission history');
  }
  
  void clearAllHistory() {
    _submissions.clear();
    _logger.i('Cleared all submission history');
  }
  
  int getSubmissionCount(ContentType type, Duration window) {
    final now = DateTime.now();
    final cutoff = now.subtract(window);
    final submissions = _submissions[type] ?? [];
    
    return submissions.where((time) => time.isAfter(cutoff)).length;
  }
}
