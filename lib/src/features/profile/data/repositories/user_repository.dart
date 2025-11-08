import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<bool> isNicknameAvailable(String nickname) async {
    final normalizedNickname = nickname.trim().toLowerCase();
    final querySnapshot = await _firestore
        .collection('users')
        .where('nicknameLowercase', isEqualTo: normalizedNickname)
        .limit(1)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  Future<void> createUserProfile(UserProfile profile) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(profile.uid);

    final data = UserProfile.toFirestore(profile);
    data['nicknameLowercase'] = profile.nickname.trim().toLowerCase();

    batch.set(userRef, data);
    await batch.commit();
  }

  Future<bool> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (updates.containsKey('nickname')) {
        final newNickname = updates['nickname'] as String;
        final isAvailable = await isNicknameAvailable(newNickname);
        if (!isAvailable) {
          return false;
        }
        updates['nicknameLowercase'] = newNickname.trim().toLowerCase();
        updates['nicknameVerified'] = true;
        updates['lastNicknameChangeAt'] = Timestamp.fromDate(DateTime.now());
      }

      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore.collection('users').doc(uid).update(updates);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> canChangeNickname(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      if (profile?.lastNicknameChangeAt == null) return true;

      final daysSinceLastChange = DateTime.now()
          .difference(profile!.lastNicknameChangeAt!)
          .inDays;

      return daysSinceLastChange >= 30;
    } catch (e) {
      return false;
    }
  }

  Future<int> getDaysUntilNicknameChange(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      if (profile?.lastNicknameChangeAt == null) return 0;

      final daysSinceLastChange = DateTime.now()
          .difference(profile!.lastNicknameChangeAt!)
          .inDays;

      final daysRemaining = 30 - daysSinceLastChange;
      return daysRemaining > 0 ? daysRemaining : 0;
    } catch (e) {
      return 30;
    }
  }
}
