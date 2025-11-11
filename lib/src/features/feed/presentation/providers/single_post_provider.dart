import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../comments/data/models/comment.dart';
import '../../../comments/data/repositories/posts_repository.dart';
import '../../../comments/presentation/providers/comments_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

final singlePostProvider = FutureProvider.family<Post?, String>((ref, postId) async {
  final repository = ref.read(postsRepositoryProvider);
  return repository.getPostById(postId);
});

final singlePostWithSchoolCheckProvider = FutureProvider.family<SinglePostResult, String>((ref, postId) async {
  final repository = ref.read(postsRepositoryProvider);
  final userProfile = await ref.watch(userProfileProvider.future);
  
  final post = await repository.getPostById(postId);
  
  if (post == null) {
    return SinglePostResult(
      post: null,
      error: 'Post not found or has been deleted',
    );
  }
  
  if (userProfile?.school != null && 
      post.school != null && 
      post.school != userProfile?.school) {
    return SinglePostResult(
      post: null,
      error: 'This post is from a different school',
    );
  }
  
  return SinglePostResult(post: post, error: null);
});

class SinglePostResult {
  final Post? post;
  final String? error;

  SinglePostResult({
    required this.post,
    required this.error,
  });
}
