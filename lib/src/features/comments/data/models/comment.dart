class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorNickname;
  final bool isAnonymous;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final List<String> likedBy;
  final List<String> mentionedUserIds;
  final bool isModerated;
  final String? replyToCommentId;
  final int replyCount;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorNickname,
    required this.isAnonymous,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.likedBy = const [],
    this.mentionedUserIds = const [],
    this.isModerated = false,
    this.replyToCommentId,
    this.replyCount = 0,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorNickname,
    bool? isAnonymous,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    List<String>? likedBy,
    List<String>? mentionedUserIds,
    bool? isModerated,
    String? replyToCommentId,
    int? replyCount,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorNickname: authorNickname ?? this.authorNickname,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      isModerated: isModerated ?? this.isModerated,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      replyCount: replyCount ?? this.replyCount,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      authorNickname: json['authorNickname'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      likedBy: List<String>.from(json['likedBy'] as List? ?? []),
      mentionedUserIds: List<String>.from(json['mentionedUserIds'] as List? ?? []),
      isModerated: json['isModerated'] as bool? ?? false,
      replyToCommentId: json['replyToCommentId'] as String?,
      replyCount: json['replyCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'authorId': authorId,
    'authorNickname': authorNickname,
    'isAnonymous': isAnonymous,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'likeCount': likeCount,
    'likedBy': likedBy,
    'mentionedUserIds': mentionedUserIds,
    'isModerated': isModerated,
    'replyToCommentId': replyToCommentId,
    'replyCount': replyCount,
  };
}

class Post {
  final String id;
  final String authorId;
  final String authorNickname;
  final bool isAnonymous;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final List<String> likedBy;
  final int commentCount;
  final List<String> mentionedUserIds;
  final bool isModerated;
  final String section;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorNickname,
    required this.isAnonymous,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    this.mentionedUserIds = const [],
    this.isModerated = false,
    this.section = 'spotted',
  });

  Post copyWith({
    String? id,
    String? authorId,
    String? authorNickname,
    bool? isAnonymous,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    List<String>? likedBy,
    int? commentCount,
    List<String>? mentionedUserIds,
    bool? isModerated,
    String? section,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorNickname: authorNickname ?? this.authorNickname,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      isModerated: isModerated ?? this.isModerated,
      section: section ?? this.section,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorNickname: json['authorNickname'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      likedBy: List<String>.from(json['likedBy'] as List? ?? []),
      commentCount: json['commentCount'] as int? ?? 0,
      mentionedUserIds: List<String>.from(json['mentionedUserIds'] as List? ?? []),
      isModerated: json['isModerated'] as bool? ?? false,
      section: json['section'] as String? ?? 'spotted',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'authorNickname': authorNickname,
    'isAnonymous': isAnonymous,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'likeCount': likeCount,
    'likedBy': likedBy,
    'commentCount': commentCount,
    'mentionedUserIds': mentionedUserIds,
    'isModerated': isModerated,
    'section': section,
  };
}