import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/domain/models/user_profile.dart';

final _conversationListProfileProvider =
    Provider<AsyncValue<UserProfile?>>((ref) => const AsyncValue.data(null));
