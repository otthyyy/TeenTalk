import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../messages/presentation/providers/direct_messages_provider.dart';
import '../../../profile/data/repositories/user_repository.dart';
import '../../../profile/domain/models/user_profile.dart';

final _likerProfilesCacheProvider =
    StateNotifierProvider<_LikerProfilesCache, Map<String, UserProfile?>>(
  (ref) => _LikerProfilesCache(),
);

class _LikerProfilesCache extends StateNotifier<Map<String, UserProfile?>> {
  _LikerProfilesCache() : super(const {});

  void updateCache(Map<String, UserProfile?> entries) {
    if (entries.isEmpty) return;
    state = {...state, ...entries};
  }
}

final likerProfilesProvider =
    FutureProvider.family<List<UserProfile>, List<String>>((ref, likerIds) async {
  if (likerIds.isEmpty) {
    return [];
  }

  final uniqueLikerIds = likerIds.toSet().toList();

  final cache = ref.watch(_likerProfilesCacheProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final blockedUsersAsync = ref.watch(blockedUsersProvider);
  final blockedUsers = await blockedUsersAsync.future;
  final blockedSet = blockedUsers.toSet();

  final idsToFetch = uniqueLikerIds.where((id) => !cache.containsKey(id)).toList();
  final fetchedEntries = <String, UserProfile?>{};

  if (idsToFetch.isNotEmpty) {
    final fetchedProfiles = await Future.wait(
      idsToFetch.map((id) => userRepository.getUserProfile(id)),
    );

    for (var i = 0; i < idsToFetch.length; i++) {
      fetchedEntries[idsToFetch[i]] = fetchedProfiles[i];
    }

    ref.read(_likerProfilesCacheProvider.notifier).updateCache(fetchedEntries);
  }

  final mergedCache = {...cache, ...fetchedEntries};

  final profiles = uniqueLikerIds
      .map((id) => mergedCache[id])
      .whereType<UserProfile>()
      .where((profile) => !blockedSet.contains(profile.uid))
      .toList();

  return profiles;
});
