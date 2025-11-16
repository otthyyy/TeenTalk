import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

class UserRepository {

  UserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<bool> isNicknameAvailable(String nickname, {String? excludeUid}) async {
    final normalizedNickname = nickname.trim().toLowerCase();
    
    // Check usernames collection first (atomic reservation system)
    final usernameDoc = await _firestore
        .collection('usernames')
        .doc(normalizedNickname)
        .get();
    
    if (usernameDoc.exists) {
      final data = usernameDoc.data();
      final reservedByUid = data?['uid'] as String?;
      // If the nickname is reserved by the current user (excludeUid), it's available to them
      if (excludeUid != null && reservedByUid == excludeUid) {
        return true;
      }
      return false;
    }
    
    // Fallback: check users collection (for backwards compatibility)
    final querySnapshot = await _firestore
        .collection('users')
        .where('nicknameLowercase', isEqualTo: normalizedNickname)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return true;
    }
    
    // If the only match is the current user, it's available to them
    if (excludeUid != null && querySnapshot.docs.length == 1) {
      final doc = querySnapshot.docs.first;
      return doc.id == excludeUid;
    }

    return false;
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
    debugPrint('📄 USER REPOSITORY: Subscribing to users/$uid');
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          debugPrint('📄 USER REPOSITORY: Snapshot received for users/$uid (exists=${doc.exists})');
          if (!doc.exists) {
            debugPrint('📄 USER REPOSITORY: Document missing for users/$uid');
            return null;
          }

          final data = doc.data();
          debugPrint('📄 USER REPOSITORY: Document data: $data');

          final profile = UserProfile.fromFirestore(doc);
          debugPrint('📄 USER REPOSITORY: Parsed profile -> onboardingComplete=${profile.onboardingComplete}, school=${profile.school}, interests=${profile.interests}');
          return profile;
        });
  }

  Future<void> createUserProfile(UserProfile profile) async {
    final nicknameLowercase = profile.nickname.trim().toLowerCase();
    final usernameRef = _firestore.collection('usernames').doc(nicknameLowercase);
    final userRef = _firestore.collection('users').doc(profile.uid);

    debugPrint('📄 USER REPOSITORY: Saving user profile for uid=${profile.uid}');
    debugPrint('   Nickname: ${profile.nickname} (normalized: $nicknameLowercase)');

    // Use a transaction to atomically reserve the nickname and create the user profile
    await _firestore.runTransaction((transaction) async {
      // Check if nickname is already taken by another user
      final usernameDoc = await transaction.get(usernameRef);
      
      if (usernameDoc.exists) {
        final existingUid = usernameDoc.data()?['uid'] as String?;
        // Allow the same user to update their profile (e.g., during re-onboarding)
        if (existingUid != profile.uid) {
          debugPrint('❌ USER REPOSITORY: Nickname already taken by uid=$existingUid');
          throw Exception('Nickname already taken');
        }
        debugPrint('✅ USER REPOSITORY: Nickname already reserved by current user, proceeding');
      }

      // Reserve the nickname (preserve createdAt if already set)
      final usernameData = <String, dynamic>{
        'uid': profile.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!usernameDoc.exists || usernameDoc.data()?['createdAt'] == null) {
        usernameData['createdAt'] = FieldValue.serverTimestamp();
      }
      transaction.set(usernameRef, usernameData, SetOptions(merge: true));

      // Create/update the user profile
      final data = UserProfile.toFirestore(profile);
      data['nicknameLowercase'] = nicknameLowercase;
      data['searchKeywords'] = profile.generateSearchKeywords();
      
      debugPrint('   Data: ${Map<String, dynamic>.from(data)}');
      
      transaction.set(userRef, data, SetOptions(merge: true));
    });

    debugPrint('📄 USER REPOSITORY: Profile and nickname reservation saved successfully');
  }

  Future<bool> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      final shouldHandleNicknameChange = updates.containsKey('nickname');
      final normalizedNickname = shouldHandleNicknameChange
          ? (updates['nickname'] as String).trim()
          : null;
      final nicknameLowercase = normalizedNickname?.toLowerCase();

      final keywordFields = {
        'nickname',
        'school',
        'schoolYear',
        'interests',
        'clubs',
        'gender',
      };

      // Fetch current profile once to reuse across calculations
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return false;
      }

      final currentProfile = UserProfile.fromFirestore(userDoc);

      if (shouldHandleNicknameChange) {
        if (normalizedNickname == null || normalizedNickname.isEmpty) {
          return false;
        }

        // Transactionally move nickname reservation to new nickname
        final currentNicknameLower = currentProfile.nickname.trim().toLowerCase();
        final newUsernameRef = _firestore.collection('usernames').doc(nicknameLowercase);
        final currentUsernameRef = _firestore.collection('usernames').doc(currentNicknameLower);

        final isAvailable = await isNicknameAvailable(
          normalizedNickname,
          excludeUid: uid,
        );

        if (!isAvailable) {
          return false;
        }

        await _firestore.runTransaction((transaction) async {
          // Reserve new nickname
          final newUsernameDoc = await transaction.get(newUsernameRef);
          if (newUsernameDoc.exists && newUsernameDoc.data()?['uid'] != uid) {
            throw Exception('Nickname already taken');
          }

          transaction.set(newUsernameRef, {
            'uid': uid,
            'createdAt': newUsernameDoc.exists
                ? newUsernameDoc.data()?['createdAt']
                : FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Release old nickname reservation if different
          if (currentNicknameLower != nicknameLowercase) {
            transaction.delete(currentUsernameRef);
          }

          // Update user document with new nickname details
          updates['nickname'] = normalizedNickname;
          updates['nicknameLowercase'] = nicknameLowercase;
          updates['nicknameVerified'] = true;
          updates['lastNicknameChangeAt'] = Timestamp.fromDate(DateTime.now());

          // Update search keywords with new nickname
          updates['searchKeywords'] = UserProfile.buildSearchKeywords(
            normalizedNickname,
            updates.containsKey('school')
                ? updates['school'] as String?
                : currentProfile.school,
            updates.containsKey('schoolYear')
                ? updates['schoolYear'] as String?
                : currentProfile.schoolYear,
            updates.containsKey('interests')
                ? (updates['interests'] as List?)?.whereType<String>().toList() ?? []
                : currentProfile.interests,
            updates.containsKey('clubs')
                ? (updates['clubs'] as List?)?.whereType<String>().toList() ?? []
                : currentProfile.clubs,
            updates.containsKey('gender')
                ? updates['gender'] as String?
                : currentProfile.gender,
          );

          updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

          transaction.update(userDoc.reference, updates);
        });

        return true;
      }

      final shouldUpdateKeywords =
          updates.keys.any((key) => keywordFields.contains(key));

      if (shouldUpdateKeywords) {
        final nicknameForKeywords = currentProfile.nickname;
        final schoolForKeywords = updates.containsKey('school')
            ? updates['school'] as String?
            : currentProfile.school;
        final schoolYearForKeywords = updates.containsKey('schoolYear')
            ? updates['schoolYear'] as String?
            : currentProfile.schoolYear;
        final interestsForKeywords = updates.containsKey('interests')
            ? (updates['interests'] as List?)?.whereType<String>().toList() ?? []
            : currentProfile.interests;
        final clubsForKeywords = updates.containsKey('clubs')
            ? (updates['clubs'] as List?)?.whereType<String>().toList() ?? []
            : currentProfile.clubs;
        final genderForKeywords = updates.containsKey('gender')
            ? updates['gender'] as String?
            : currentProfile.gender;

        updates['searchKeywords'] = UserProfile.buildSearchKeywords(
          nicknameForKeywords,
          schoolForKeywords,
          schoolYearForKeywords,
          interestsForKeywords,
          clubsForKeywords,
          genderForKeywords,
        );
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
