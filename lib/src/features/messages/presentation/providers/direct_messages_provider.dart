import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/direct_message.dart';
import '../../data/models/conversation.dart';
import '../../data/repositories/direct_messages_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user?.uid,
    orElse: () => ref.read(firebaseAuthServiceProvider).currentUser?.uid,
  );
});

// Get conversations for current user
final conversationsProvider = StreamProvider<List<Conversation>>((ref) async* {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return;

  final repository = ref.watch(directMessagesRepositoryProvider);
  yield* repository.watchConversations(currentUserId);
});

// Get messages for a specific conversation
final messagesProvider =
    StreamProvider.family<List<DirectMessage>, String>((ref, conversationId) async* {
  final repository = ref.watch(directMessagesRepositoryProvider);
  yield* repository.watchMessages(conversationId);
});

// Get blocked users for current user
final blockedUsersProvider = FutureProvider<List<String>>((ref) async {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return [];

  final repository = ref.watch(directMessagesRepositoryProvider);
  return repository.getBlockedUsers(currentUserId);
});

// Send message state
final sendMessageProvider =
    StateNotifierProvider<SendMessageNotifier, AsyncValue<void>>((ref) {
  return SendMessageNotifier(ref);
});

class SendMessageNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SendMessageNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String receiverId,
    required String text,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final repository = ref.read(directMessagesRepositoryProvider);
      await repository.sendMessage(
        senderId: currentUserId,
        receiverId: receiverId,
        text: text,
        imageUrl: imageUrl,
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Block user state
final blockUserProvider =
    StateNotifierProvider<BlockUserNotifier, AsyncValue<void>>((ref) {
  return BlockUserNotifier(ref);
});

class BlockUserNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  BlockUserNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> blockUser(String blockedUserId) async {
    state = const AsyncValue.loading();
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final repository = ref.read(directMessagesRepositoryProvider);
      await repository.blockUser(currentUserId, blockedUserId);

      // Refresh blocked users list
      ref.refresh(blockedUsersProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> unblockUser(String blockedUserId) async {
    state = const AsyncValue.loading();
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final repository = ref.read(directMessagesRepositoryProvider);
      await repository.unblockUser(currentUserId, blockedUserId);

      // Refresh blocked users list
      ref.refresh(blockedUsersProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Get unread count
final unreadCountProvider = FutureProvider<int>((ref) async {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return 0;

  final repository = ref.watch(directMessagesRepositoryProvider);
  return repository.getUnreadCount(currentUserId);
});
