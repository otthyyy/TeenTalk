enum FeedSortOption {
  newest('newest', 'Newest'),
  mostLiked('most_liked', 'Most Liked'),
  /// Trending relies on Firestore documents containing an `engagementScore`
  /// field, maintained by backend Cloud Functions that weight likes, comments,
  /// and recency.
  trending('trending', 'Trending');

  const FeedSortOption(this.value, this.label);
  final String value;
  final String label;
}

extension FeedSortOptionX on FeedSortOption {
  static FeedSortOption fromStorage(String value) {
    return FeedSortOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => FeedSortOption.newest,
    );
  }

  String get primaryOrderField {
    switch (this) {
      case FeedSortOption.newest:
        return 'createdAt';
      case FeedSortOption.mostLiked:
        return 'likeCount';
      case FeedSortOption.trending:
        return 'engagementScore';
    }
  }

  /// Ties are broken using creation timestamp so the feed remains deterministic.
  String? get secondaryOrderField {
    switch (this) {
      case FeedSortOption.newest:
        return null;
      case FeedSortOption.mostLiked:
        return 'createdAt';
      case FeedSortOption.trending:
        return 'createdAt';
    }
  }

  bool get isDescending => true;
}
