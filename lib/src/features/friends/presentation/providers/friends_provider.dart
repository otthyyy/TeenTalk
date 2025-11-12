import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/friend_request.dart';
import '../../data/models/friend_entry.dart';
import '../../data/models/friendship_status.dart';
import '../../data/repositories/friends_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final friendsCurrentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user?.uid,
    orElse: () => ref.read(firebaseAuthServiceProvider).currentUser?.uid,
  );
});

final incomingFriendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) async* {
  final currentUserId = ref.watch(friendsCurrentUserIdProvider);
  if (currentUserId == null) {
    yield [];
    return;
  }

  final repository = ref.watch(friendsRepositoryProvider);
  yield* repository.watchIncomingRequests(currentUserId);
});

final outgoingFriendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) async* {
  final currentUserId = ref.watch(friendsCurrentUserIdProvider);
  if (currentUserId == null) {
    yield [];
    return;
  }

  final repository = ref.watch(friendsRepositoryProvider);
  yield* repository.watchOutgoingRequests(currentUserId);
});

final friendsListProvider = StreamProvider<List<FriendEntry>>((ref) async* {
  final currentUserId = ref.watch(friendsCurrentUserIdProvider);
  if (currentUserId == null) {
    yield [];
    return;
  }

  final repository = ref.watch(friendsRepositoryProvider);
  yield* repository.watchFriends(currentUserId);
});

final friendshipStatusProvider = FutureProvider.family<FriendshipStatus, String>(
  (ref, otherUserId) async {
    final currentUserId = ref.watch(friendsCurrentUserIdProvider);
    if (currentUserId == null) {
      return FriendshipStatus.none;
    }

    final repository = ref.watch(friendsRepositoryProvider);
    return repository.getFriendshipStatus(currentUserId, otherUserId);
  },
);

final sendFriendRequestProvider = StateNotifierProvider<SendFriendRequestNotifier, AsyncValue<void>>((ref) {
  return SendFriendRequestNotifier(ref);
});

class SendFriendRequestNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SendFriendRequestNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> sendRequest(String toUserId) async {
    state = const AsyncValue.loading();
    try {
      final currentUserId = ref.read(friendsCurrentUserIdProvider);
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final repository = ref.read(friendsRepositoryProvider);
      await repository.sendFriendRequest(currentUserId, toUserId);

      ref.invalidate(friendshipStatusProvider(toUserId));
      ref.invalidate(outgoingFriendRequestsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelRequest(String requestId, String otherUserId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(friendsRepositoryProvider);
      await repository.cancelFriendRequest(requestId);

      ref.invalidate(friendshipStatusProvider(otherUserId));
      ref.invalidate(outgoingFriendRequestsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final respondToFriendRequestProvider = StateNotifierProvider<RespondToFriendRequestNotifier, AsyncValue<void>>((ref) {
  return RespondToFriendRequestNotifier(ref);
});

class RespondToFriendRequestNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  RespondToFriendRequestNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> accept(String requestId, String otherUserId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(friendsRepositoryProvider);
      await repository.acceptFriendRequest(requestId);

      ref.invalidate(friendshipStatusProvider(otherUserId));
      ref.invalidate(incomingFriendRequestsProvider);
      ref.invalidate(friendsListProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> reject(String requestId, String otherUserId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(friendsRepositoryProvider);
      await repository.rejectFriendRequest(requestId);

      ref.invalidate(friendshipStatusProvider(otherUserId));
      ref.invalidate(incomingFriendRequestsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
