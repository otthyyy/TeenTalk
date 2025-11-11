class FeedPaginationMarker {
  final Object? primaryValue;
  final String createdAtIso;
  final String lastPostId;

  const FeedPaginationMarker({
    required this.primaryValue,
    required this.createdAtIso,
    required this.lastPostId,
  });
}
