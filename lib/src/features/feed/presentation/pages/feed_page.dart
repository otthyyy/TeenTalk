import 'package:flutter/material.dart';
import 'feed_sections_page.dart';

class FeedPage extends StatelessWidget {
  final String? openCommentsForPost;
  
  const FeedPage({
    super.key,
    this.openCommentsForPost,
  });

  @override
  Widget build(BuildContext context) {
    return FeedSectionsPage(
      openCommentsForPost: openCommentsForPost,
    );
  }
}
