class FeedPaginationMarker {

  const FeedPaginationMarker({
    required this.primaryValue,
    required this.createdAtIso,
    required this.lastPostId,
  });
  final Object? primaryValue;
  final String createdAtIso;
  final String lastPostId;
}
