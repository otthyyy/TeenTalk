import 'package:flutter/material.dart';
import 'feed_sections_page.dart';

class FeedPage extends StatelessWidget {
  
  const FeedPage({
    super.key,
    this.openCommentsForPost,
  });
  final String? openCommentsForPost;

  @override
  Widget build(BuildContext context) {
    return FeedSectionsPage(
      openCommentsForPost: openCommentsForPost,
    );
  }
}
