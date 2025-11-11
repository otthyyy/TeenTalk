import 'package:flutter/material.dart';
import '../../../comments/data/models/comment.dart';

class PostSearchDelegate extends SearchDelegate<Post?> {
  final List<Post> posts;

  PostSearchDelegate(this.posts);

  @override
  String get searchFieldLabel => 'Cerca post...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Cerca nei post',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final searchQuery = query.toLowerCase();
    final results = posts.where((post) {
      return post.content.toLowerCase().contains(searchQuery) ||
          post.authorNickname.toLowerCase().contains(searchQuery);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun risultato trovato',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prova con altre parole chiave',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              post.isAnonymous
                  ? 'A'
                  : post.authorNickname[0].toUpperCase(),
            ),
          ),
          title: Text(
            post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${post.isAnonymous ? "Anonymous" : post.authorNickname} • ${_formatDate(post.createdAt)}',
          ),
          onTap: () {
            close(context, post);
          },
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h fa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g fa';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
