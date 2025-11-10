import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../profile/domain/models/user_profile.dart';
import '../../../../core/utils/search_keywords_generator.dart';
import '../models/search_filters.dart';

class SearchRepository {
  SearchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<UserProfile>> searchProfiles(
    SearchFilters filters, {
    int limit = 50,
  }) async {
    final hasQuery = filters.query.trim().isNotEmpty;
    final shouldFilterInterestsLocally = hasQuery && filters.interests.isNotEmpty;

    final query = _buildQuery(filters).limit(limit);
    final snapshot = await query.get();

    var profiles = snapshot.docs.map(UserProfile.fromFirestore).toList();

    if (shouldFilterInterestsLocally) {
      profiles = _filterProfilesByInterests(profiles, filters.interests);
    }

    return profiles;
  }

  Stream<List<UserProfile>> watchProfiles(
    SearchFilters filters, {
    int limit = 50,
  }) {
    final hasQuery = filters.query.trim().isNotEmpty;
    final shouldFilterInterestsLocally = hasQuery && filters.interests.isNotEmpty;

    final query = _buildQuery(filters).limit(limit);

    return query.snapshots().map((snapshot) {
      var profiles = snapshot.docs.map(UserProfile.fromFirestore).toList();

      if (shouldFilterInterestsLocally) {
        profiles = _filterProfilesByInterests(profiles, filters.interests);
      }

      return profiles;
    });
  }

  Query<Map<String, dynamic>> _buildQuery(SearchFilters filters) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('users').where('profileVisible', isEqualTo: true);

    final hasQuery = filters.query.trim().isNotEmpty;
    final shouldApplyInterestFilter =
        filters.interests.isNotEmpty && !hasQuery;

    if (hasQuery) {
      final tokens = SearchKeywordsGenerator.buildQueryTokens(filters.query)
          .take(10)
          .toList();
      if (tokens.isNotEmpty) {
        query = query.where('searchKeywords', arrayContainsAny: tokens);
      }
    }

    if (filters.school != null && filters.school!.isNotEmpty) {
      query = query.where('school', isEqualTo: filters.school);
    }

    final hasSchoolYearRange =
        filters.minSchoolYear != null || filters.maxSchoolYear != null;
    if (filters.minSchoolYear != null) {
      query = query.where(
        'schoolYear',
        isGreaterThanOrEqualTo: filters.minSchoolYear,
      );
    }

    if (filters.maxSchoolYear != null) {
      query = query.where(
        'schoolYear',
        isLessThanOrEqualTo: filters.maxSchoolYear,
      );
    }

    if (shouldApplyInterestFilter) {
      final interests = filters.interests.take(10).toList();
      query = query.where('interests', arrayContainsAny: interests);
    }

    if (filters.minTrustLevel != null) {
      query = query.where(
        'trustLevel',
        isGreaterThanOrEqualTo: filters.minTrustLevel,
      );
    }

    if (hasQuery) {
      query = query.orderBy('createdAt', descending: true);
      return query;
    }

    if (hasSchoolYearRange) {
      query = query.orderBy('schoolYear');
      query = query.orderBy('trustLevel', descending: true);
      query = query.orderBy('nicknameLowercase');
      return query;
    }

    if (filters.minTrustLevel != null) {
      query = query.orderBy('trustLevel', descending: true);
      query = query.orderBy('nicknameLowercase');
      return query;
    }

    query = query.orderBy('nicknameLowercase');
    return query;
  }

  List<UserProfile> _filterProfilesByInterests(
    List<UserProfile> profiles,
    List<String> requiredInterests,
  ) {
    return profiles.where((profile) {
      final profileInterestsLower = profile.interests
          .map((interest) => interest.toLowerCase())
          .toSet();
      final requiredInterestsLower = requiredInterests
          .map((interest) => interest.toLowerCase())
          .toSet();

      return requiredInterestsLower
          .any((interest) => profileInterestsLower.contains(interest));
    }).toList();
  }
}
